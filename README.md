# Simplified Version of FAST

This project is a simplified reproduction of FAST, which is a SPEC-fuzzing technique presented in this paper "Finding Specification Blind Spots via Fuzz Testing"

The repo applied FAST is s2n-tls, the original repo url is https://github.com/aws/s2n-tls.git

## What to simplify?

1. The mutation strategy is "Random Mutation", not the "Evolutionary Mutation" mentioned in the paper.

2. The program will stop when it finds a surviving code mutant passing SAW verification, regardless of whether it passes the test suite. (But the surviving code mutant will then be sent to test suite)

3. To obtain quick feedback results and shorten the development cycle when using random mutation, I only mutated the code in two functions: s2n_conn_set_handshake_type in s2n_handshake_io.c and s2nshake_type_set_tls12_flag in s2n_handshake_type.c. But it is possible to switch to mutation on all s2n-tls code. The related documentation is here: https://github.com/YinhuaChen-cloud/fast-pass.

## Any experiment results?

Actually, I find out a code mutant which can pass both SAW verification and test suite, and this code mutant is not specifically mentioned in the paper.

The code mutant is in s2n_handshake_io.c : s2n_conn_set_handshake_type, as the following image

![image](https://github.com/YinhuaChen-cloud/fast/assets/57990071/1a140c26-e459-479e-afd8-f94b661dd808)

If change the "<" to "!=", the result code can still pass SAW verification and test suite

## How to run ?

The following commands are tested on Ubuntu20.04

(If memory of machine is too small, the program may crash in the SAW verification part)

```
  sudo apt install clang
  sudo apt-get install libssl-dev
  sudo apt install llvm
  sudo ln -s /usr/bin/llvm-link /usr/bin/llvm-link-3.9
  sudo apt install docker
  sudo apt install docker.io
  sudo docker pull ghcr.io/galoisinc/saw:nightly
  sudo apt install z3
  sudo add-apt-repository ppa:sri-csl/formal-methods
  sudo apt-get update
  sudo apt-get install yices2
  clone this repo
  cd this repo
  S2N_LIBCRYPTO=openssl-1.1.1 BUILD_S2N=true TESTS=integrationv2 GCC_VERSION=9
  sudo codebuild/bin/s2n_install_test_dependencies.sh  (This command installs dependencies of s2n-tls, if you are in China, you may need to configure proxy to run this command successfully)
  codebuild/bin/s2n_codebuild.sh
  mkdir -p tests/saw/lib
  cp build/lib/libs2n.so tests/saw/lib/libs2n.so
  cp build/lib/libs2n.so.1 tests/saw/lib/libs2n.so.1
  cp build/lib/libs2n.so.1.0.0 tests/saw/lib/libs2n.so.1.0.0
  (接下来要配置 LLVM-PASS)
  sudo make fast -j$(nproc) 
```



