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

#define DEBUG_TYPE "xcore-reg-info"

#define GET_REGINFO_TARGET_DESC
#include "VC4GenRegisterInfo.inc"

VC4RegisterInfo::VC4RegisterInfo()
  : VC4GenRegisterInfo(VC4::LR) {
}

// TODO:
#if 0
// helper functions
static inline bool isImmUs(unsigned val) {
  return val <= 11;
}

static inline bool isImmU6(unsigned val) {
  return val < (1 << 6);
}

static inline bool isImmU16(unsigned val) {
  return val < (1 << 16);
}


static void InsertFPImmInst(MachineBasicBlock::iterator II,
                            const VC4InstrInfo &TII,
                            unsigned Reg, unsigned FrameReg, int Offset ) {
  MachineInstr &MI = *II;
  MachineBasicBlock &MBB = *MI.getParent();
  DebugLoc dl = MI.getDebugLoc();

  switch (MI.getOpcode()) {
  case VC4::LDWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::LDW_2rus), Reg)
          .addReg(FrameReg)
          .addImm(Offset)
          .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::STWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::STW_2rus))
          .addReg(Reg, getKillRegState(MI.getOperand(0).isKill()))
          .addReg(FrameReg)
          .addImm(Offset)
          .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::LDAWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::LDAWF_l2rus), Reg)
          .addReg(FrameReg)
          .addImm(Offset);
    break;
  default:
    llvm_unreachable("Unexpected Opcode");
  }
}

static void InsertFPConstInst(MachineBasicBlock::iterator II,
                              const VC4InstrInfo &TII,
                              unsigned Reg, unsigned FrameReg,
                              int Offset, RegScavenger *RS ) {
  assert(RS && "requiresRegisterScavenging failed");
  MachineInstr &MI = *II;
  MachineBasicBlock &MBB = *MI.getParent();
  DebugLoc dl = MI.getDebugLoc();
  unsigned ScratchOffset = RS->scavengeRegister(&VC4::GRRegsRegClass, II, 0);
  RS->setRegUsed(ScratchOffset);
  TII.loadImmediate(MBB, II, ScratchOffset, Offset);

  switch (MI.getOpcode()) {
  case VC4::LDWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::LDW_3r), Reg)
          .addReg(FrameReg)
          .addReg(ScratchOffset, RegState::Kill)
          .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::STWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::STW_l3r))
          .addReg(Reg, getKillRegState(MI.getOperand(0).isKill()))
          .addReg(FrameReg)
          .addReg(ScratchOffset, RegState::Kill)
          .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::LDAWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::LDAWF_l3r), Reg)
          .addReg(FrameReg)
          .addReg(ScratchOffset, RegState::Kill);
    break;
  default:
    llvm_unreachable("Unexpected Opcode");
  }
}

static void InsertSPImmInst(MachineBasicBlock::iterator II,
                            const VC4InstrInfo &TII,
                            unsigned Reg, int Offset) {
  MachineInstr &MI = *II;
  MachineBasicBlock &MBB = *MI.getParent();
  DebugLoc dl = MI.getDebugLoc();
  bool isU6 = isImmU6(Offset);

  switch (MI.getOpcode()) {
  int NewOpcode;
  case VC4::LDWFI:
    NewOpcode = (isU6) ? VC4::LDWSP_ru6 : VC4::LDWSP_lru6;
    BuildMI(MBB, II, dl, TII.get(NewOpcode), Reg)
          .addImm(Offset)
          .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::STWFI:
    NewOpcode = (isU6) ? VC4::STWSP_ru6 : VC4::STWSP_lru6;
    BuildMI(MBB, II, dl, TII.get(NewOpcode))
          .addReg(Reg, getKillRegState(MI.getOperand(0).isKill()))
          .addImm(Offset)
          .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::LDAWFI:
    NewOpcode = (isU6) ? VC4::LDAWSP_ru6 : VC4::LDAWSP_lru6;
    BuildMI(MBB, II, dl, TII.get(NewOpcode), Reg)
          .addImm(Offset);
    break;
  default:
    llvm_unreachable("Unexpected Opcode");
  }
}

static void InsertSPConstInst(MachineBasicBlock::iterator II,
                                const VC4InstrInfo &TII,
                                unsigned Reg, int Offset, RegScavenger *RS ) {
  assert(RS && "requiresRegisterScavenging failed");
  MachineInstr &MI = *II;
  MachineBasicBlock &MBB = *MI.getParent();
  DebugLoc dl = MI.getDebugLoc();
  unsigned OpCode = MI.getOpcode();

  unsigned ScratchBase;
  if (OpCode==VC4::STWFI) {
    ScratchBase = RS->scavengeRegister(&VC4::GRRegsRegClass, II, 0);
    RS->setRegUsed(ScratchBase);
  } else
    ScratchBase = Reg;
  BuildMI(MBB, II, dl, TII.get(VC4::LDAWSP_ru6), ScratchBase).addImm(0);
  unsigned ScratchOffset = RS->scavengeRegister(&VC4::GRRegsRegClass, II, 0);
  RS->setRegUsed(ScratchOffset);
  TII.loadImmediate(MBB, II, ScratchOffset, Offset);

  switch (OpCode) {
  case VC4::LDWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::LDW_3r), Reg)
          .addReg(ScratchBase, RegState::Kill)
          .addReg(ScratchOffset, RegState::Kill)
          .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::STWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::STW_l3r))
          .addReg(Reg, getKillRegState(MI.getOperand(0).isKill()))
          .addReg(ScratchBase, RegState::Kill)
          .addReg(ScratchOffset, RegState::Kill)
          .addMemOperand(*MI.memoperands_begin());
    break;
  case VC4::LDAWFI:
    BuildMI(MBB, II, dl, TII.get(VC4::LDAWF_l3r), Reg)
          .addReg(ScratchBase, RegState::Kill)
          .addReg(ScratchOffset, RegState::Kill);
    break;
  default:
    llvm_unreachable("Unexpected Opcode");
  }
}
#endif

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
  // TODO:
#if 0
  assert(SPAdj == 0 && "Unexpected");
  MachineInstr &MI = *II;
  MachineOperand &FrameOp = MI.getOperand(FIOperandNum);
  int FrameIndex = FrameOp.getIndex();

  MachineFunction &MF = *MI.getParent()->getParent();
  const VC4InstrInfo &TII =
      *static_cast<const VC4InstrInfo *>(MF.getSubtarget().getInstrInfo());

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
  Offset/=4;

  unsigned Reg = MI.getOperand(0).getReg();
  assert(VC4::GRRegsRegClass.contains(Reg) && "Unexpected register operand");

  if (TFI->hasFP(MF)) {
    if (isImmUs(Offset))
      InsertFPImmInst(II, TII, Reg, FrameReg, Offset);
    else
      InsertFPConstInst(II, TII, Reg, FrameReg, Offset, RS);
  } else {
    if (isImmU16(Offset))
      InsertSPImmInst(II, TII, Reg, Offset);
    else
      InsertSPConstInst(II, TII, Reg, Offset, RS);
  }
  // Erase old instruction.
  MachineBasicBlock &MBB = *MI.getParent();
  MBB.erase(II);
#endif
}


unsigned VC4RegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const VC4FrameLowering *TFI = getFrameLowering(MF);
  return TFI->hasFP(MF) ? VC4::R23 : VC4::SP;
}
