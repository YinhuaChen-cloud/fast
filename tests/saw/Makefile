#####################
# Copyright 2016 Galois, Inc. All Rights Reserved
#
#  Authors:
#	Joey Dodds : jdodds@galois.com
#       Nathan Collins : conathan@galois.com
#	
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
########################

#The scripts are all of the saw files in this directory
SCRIPTS = $(wildcard *.saw)
#A log file will be created for each test in the temp dir
LOGS=$(patsubst %.saw,tmp/%.log,$(SCRIPTS))
SHELL:=/bin/bash
YICES_VERSION=$(shell yices-smt2 --version)
export LIBCRYPTO_ROOT:=$(shell pwd)/../../libcrypto-root

.PHONY : all
all:
	@echo "Running formal verification with ${YICES_VERSION}"
	@${MAKE} clean-logs
	@${MAKE} clean_the_dir
	@${MAKE} $(LOGS)
	@${MAKE} failure-tests


############################################
## Clean targets
############################################
.PHONY : clean-logs
clean-logs : 
	$(RM) -- $(wildcard tmp/*.log)

.PHONY : clean-bitcode
clean-bitcode :
	$(RM) -- bitcode/all_llvm.bc

.PHONY : clean-failure-logs
clean-failure-logs :
	$(RM) -- $(wildcard failure_tests/*.log)

.PHONY: clean
clean: decruft

.PHONY: decruft
decruft : clean-logs
	${MAKE} -C bitcode decruft
	${RM} -r s2n
	${RM} -r tmp

clean_the_dir :
	${RM} -r s2n
	${RM} -r tmp
	${RM} -r failure_tests/*.log
	${RM} -r bitcode/*.bc

###########################################
## Script Tests
###########################################

# To make a log we need the corresponding saw file, the all_llvm file, and a temp directory
# The pipefail command causes the entire command to fail if saw fails, even though we pipe it to tee
# without it we would see only the tee return code
tmp/%.log : %.saw bitcode/all_llvm.bc tmp
	@echo "Running formal verification with ${YICES_VERSION}"
	@echo "Running formal verification with SAW version:"
	@saw --version
	set -o pipefail; \
	sudo docker run -v $(shell pwd):/a ghcr.io/galoisinc/saw:nightly a/$< | tee $@
# saw $< | tee $@

###########################################
## Failure Tests
##
## where we patch the code and make sure
## that our proofs fail when it is patched
## with errors
###########################################

#These won't work in parallel, so we just hard code them,
#Otherwise we'd have to make a separate patched folder for each one
.PHONY : failure-tests
failure-tests : bitcode
	@${MAKE} clean-failure-logs
	@${MAKE} failure_tests/tls_early_ccs.log
	@${MAKE} failure_tests/tls_missing_full_handshake.log
	@${MAKE} failure_tests/sha_bad_magic_mod.log
	@${MAKE} failure_tests/cork_one.log
	@${MAKE} failure_tests/cork_two.log

#The bitcode files don't get deleted, in case we want to do tests on them
.SECONDARY : $(wildcard bitcode/*.bc)

# We're just making separate prefix targets for each saw script we want to do
# negative tests on
failure_tests/sha_%.log : bitcode/sha_%.bc
        #this might not be necessary
	cp $< bitcode/all_llvm.bc 
	set -o pipefail; \
	! (saw verify_HMAC.saw 2>&1 | tee $@)
	grep "error: in _SAW_verify_prestate" $@

failure_tests/tls_%.log : bitcode/tls_%.bc
        #this might not be necessary
	cp $< bitcode/all_llvm.bc 
	set -o pipefail; \
	! (saw verify_state_machine.saw 2>&1 | tee $@)
	grep "error: in _SAW_verify_prestate" $@

failure_tests/cork_%.log : bitcode/cork_%.bc
        #this might not be necessary
	cp $< bitcode/all_llvm.bc 
	set -o pipefail; \
	! (saw verify_cork_uncork.saw 2>&1 | tee $@)
	grep "error: in llvm_ghost_value" $@


# we patch the s2n dir, build it with the top level s2n makefile, and
# move the resulting, patched and linked llvm bitcode into our bitcode directory
bitcode/%.bc : failure_tests/%.patch
	patch -p1 -d s2n -i ../$<
	${MAKE} -C s2n bc; \
	${MAKE} bitcode/all_llvm.bc; \
        status=$$?; \
	cp bitcode/all_llvm.bc $@
	patch -R -p1 -d s2n -i  ../$<; \
        exit $$status

#if we ask this makefile to create bitcode it will always completely rebuild it
.PHONY : bitcode
bitcode :
	${MAKE} clean_the_dir
	${MAKE} bitcode/all_llvm.bc

########################################################
## Rules to copy the s2n directory for patching and bulding
########################################################

CRYPTO_C = $(wildcard ../../crypto/*.c) $(wildcard ../../crypto/*.h) ../../crypto/Makefile
CRYPTO_COPY = $(addprefix s2n/crypto/, $(notdir $(CRYPTO_C)))

PQ_CRYPTO_C = $(wildcard ../../pq-crypto/*.c) $(wildcard ../../pq-crypto/*.h) ../../pq-crypto/s2n_pq_asm.mk ../../pq-crypto/Makefile
PQ_CRYPTO_COPY = $(addprefix s2n/pq-crypto/, $(notdir $(PQ_CRYPTO_C)))

KYBER_R3_C = $(wildcard ../../pq-crypto/kyber_r3/*.c) $(wildcard ../../pq-crypto/kyber_r3/*.h) ../../pq-crypto/kyber_r3/Makefile
KYBER_R3_COPY = $(addprefix s2n/pq-crypto/kyber_r3/, $(notdir $(KYBER_R3_C)))

UTILS_C = $(wildcard ../../utils/*.c) $(wildcard ../../utils/*.h) ../../utils/Makefile
UTILS_COPY =$(addprefix s2n/utils/, $(notdir $(UTILS_C)))

TLS_C = $(wildcard ../../tls/*.c ../../tls/*/*.c ../../tls/*.h ../../tls/*/*.h ../../tls/*/Makefile) ../../tls/Makefile
TLS_COPY = $(subst ../../tls/, s2n/tls/, $(TLS_C))
TLS_DIRS = $(sort $(dir $(TLS_COPY)))

STUFFER_C = $(wildcard ../../stuffer/*.c) $(wildcard ../../stuffer/*.h) ../../stuffer/Makefile
STUFFER_COPY =$(addprefix s2n/stuffer/, $(notdir $(STUFFER_C)))

API_COPY = $(subst ../../api, s2n/api, $(wildcard ../../api/*.h ../../api/*/*.h))
API_DIRS = $(sort $(dir $(API_COPY)))

