//===-- VC4SelectionDAGInfo.cpp - VideoCore-IV SelectionDAG Info ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the VC4SelectionDAGInfo class.
//
//===----------------------------------------------------------------------===//

#include "VC4TargetMachine.h"
using namespace llvm;

#define DEBUG_TYPE "vc4-selectiondag-info"

VC4SelectionDAGInfo::~VC4SelectionDAGInfo() {}