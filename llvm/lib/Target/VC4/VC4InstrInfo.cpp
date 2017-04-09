//===-- VC4InstrInfo.cpp - VC4 Instruction Information ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the VC4 implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "VC4InstrInfo.h"
#include "VC4.h"
#include "VC4MachineFunctionInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/MC/MCContext.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "VC4GenInstrInfo.inc"

// Pin the vtable to this file.
void VC4InstrInfo::anchor() {}

VC4InstrInfo::VC4InstrInfo()
  : VC4GenInstrInfo(VC4::ADJCALLSTACKDOWN, VC4::ADJCALLSTACKUP),
    RI() {
}

/// isLoadFromStackSlot - If the specified machine instruction is a direct
/// load from a stack slot, return the virtual or physical register number of
/// the destination along with the FrameIndex of the loaded stack slot.  If
/// not, return 0.  This predicate must return 0 if the instruction has
/// any side effects other than loading from the stack slot.
unsigned
VC4InstrInfo::isLoadFromStackSlot(const MachineInstr &MI,
                                  int &FrameIndex) const {
  // TODO:
  // int Opcode = MI.getOpcode();
  // if (Opcode == VC4::LDWFI)
  // {
  //   if ((MI.getOperand(1).isFI()) &&  // is a stack slot
  //       (MI.getOperand(2).isImm()) && // the imm is zero
  //       (isZeroImm(MI.getOperand(2)))) {
  //     FrameIndex = MI.getOperand(1).getIndex();
  //     return MI.getOperand(0).getReg();
  //   }
  // }
  return 0;
}

/// isStoreToStackSlot - If the specified machine instruction is a direct
/// store to a stack slot, return the virtual or physical register number of
/// the source reg along with the FrameIndex of the loaded stack slot.  If
/// not, return 0.  This predicate must return 0 if the instruction has
/// any side effects other than storing to the stack slot.
unsigned
VC4InstrInfo::isStoreToStackSlot(const MachineInstr &MI,
                                 int &FrameIndex) const {
  // TODO:
  // int Opcode = MI.getOpcode();
  // if (Opcode == VC4::STWFI)
  // {
  //   if ((MI.getOperand(1).isFI()) &&  // is a stack slot
  //       (MI.getOperand(2).isImm()) && // the imm is zero
  //       (isZeroImm(MI.getOperand(2)))) {
  //     FrameIndex = MI.getOperand(1).getIndex();
  //     return MI.getOperand(0).getReg();
  //   }
  // }
  return 0;
}
