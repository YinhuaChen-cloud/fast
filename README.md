# Simplified Version of FAST

This project is a simplified reproduction of FAST, which is a SPEC-fuzzing technique presented in this paper "Finding Specification Blind Spots via Fuzz Testing"

The repo applied FAST is s2n-tls, the original repo url is https://github.com/aws/s2n-tls.git

## Where to simplify?

1. The mutation strategy is "Random Mutation", not the "Evolutionary Mutation" mentioned in the paper.

2. The program will stop when it finds a surviving code mutant passing SAW verification, regardless of whether it passes the test suite. (But the surviving code mutant will then be sent to test suite)

3. To obtain quick feedback results and shorten the development cycle when using random mutation, I only mutated the code in two functions: s2n_conn_set_handshake_type in s2n_handshake_io.c and s2nshake_type_set_tls12_flag in s2n_handshake_type.c. But it is possible to switch to mutation on all s2n-tls code. The related documentation is here: https://github.com/YinhuaChen-cloud/fast-pass.

## Any experiment results?

Actually, I find out a code mutant which can pass both SAW verification and test suite, and this code mutant is not specifically mentioned in the paper.

The code mutant is in s2n_handshake_io.c : s2n_conn_set_handshake_type, as the following image

![image](https://github.com/YinhuaChen-cloud/fast/assets/57990071/79ebdf8c-f035-48cb-b813-ad16a6e41012)

If change the "<" to "!=", the result code can still pass SAW verification and test suite

## How to run ?

Use the following commands to run FAST
```
  sudo make fast -j$(nproc)
```



