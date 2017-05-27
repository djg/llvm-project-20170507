//===-- VC4SelectionDAGInfo.h - VideoCore-IV SelectionDAG Info --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the VC4 subclass for SelectionDAGTargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_VC4_VC4SELECTIONDAGINFO_H
#define LLVM_LIB_TARGET_VC4_VC4SELECTIONDAGINFO_H

#include "llvm/CodeGen/SelectionDAGTargetInfo.h"

namespace llvm {

class VC4SelectionDAGInfo : public SelectionDAGTargetInfo {
public:
  ~VC4SelectionDAGInfo();
};

}

#endif