ERROR_C = $(wildcard ../../error/*.c) $(wildcard ../../error/*.h) ../../error/Makefile
ERROR_COPY = $(addprefix s2n/error/, $(notdir $(ERROR_C)))

LIB_COPY = s2n/lib/Makefile

s2n/error :
	mkdir -p $@

s2n/api :
	mkdir -p $(API_DIRS)

s2n/crypto :
	mkdir -p $@

s2n/pq-crypto :
	mkdir -p $@

s2n/pq-crypto/kyber_r3 :
	mkdir -p $@

s2n/utils :
	mkdir -p $@

s2n/tls :
	mkdir -p $(TLS_DIRS)

s2n/stuffer :
	mkdir -p $@

s2n/lib :
	mkdir -p $@

export BITCODE_DIR := $(CURDIR)/bitcode/

tmp:
	mkdir -p tmp

bitcode/all_llvm.bc : s2n/crypto s2n/pq-crypto s2n/utils s2n/tls s2n/api s2n/error s2n/stuffer s2n/Makefile s2n/s2n.mk $(CRYPTO_COPY) $(PQ_CRYPTO_COPY) $(UTILS_COPY) $(TLS_COPY) $(API_COPY) $(ERROR_COPY) $(STUFFER_COPY)
	${MAKE} -C s2n bc
	${MAKE} -C bitcode all_llvm.bc

s2n/lib/libs2n.so : s2n/crypto s2n/pq-crypto s2n/pq-crypto/kyber_r3 s2n/utils s2n/tls s2n/api s2n/error s2n/stuffer s2n/lib s2n/Makefile s2n/s2n.mk $(CRYPTO_COPY) $(PQ_CRYPTO_COPY) $(KYBER_R3_COPY) $(UTILS_COPY) $(TLS_COPY) $(API_COPY) $(ERROR_COPY) $(STUFFER_COPY) $(LIB_COPY)
	${MAKE} -C s2n libs NO_STACK_PROTECTOR=1 NO_INLINE=1

s2n/%.h : ../../%.h
	cp $< $@

s2n/%.c : ../../%.c
	cp $< $@

s2n/%.S : ../../%.S
	cp $< $@

s2n/%Makefile : ../../%Makefile
	cp $< $@

s2n/Makefile : ../../Makefile
	cp $< $@

s2n/s2n.mk : ../../s2n.mk
	cp $< $@

s2n/pq-crypto/s2n_pq_asm.mk : ../../pq-crypto/s2n_pq_asm.mk
	cp $< $@


# added by cyh --- start
# libs2n.so 的一部分，但是不属于 all_llvm.bc 的源C代码文件
MOREFILES = $(addprefix $(S2N_ROOT)/, $(shell cat morefiles))
MOREOBJS = $(addprefix libs2n_objs/, $(addsuffix .o, $(shell cat morefiles)))	
# 使用filter函数找到以"_avx2.c.o"结尾的目标文件
AVX2_OBJS = $(filter %_avx2.c.o, $(MOREOBJS))

# 1. 编译 libs2n.so
.PHONY : total-fast
total-fast :
# 先清理临时文件，比如 tmp/*.log，s2n，failure_tests，bitcode 等
	@${MAKE} clean-logs
	@${MAKE} clean_the_dir
# FAST 分为
# 	1. 编译SAW验证相关源码为 LLVM BC，链接成为成为 all_llvm.bc
	make bitcode/all_llvm.bc
#		2. 把 all_llvm.bc 转换成 all_llvm.ll (LLVM IR) 的一种
	llvm-dis bitcode/all_llvm.bc -o bitcode/all_llvm.ll
#   3. 进行代码突变
	make mutation
#   4. 把突变后的 all_llvm.ll 转回 all_llvm.bc
	llvm-as bitcode/all_llvm.ll -o bitcode/all_llvm.bc
#   5. 对突变后的 all_llvm.bc 进行 SAW 验证，SAW验证时的输出放在 tmp 文件夹下
	@${MAKE} $(LOGS)
# 	6. SAW验证结束后，把 all_llvm.bc 文件转换成 all_llvm.o 文件
	llc -filetype=obj --relocation-model=pic bitcode/all_llvm.bc -o bitcode/all_llvm.o
#   7. 把 all_llvm.o 和 其它 .o 文件共同链接成 libs2n.so 动态库
	make cyhlink
#   9. 运行测试套件
	cp lib/* $(S2N_ROOT)/build/lib
	make -C $(S2N_ROOT)/build test ARGS="-L unit --output-on-failure -j $(shell nproc)"


cyhlink : $(MOREOBJS) bitcode/all_llvm.o
# 链接成 libs2n.so, libs2n.so.1, libs2n.so.1.0.0
	clang -fPIC \
	-Wl,-z,noexecstack,-z,relro,-z,now \
	-shared \
	-Wl,-soname,libs2n.so.1 \
	-o lib/libs2n.so.1.0.0 \
	$^ \
	-Wl,-rpath,$(S2N_ROOT)/test-deps/openssl-1.1.1/lib: \
	$(S2N_ROOT)/test-deps/openssl-1.1.1/lib/libcrypto.so \
	-ldl \
	-lrt \
	-lm \
	-pthread 
	cmake -E cmake_symlink_library lib/libs2n.so.1.0.0 lib/libs2n.so.1 lib/libs2n.so
	cmake -E touch_nocreate lib/libs2n.so


# 当多个规则匹配同一个目标时，老版本的 make 会选用第一个规则
# 新版本的 make 会选用最 specific 的规则
$(AVX2_OBJS) : libs2n_objs/%.o : $(S2N_ROOT)/%
	@mkdir -p $(dir $@)
	clang	$(FAST_CLANG_FLAGS) -mavx2 -mavx -mbmi2 -o $@ -c $<

libs2n_objs/%.o : $(S2N_ROOT)/%
	@mkdir -p $(dir $@)
	clang	$(FAST_CLANG_FLAGS) -o $@ -c $<


FAST_CLANG_FLAGS = -D_POSIX_C_SOURCE=200809L \
	-Ds2n_EXPORTS \
	-I$(S2N_ROOT) \
	-I$(S2N_ROOT)/api \
	-isystem $(S2N_ROOT)/test-deps/openssl-1.1.1/include \
	-fPIC \
	-pedantic \
	-std=gnu99 \
	-Wall \
	-Wimplicit \
	-Wunused \
	-Wcomment \
	-Wchar-subscripts \
	-Wuninitialized \
	-Wshadow \
	-Wcast-align \
	-Wwrite-strings \
	-Wno-deprecated-declarations \
	-Wno-unknown-pragmas \
	-Wformat-security \
	-Wno-missing-braces \
	-Wno-strict-prototypes \
	-Wa,--noexecstack \
	-Wsign-compare \
	-Werror \
	-fvisibility=default \
	-DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=1 \
	-DS2N_KYBER512R3_AVX2_BMI2 \
	-DS2N_STACKTRACE \
	-DS2N_CPUID_AVAILABLE \
	-DS2N_FEATURES_AVAILABLE \
	-fPIC \
	-DS2N_FALL_THROUGH_SUPPORTED \
	-DS2N___RESTRICT__SUPPORTED \
	-DS2N_MADVISE_SUPPORTED \
	-DS2N_CLONE_SUPPORTED \
	-Wcast-qual \
	-DS2N_LIBCRYPTO_SUPPORTS_EVP_MD5_SHA1_HASH \
	-DS2N_LIBCRYPTO_SUPPORTS_EVP_RC4 \
	-DS2N_LIBCRYPTO_SUPPORTS_EVP_MD_CTX_SET_PKEY_CTX \
	-DS2N_PLATFORM_SUPPORTS_KTLS \
	-pthread \
  -g -O1


# /usr/bin/clang -D_POSIX_C_SOURCE=200809L -Ds2n_EXPORTS -I/home/ieda/prjs/s2n-tls -I/home/ieda/prjs/s2n-tls/api -isystem /home/ieda/prjs/s2n-tls/test-deps/openssl-1.1.1/include  -fPIC   -pedantic -std=gnu99 -Wall -Wimplicit -Wunused -Wcomment -Wchar-subscripts -Wuninitialized -Wshadow -Wcast-align -Wwrite-strings -Wno-deprecated-declarations -Wno-unknown-pragmas -Wformat-security -Wno-missing-braces -Wno-strict-prototypes -Wa,--noexecstack -Wsign-compare -Werror -fvisibility=default -DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=1 -DS2N_KYBER512R3_AVX2_BMI2 -DS2N_STACKTRACE -DS2N_CPUID_AVAILABLE -DS2N_FEATURES_AVAILABLE -fPIC -DS2N_FALL_THROUGH_SUPPORTED -DS2N___RESTRICT__SUPPORTED -DS2N_MADVISE_SUPPORTED -DS2N_CLONE_SUPPORTED -Wcast-qual -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD5_SHA1_HASH -DS2N_LIBCRYPTO_SUPPORTS_EVP_RC4 -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD_CTX_SET_PKEY_CTX -DS2N_PLATFORM_SUPPORTS_KTLS -pthread -g -O1 -c /home/ieda/prjs/s2n-tls/pq-crypto/kyber_r3/kyber512r3_basemul_avx2.S -o libs2n_objs/pq-crypto/kyber_r3/kyber512r3_basemul_avx2.S.o
# /usr/bin/clang -D_POSIX_C_SOURCE=200809L -Ds2n_EXPORTS -I/home/ieda/prjs/s2n-tls -I/home/ieda/prjs/s2n-tls/api -isystem /home/ieda/prjs/s2n-tls/test-deps/openssl-1.1.1/include  -fPIC   -pedantic -std=gnu99 -Wall -Wimplicit -Wunused -Wcomment -Wchar-subscripts -Wuninitialized -Wshadow -Wcast-align -Wwrite-strings -Wno-deprecated-declarations -Wno-unknown-pragmas -Wformat-security -Wno-missing-braces -Wno-strict-prototypes -Wa,--noexecstack -Wsign-compare -Werror -fvisibility=default -DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=1 -DS2N_KYBER512R3_AVX2_BMI2 -DS2N_STACKTRACE -DS2N_CPUID_AVAILABLE -DS2N_FEATURES_AVAILABLE -fPIC -DS2N_FALL_THROUGH_SUPPORTED -DS2N___RESTRICT__SUPPORTED -DS2N_MADVISE_SUPPORTED -DS2N_CLONE_SUPPORTED -Wcast-qual -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD5_SHA1_HASH -DS2N_LIBCRYPTO_SUPPORTS_EVP_RC4 -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD_CTX_SET_PKEY_CTX -DS2N_PLATFORM_SUPPORTS_KTLS -pthread -g -O1 -c /home/ieda/prjs/s2n-tls/pq-crypto/kyber_r3/kyber512r3_fq_avx2.S -o libs2n_objs/pq-crypto/kyber_r3/kyber512r3_fq_avx2.S.o
# /usr/bin/clang -D_POSIX_C_SOURCE=200809L -Ds2n_EXPORTS -I/home/ieda/prjs/s2n-tls -I/home/ieda/prjs/s2n-tls/api -isystem /home/ieda/prjs/s2n-tls/test-deps/openssl-1.1.1/include  -fPIC   -pedantic -std=gnu99 -Wall -Wimplicit -Wunused -Wcomment -Wchar-subscripts -Wuninitialized -Wshadow -Wcast-align -Wwrite-strings -Wno-deprecated-declarations -Wno-unknown-pragmas -Wformat-security -Wno-missing-braces -Wno-strict-prototypes -Wa,--noexecstack -Wsign-compare -Werror -fvisibility=default -DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=1 -DS2N_KYBER512R3_AVX2_BMI2 -DS2N_STACKTRACE -DS2N_CPUID_AVAILABLE -DS2N_FEATURES_AVAILABLE -fPIC -DS2N_FALL_THROUGH_SUPPORTED -DS2N___RESTRICT__SUPPORTED -DS2N_MADVISE_SUPPORTED -DS2N_CLONE_SUPPORTED -Wcast-qual -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD5_SHA1_HASH -DS2N_LIBCRYPTO_SUPPORTS_EVP_RC4 -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD_CTX_SET_PKEY_CTX -DS2N_PLATFORM_SUPPORTS_KTLS -pthread -g -O1 -c /home/ieda/prjs/s2n-tls/pq-crypto/kyber_r3/kyber512r3_invntt_avx2.S -o libs2n_objs/pq-crypto/kyber_r3/kyber512r3_invntt_avx2.S.o
# /usr/bin/clang -D_POSIX_C_SOURCE=200809L -Ds2n_EXPORTS -I/home/ieda/prjs/s2n-tls -I/home/ieda/prjs/s2n-tls/api -isystem /home/ieda/prjs/s2n-tls/test-deps/openssl-1.1.1/include  -fPIC   -pedantic -std=gnu99 -Wall -Wimplicit -Wunused -Wcomment -Wchar-subscripts -Wuninitialized -Wshadow -Wcast-align -Wwrite-strings -Wno-deprecated-declarations -Wno-unknown-pragmas -Wformat-security -Wno-missing-braces -Wno-strict-prototypes -Wa,--noexecstack -Wsign-compare -Werror -fvisibility=default -DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=1 -DS2N_KYBER512R3_AVX2_BMI2 -DS2N_STACKTRACE -DS2N_CPUID_AVAILABLE -DS2N_FEATURES_AVAILABLE -fPIC -DS2N_FALL_THROUGH_SUPPORTED -DS2N___RESTRICT__SUPPORTED -DS2N_MADVISE_SUPPORTED -DS2N_CLONE_SUPPORTED -Wcast-qual -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD5_SHA1_HASH -DS2N_LIBCRYPTO_SUPPORTS_EVP_RC4 -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD_CTX_SET_PKEY_CTX -DS2N_PLATFORM_SUPPORTS_KTLS -pthread -g -O1 -c /home/ieda/prjs/s2n-tls/pq-crypto/kyber_r3/kyber512r3_ntt_avx2.S -o libs2n_objs/pq-crypto/kyber_r3/kyber512r3_ntt_avx2.S.o
# /usr/bin/clang -D_POSIX_C_SOURCE=200809L -Ds2n_EXPORTS -I/home/ieda/prjs/s2n-tls -I/home/ieda/prjs/s2n-tls/api -isystem /home/ieda/prjs/s2n-tls/test-deps/openssl-1.1.1/include  -fPIC   -pedantic -std=gnu99 -Wall -Wimplicit -Wunused -Wcomment -Wchar-subscripts -Wuninitialized -Wshadow -Wcast-align -Wwrite-strings -Wno-deprecated-declarations -Wno-unknown-pragmas -Wformat-security -Wno-missing-braces -Wno-strict-prototypes -Wa,--noexecstack -Wsign-compare -Werror -fvisibility=default -DS2N_BLOCK_NONPORTABLE_OPTIMIZATIONS=1 -DS2N_KYBER512R3_AVX2_BMI2 -DS2N_STACKTRACE -DS2N_CPUID_AVAILABLE -DS2N_FEATURES_AVAILABLE -fPIC -DS2N_FALL_THROUGH_SUPPORTED -DS2N___RESTRICT__SUPPORTED -DS2N_MADVISE_SUPPORTED -DS2N_CLONE_SUPPORTED -Wcast-qual -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD5_SHA1_HASH -DS2N_LIBCRYPTO_SUPPORTS_EVP_RC4 -DS2N_LIBCRYPTO_SUPPORTS_EVP_MD_CTX_SET_PKEY_CTX -DS2N_PLATFORM_SUPPORTS_KTLS -pthread -g -O1 -c /home/ieda/prjs/s2n-tls/pq-crypto/kyber_r3/kyber512r3_shuffle_avx2.S -o libs2n_objs/pq-crypto/kyber_r3/kyber512r3_shuffle_avx2.S.o

.PHONY : mutation
mutation:
	@echo "code mutation"

# added by cyh --- end

