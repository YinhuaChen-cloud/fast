#
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

SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)

BITCODE_DIR?=../tests/saw/bitcode/

BCS_1= s2n_hash.bc s2n_hmac.bc s2n_drbg.bc s2n_fips.bc s2n_sequence.bc s2n_libcrypto.bc
BCS=$(addprefix $(BITCODE_DIR), $(BCS_1))
# BCS = 
# ../tests/saw/bitcode/s2n_hash.bc 
# ../tests/saw/bitcode/s2n_hmac.bc 
# ../tests/saw/bitcode/s2n_drbg.bc 
# ../tests/saw/bitcode/s2n_fips.bc 
# ../tests/saw/bitcode/s2n_sequence.bc 
# ../tests/saw/bitcode/s2n_libcrypto.bc

.PHONY : all
all: $(OBJS)

.PHONY : bc
bc: $(BCS)
	@echo "cyh: in crpto/Makefile, BCS = $(BCS)"

# added by cyh --- start
IR_DIR?=../tests/saw/ir/

IRS_1= s2n_hash.ir s2n_hmac.ir s2n_drbg.ir s2n_fips.ir s2n_sequence.ir s2n_libcrypto.ir
IRS=$(addprefix $(IR_DIR), $(IRS_1))
# IRS =
# ../tests/saw/ir/s2n_hash.ir 
# ../tests/saw/ir/s2n_hmac.ir 
# ../tests/saw/ir/s2n_drbg.ir 
# ../tests/saw/ir/s2n_fips.ir 
# ../tests/saw/ir/s2n_sequence.ir 
# ../tests/saw/ir/s2n_libcrypto.ir

.PHONY : ir
ir: $(IRS)
	@echo "cyh: in crpto/Makefile, IRS = $(IRS)"
# added by cyh --- end

include ../s2n.mk
