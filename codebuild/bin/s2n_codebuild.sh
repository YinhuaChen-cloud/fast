#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#  http://aws.amazon.com/apache2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#

set -e

source codebuild/bin/s2n_setup_env.sh

# Use prlimit to set the memlock limit to unlimited for linux. OSX is unlimited by default
# Codebuild Containers aren't allowing prlimit changes (and aren't being caught with the usual cgroup check)
if [[ "$OS_NAME" == "linux" && -n "$CODEBUILD_BUILD_ARN" ]]; then
    PRLIMIT_LOCATION=`which prlimit`
    sudo -E ${PRLIMIT_LOCATION} --pid "$$" --memlock=unlimited:unlimited;
fi

# Set the version of GCC as Default if it's required
if [[ -n "$GCC_VERSION" ]] && [[ "$GCC_VERSION" != "NONE" ]]; then
    alias gcc=$(which gcc-$GCC_VERSION);
fi

# Find if the environment has more than 8 cores
JOBS=8
if [[ -x "$(command -v nproc)" ]]; then
    UNITS=$(nproc);
    if [[ $UNITS -gt $JOBS ]]; then
        JOBS=$UNITS;
    fi
fi

# 清除所有已构建的东西
make clean;

echo "Using $JOBS jobs for make..";
echo "running with libcrypto: ${S2N_LIBCRYPTO}, gcc_version: ${GCC_VERSION}"

if [[ "$OS_NAME" == "linux" && "$TESTS" == "valgrind" ]]; then
    # For linux make a build with debug symbols and run valgrind
    # We have to output something every 9 minutes, as some test may run longer than 10 minutes
    # and will not produce any output
    while sleep 9m; do echo "=====[ $SECONDS seconds still running ]====="; done &

    if [[ "$S2N_LIBCRYPTO" == "openssl-1.1.1" || "$S2N_LIBCRYPTO" == "awslc" ]]; then
        # https://github.com/aws/s2n-tls/issues/3758
        # Run valgrind in pedantic mode (--errors-for-leak-kinds=all)
        echo "running task pedantic_valgrind"
        S2N_DEBUG=true make -j $JOBS pedantic_valgrind
    else
        S2N_DEBUG=true make -j $JOBS valgrind
    fi

    kill %1
fi

CMAKE_PQ_OPTION="S2N_NO_PQ=False"
if [[ -n "$S2N_NO_PQ" ]]; then
    CMAKE_PQ_OPTION="S2N_NO_PQ=True"
fi

# cyhNOTE: 这个应该仅仅是用来测试 libcrypto 链接库
test_linked_libcrypto() {
    s2n_executable="$1"
    so_path="${LIBCRYPTO_ROOT}/lib/libcrypto.so"
    echo "Testing for linked libcrypto: ${so_path}"
    echo "ldd:"
    ldd "${s2n_executable}"
    ldd "${s2n_executable}" | grep "${so_path}" || \
        { echo "Linked libcrypto is incorrect."; exit 1; }
    echo "Test succeeded!"
}

setup_apache_server() {
    # Start the apache server if the list of tests isn't defined, meaning all tests
    # are to be run, or if the renegotiate test is included in the list of tests.
    if [[ -z $TOX_TEST_NAME ]] || [[ "${TOX_TEST_NAME}" == *"test_renegotiate_apache"* ]]; then
        source codebuild/bin/s2n_apache2.sh
        APACHE_CERT_DIR="$(pwd)/tests/pems"

        apache2_start "${APACHE_CERT_DIR}"
    fi
}

run_integration_v2_tests() {
    setup_apache_server
    "$CB_BIN_DIR/install_s2n_head.sh" "$(mktemp -d)"
    cmake . -Bbuild \
            -DCMAKE_PREFIX_PATH=$LIBCRYPTO_ROOT \
            -D${CMAKE_PQ_OPTION} \
            -DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=True \
            -DBUILD_SHARED_LIBS=on \
            -DS2N_INTEG_TESTS=on \
            -DPython3_EXECUTABLE=$(which python3)
    cmake --build ./build --clean-first -- -j $(nproc)
    test_linked_libcrypto ./build/bin/s2nc
    test_linked_libcrypto ./build/bin/s2nd
    cp -f ./build/bin/s2nc "$BASE_S2N_DIR"/bin/s2nc
    cp -f ./build/bin/s2nd "$BASE_S2N_DIR"/bin/s2nd
    cd ./build/
    for test_name in $TOX_TEST_NAME; do
      test="${test_name//test_/}"
      echo "Running... ctest --no-tests=error --output-on-failure --verbose -R ^integrationv2_${test}$"
      ctest --no-tests=error --output-on-failure --verbose -R ^integrationv2_${test}$
    done
}

