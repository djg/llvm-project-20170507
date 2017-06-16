//===-- VC4RegisterInfo.cpp - VC4 Register Information ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the VC4 implementation of the MRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "VC4RegisterInfo.h"
#include "VC4.h"
#include "VC4InstrInfo.h"
#include "VC4MachineFunctionInfo.h"
#include "VC4Subtarget.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

#define DEBUG_TYPE "vc4-reg-info"

#define GET_REGINFO_TARGET_DESC
#include "VC4GenRegisterInfo.inc"

VC4RegisterInfo::VC4RegisterInfo()
  : VC4GenRegisterInfo(VC4::LR) {
}

enum {
  Imm5,
  Imm16,
  Imm27,
};

static int LDWSPOpcode(unsigned Size) {
  switch (Size) {
    default:
      llvm_unreachable("Invalid Size");
    case Imm5:
      return VC4::LDWSP_1r4o7;
    case Imm16:
      return VC4::LDWSP_1r5o16;
    case Imm27:
      return VC4::LDWSP_1r5o27;
  }
}

static int STWSPOpcode(unsigned Size) {
  switch (Size) {
    default:
      llvm_unreachable("Invalid Size");
    case Imm5:
      return VC4::STWSP_1r4o7;
    case Imm16:
      return VC4::STWSP_1r5o16;
    case Imm27:
      return VC4::STWSP_1r5o27;
  }
}

// helper functions
static void
InsertSPImmInst(MachineBasicBlock::iterator II,
                const VC4InstrInfo &TII,
                unsigned Reg, unsigned Offset, unsigned Size) {
  MachineInstr &MI = *II;
  MachineBasicBlock &MBB = *MI.getParent();
  DebugLoc dl = MI.getDebugLoc();

  switch (MI.getOpcode()) {
    int NewOpcode;
  default:
    llvm_unreachable("Unexpected Opcode");
  case VC4::LDWFI:
    NewOpcode = LDWSPOpcode(Size);
    BuildMI(MBB, II, dl, TII.get(NewOpcode), Reg)
      .addImm(Offset)
      .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::STWFI:
    NewOpcode = STWSPOpcode(Size);
    BuildMI(MBB, II, dl, TII.get(NewOpcode))
      .addReg(Reg, getKillRegState(MI.getOperand(0).isKill()))
      .addImm(Offset)
      .addMemOperand(*MI.memoperands_begin());
    break;
  }
}

bool VC4RegisterInfo::needsFrameMoves(const MachineFunction &MF) {
  return MF.getMMI().hasDebugInfo() ||
    MF.getFunction()->needsUnwindTableEntry();
}

const MCPhysReg *
VC4RegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  // The callee saved registers LR & FP are explicitly handled during
  // emitPrologue & emitEpilogue and related functions.
  static const MCPhysReg CalleeSavedRegs[] = {
    VC4::R6, VC4::R7, VC4::R8, VC4::R9, VC4::R10, VC4::R11, VC4::R12, VC4::R13, VC4::R14, VC4::R15,
    VC4::R16, VC4::R17, VC4::R18, VC4::R19, VC4::R20, VC4::R21, VC4::R22, VC4::R23,
    0
  };

  static const MCPhysReg CalleeSavedRegsFP[] = {
    VC4::R6, VC4::R7, VC4::R8, VC4::R9, VC4::R10, VC4::R11, VC4::R12, VC4::R13, VC4::R14, VC4::R15,
    VC4::R16, VC4::R17, VC4::R18, VC4::R19, VC4::R20, VC4::R21, VC4::R22,
    0
  };

  const VC4FrameLowering *TFI = getFrameLowering(*MF);
  if (TFI->hasFP(*MF))
    return CalleeSavedRegsFP;
  return CalleeSavedRegs;
}

