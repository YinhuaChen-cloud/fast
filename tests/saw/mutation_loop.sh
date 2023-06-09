#!/bin/bash

# 突变循环 (代码突变 -> 做SAW验证 -> 若没存活，重新突变，若存活，结束 -> 结束时把存活突变体覆盖 all_llvm.bc)
count=0

# 初始化 tmp/saw_log，往里面塞入SAW验证失败的信息，以保证能进入循环
mkdir -p tmp
echo "Proof failed" > tmp/saw_log

#备份 all_llvm.bc 为 all_llvm.bc.backup，这也是后续的突变来源
cp bitcode/all_llvm.bc bitcode/all_llvm.bc.backup

while [ "$(grep "Proof failed" tmp/saw_log)" ]
do
# 1. 代码突变
  # $LLVM_DIR/bin/opt -load ./libInjectFuncCall.so -legacy-inject-func-call bitcode/all_llvm.bc.backup -o bitcode/all_llvm.bc.$count
  cp bitcode/all_llvm.bc bitcode/all_llvm.bc.$count
# 2. 对突变体 进行 SAW 验证，SAW验证时的输出放在 tmp 文件夹下
  # 由于 SAW 脚本只会对 bitcode/all_llvm.bc 进行验证，所以要用突变体覆盖 all_llvm.bc
  cp bitcode/all_llvm.bc.$count bitcode/all_llvm.bc
  # 清空 saw_log
  echo "" > tmp/saw_log
  # 运行 SAW 验证程序
	sudo docker run -v $(pwd):/a ghcr.io/galoisinc/saw:nightly a/verify_cork_uncork.saw 2>&1 >> tmp/saw_log &
	sudo docker run -v $(pwd):/a ghcr.io/galoisinc/saw:nightly a/verify_drbg.saw 2>&1 >> tmp/saw_log &
	sudo docker run -v $(pwd):/a ghcr.io/galoisinc/saw:nightly a/verify_handshake.saw 2>&1 >> tmp/saw_log &
	sudo docker run -v $(pwd):/a ghcr.io/galoisinc/saw:nightly a/verify_HMAC.saw 2>&1 >> tmp/saw_log &
	sudo docker run -v $(pwd):/a ghcr.io/galoisinc/saw:nightly a/verify_imperative_cryptol_spec.saw 2>&1 >> tmp/saw_log &
	sudo docker run -v $(pwd):/a ghcr.io/galoisinc/saw:nightly a/verify_state_machine.saw 2>&1 >> tmp/saw_log &
  echo "Count is $count"
  count=$((count+1))
  # 等待SAW验证结束
  wait
done

# 当从 while loop 中退出时，count 数最高的，以及 all_llvm.bc 就是存活下来的突变体

exit 0