run_unit_tests() {
    cmake . -Bbuild \
            -DCMAKE_PREFIX_PATH=$LIBCRYPTO_ROOT \
            -D${CMAKE_PQ_OPTION} \
            -DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=True \
            -DBUILD_SHARED_LIBS=on \
            -DEXPERIMENTAL_TREAT_WARNINGS_AS_ERRORS=on
# . 指定根CMakeLists.txt文件的路径。
# -Bbuild                                      选项指定生成构建系统的目录。在这种情况下，它将在名为 build 的目录中生成。
# -DCMAKE_PREFIX_PATH=$LIBCRYPTO_ROOT          选项设置 libcrypto 库安装的目录路径。这用于在构建过程中查找和链接库。
# -D${CMAKE_PQ_OPTION}                         选项将名为 CMAKE_PQ_OPTION 的CMake变量设置为在构建系统的其他地方确定的值。这是从外部构建系统向CMake传递选项的常见方法。
# -DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=True   选项将名为 S2N_BLOCK_NONPORTABLE_OPTIMIZATIONS 的CMake变量设置为 True。这用于在 s2n 库中启用非可移植优化。
# -DBUILD_SHARED_LIBS=on                       这用于构建共享库而不是静态库。
# -DEXPERIMENTAL_TREAT_WARNINGS_AS_ERRORS=on   用于在构建过程中将警告视为错误，可以帮助尽早发现潜在问题。
# 根据猜测：这一段是在构建 build 下的构建系统
    cmake --build ./build -- -j $(nproc)
# --build ./build 构建在build目录下生成的构建系统
# -- -j 把参数传给底层构建系统，使用多处理器加速构建
# 根据猜测：这一段实在 build 默认目标: libcrypto.so

    # 测试 libcrypto 链接库
    test_linked_libcrypto ./build/bin/s2nc
    # 运行测试
    cmake --build build/ --target test -- ARGS="-L unit --output-on-failure -j $(nproc)"
    # --target test：此选项指定要构建的目标。在这种情况下，目标是 test，它会构建和运行项目的单元测试。
    # -- ARGS="-L unit --output-on-failure -j $(nproc)"：此选项指定要传递给构建命令的其他参数。
    # 在这种情况下，参数是 -L unit，它会过滤只运行带有 unit 标签的测试，--output-on-failure，它会打印失败测试的输出，
    # 以及 -j $(nproc)，它会使用可用处理器的数量并行运行测试。
    # 猜测：这一段是在运行测试，同时构建s2n可运行程序
    # TODO: 注意，我认为运行测试的方法是，把 s2n-tls 跟要运行的测试一起编译
}

# 在我的环境变量中并没有定义 TESTS，估计是在 source codebuild/bin/s2n_setup_env.sh 这行定义的
# Run Multiple tests on one flag.
if [[ "$TESTS" == "ALL" || "$TESTS" == "sawHMACPlus" ]] && [[ "$OS_NAME" == "linux" ]]; then make -C tests/saw tmp/verify_HMAC.log tmp/verify_drbg.log failure-tests; fi

# Run Individual tests
if [[ "$TESTS" == "ALL" || "$TESTS" == "unit" ]]; then echo "cyh add here" ; run_unit_tests; fi   # 默认情况下运行这一行
if [[ "$TESTS" == "ALL" || "$TESTS" == "interning" ]]; then ./codebuild/bin/test_libcrypto_interning.sh; fi
if [[ "$TESTS" == "ALL" || "$TESTS" == "asan" ]]; then make clean; S2N_ADDRESS_SANITIZER=1 make -j $JOBS ; fi
if [[ "$TESTS" == "ALL" || "$TESTS" == "integrationv2" ]]; then run_integration_v2_tests; fi
if [[ "$TESTS" == "ALL" || "$TESTS" == "crt" ]]; then ./codebuild/bin/build_aws_crt_cpp.sh $(mktemp -d) $(mktemp -d); fi
if [[ "$TESTS" == "ALL" || "$TESTS" == "sharedandstatic" ]]; then ./codebuild/bin/test_install_shared_and_static.sh $(mktemp -d); fi
if [[ "$TESTS" == "ALL" || "$TESTS" == "fuzz" ]]; then (make clean && make fuzz) ; fi
if [[ "$TESTS" == "ALL" || "$TESTS" == "benchmark" ]]; then (make clean && make benchmark) ; fi
if [[ "$TESTS" == "sawHMAC" ]] && [[ "$OS_NAME" == "linux" ]]; then make -C tests/saw/ tmp/verify_HMAC.log ; fi
if [[ "$TESTS" == "sawDRBG" ]]; then make -C tests/saw tmp/verify_drbg.log ; fi
if [[ "$TESTS" == "ALL" || "$TESTS" == "tls" ]]; then make -C tests/saw tmp/verify_handshake.log ; fi
if [[ "$TESTS" == "sawHMACFailure" ]]; then make -C tests/saw failure-tests ; fi