BitVector VC4RegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  const VC4FrameLowering *TFI = getFrameLowering(MF);

  Reserved.set(VC4::GP);
  Reserved.set(VC4::SP);
  Reserved.set(VC4::LR);
  Reserved.set(VC4::TP);
  if (TFI->hasFP(MF)) {
    Reserved.set(VC4::R23);
  }
  return Reserved;
}

bool
VC4RegisterInfo::requiresRegisterScavenging(const MachineFunction &MF) const {
  return true;
}

bool
VC4RegisterInfo::trackLivenessAfterRegAlloc(const MachineFunction &MF) const {
  return true;
}

bool
VC4RegisterInfo::useFPForScavengingIndex(const MachineFunction &MF) const {
  return false;
}

void
VC4RegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                     int SPAdj, unsigned FIOperandNum,
                                     RegScavenger *RS) const {
  DEBUG(dbgs() << "VC4RegisterInfo::eliminateFrameIndex(II, SPAdj=" << SPAdj <<
        ", FIOperandNum=" << FIOperandNum <<
        ", RegScavenger=" << RS << ")\n");

  assert(SPAdj == 0 && "Unexpected");
  MachineInstr &MI = *II;
  MachineOperand &FrameOp = MI.getOperand(FIOperandNum);
  int FrameIndex = FrameOp.getIndex();

  MachineFunction &MF = *MI.getParent()->getParent();
  const VC4InstrInfo &TII = *static_cast<const VC4InstrInfo *>(MF.getSubtarget().getInstrInfo());

  const VC4FrameLowering *TFI = getFrameLowering(MF);
  int Offset = MF.getFrameInfo().getObjectOffset(FrameIndex);
  int StackSize = MF.getFrameInfo().getStackSize();

#ifndef NDEBUG
  DEBUG(errs() << "\nFunction         : "
        << MF.getName() << "\n");
  DEBUG(errs() << "<--------->\n");
  DEBUG(MI.print(errs()));
  DEBUG(errs() << "FrameIndex         : " << FrameIndex << "\n");
  DEBUG(errs() << "FrameOffset        : " << Offset << "\n");
  DEBUG(errs() << "StackSize          : " << StackSize << "\n");
#endif

  Offset += StackSize;

  unsigned FrameReg = getFrameRegister(MF);

  // Special handling of DBG_VALUE instructions.
  if (MI.isDebugValue()) {
    MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false /*isDef*/);
    MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
    return;
  }

  // fold constant into offset.
  Offset += MI.getOperand(FIOperandNum + 1).getImm();
  MI.getOperand(FIOperandNum + 1).ChangeToImmediate(0);

  assert(Offset%4 == 0 && "Misaligned stack offset");
  DEBUG(errs() << "Offset             : " << Offset << "\n" << "<--------->\n");

  unsigned Reg = MI.getOperand(0).getReg();
  bool IsGReg = VC4::GRegsRegClass.contains(Reg);

  if (TFI->hasFP(MF)) {
    /*    if (isImmUs(Offset))
      InsertFPImmInst(II, TII, Reg, FrameReg, Offset);
    else
      InsertFPConstInst(II, TII, Reg, FrameReg, Offset, RS);
    */
    llvm_unreachable("Frame Pointer not supported");
  } else { // SP relative
    unsigned Size = 0;
    if (IsGReg && isShiftedUInt<5,2>(Offset)) {
      Offset /= 4;
      Size = Imm5;
    } else if (isInt<16>(Offset)) {
      Size = Imm16;
    } else if (isInt<27>(Offset)) {
      Size = Imm27;
    } else {
      llvm_unreachable("Stack Offset is too large!");
    }
    InsertSPImmInst(II, TII, Reg, Offset, Size);
  }

  // Erase old instruction.
  MachineBasicBlock &MBB = *MI.getParent();
  MBB.erase(II);
}

unsigned VC4RegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const VC4FrameLowering *TFI = getFrameLowering(MF);
  return TFI->hasFP(MF) ? VC4::R23 : VC4::SP;
}
