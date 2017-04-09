//===- VC4MachineFunctionInfo.h - VC4 machine function info -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares XCore-specific per-machine-function information.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_VC4_VC4MACHINEFUNCTIONINFO_H
#define LLVM_LIB_TARGET_VC4_VC4MACHINEFUNCTIONINFO_H

#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include <cassert>
#include <utility>
#include <vector>

namespace llvm {

/// VC4FunctionInfo - This class is derived from MachineFunction private
/// VC4 target-specific information for each MachineFunction.
class VC4FunctionInfo : public MachineFunctionInfo {
  int VarArgsFrameIndex = 0;

  virtual void anchor();

public:
  VC4FunctionInfo() = default;

  explicit VC4FunctionInfo(MachineFunction &MF) {}

  ~VC4FunctionInfo() override;

  void setVarArgsFrameIndex(int off) { VarArgsFrameIndex = off; }
  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
};

} // end namespace llvm

#endif
