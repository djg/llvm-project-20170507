//===-- VC4FrameLowering.cpp - Frame info for VideoCore-IV Target ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains XCore frame information that doesn't fit anywhere else
// cleanly...
//
//===----------------------------------------------------------------------===//

#include "VC4FrameLowering.h"
#include "VC4.h"
#include "VC4InstrInfo.h"
#include "VC4MachineFunctionInfo.h"
#include "VC4Subtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/Target/TargetOptions.h"
#include <algorithm>    // std::sort

using namespace llvm;

#define DEBUG_TYPE "vc4-frame-lowering"

//===----------------------------------------------------------------------===//
// VC4FrameLowering:
//===----------------------------------------------------------------------===//

VC4FrameLowering::VC4FrameLowering(const VC4Subtarget &sti)
  : TargetFrameLowering(TargetFrameLowering::StackGrowsDown, 4, 0) {
  // Do nothing
}

void
VC4FrameLowering::emitPrologue(MachineFunction &MF,
                               MachineBasicBlock &MBB) const {
  DEBUG(dbgs() << "VC4FrameLowering::emitPrologue\n");
  DEBUG(MF.dump());
  DEBUG(MBB.dump());
}

void
VC4FrameLowering::emitEpilogue(MachineFunction &MF,
                               MachineBasicBlock &MBB) const {
  DEBUG(dbgs() << "VC4FrameLowering::emitEpilogue\n");
  DEBUG(MF.dump());
  DEBUG(MBB.dump());
}

bool
VC4FrameLowering::hasFP(const MachineFunction &MF) const {
  return MF.getTarget().Options.DisableFramePointerElim(MF) ||
         MF.getFrameInfo().hasVarSizedObjects();
}

