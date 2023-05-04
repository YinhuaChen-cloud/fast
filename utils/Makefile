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

BCS_1=$(SRCS:.c=.bc)
BCS=$(addprefix $(BITCODE_DIR), $(BCS_1))

.PHONY : all
all: $(OBJS)

.PHONY : bc
bc: $(BCS)

# added by cyh --- start
IR_DIR?=../tests/saw/ir/

IRS_1=$(SRCS:.c=.ir)
IRS=$(addprefix $(IR_DIR), $(IRS_1))

.PHONY : ir
ir: $(IRS)
	@echo "cyh: in utils/Makefile, IRS = $(IRS)"
# added by cyh --- end

include ../s2n.mk
