# Simplified Version of FAST

This project is a simplified reproduction of FAST, which is a SPEC-fuzzing technique presented in this paper "Finding Specification Blind Spots via Fuzz Testing"

The repo applied FAST is s2n-tls, the original repo url is https://github.com/aws/s2n-tls.git

---

## Where to simplify?

1. The mutation strategy is "Random Mutation", not the "Evolutionary Mutation" mentioned in the paper.

2. The program will stop when it finds a surviving code mutant passing SAW verification, regardless of whether it passes the test suite. (But the surviving code mutant will then be sent to test suite)

--- 

## Any experiment results?

Actually, I find out a code mutant which can pass both SAW verification and test suite, and this code mutant is not specifically mentioned in the paper.

The code mutant is as follows:

![image](https://github.com/YinhuaChen-cloud/fast/assets/57990071/79ebdf8c-f035-48cb-b813-ad16a6e41012)

---

## How to run ?

Use the following commands to run FAST
```
  sudo make fast -j$(nproc)
```



