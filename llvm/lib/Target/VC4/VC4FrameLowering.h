//===-- VC4FrameLowering.h - Frame info for VideoCore-IV Target -*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_VC4_VC4FRAMELOWERING_H
#define LLVM_LIB_TARGET_VC4_VC4FRAMELOWERING_H

#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
  class VC4Subtarget;

  class VC4FrameLowering: public TargetFrameLowering {
  public:
    VC4FrameLowering(const VC4Subtarget &STI);

    /// emitProlog/emitEpilog - These methods insert prolog and epilog code into the function.
    void emitPrologue(MachineFunction &MF,
                      MachineBasicBlock &MBB) const override;
    void emitEpilogue(MachineFunction &MF,
                      MachineBasicBlock &MBB) const override;
    bool hasFP(const MachineFunction &MF) const override;
  };
}

#endif
