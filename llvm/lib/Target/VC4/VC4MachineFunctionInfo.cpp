//===-- VC4MachineFunctionInfo.cpp - VideoCore-IV machine function info ---===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "VC4MachineFunctionInfo.h"
#include "VC4InstrInfo.h"
#include "llvm/IR/Function.h"

using namespace llvm;

void VC4FunctionInfo::anchor() { }

VC4FunctionInfo::~VC4FunctionInfo() = default;
