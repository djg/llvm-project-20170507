//===-- VC4Subtarget.cpp - VideoCore-IVe Subtarget Information ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the VC4 specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "VC4Subtarget.h"
#include "VC4.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "xcore-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "VC4GenSubtargetInfo.inc"

void VC4Subtarget::anchor() { }

VC4Subtarget::VC4Subtarget(const Triple &TT, const std::string &CPU,
                           const std::string &FS, const TargetMachine &TM)
  : VC4GenSubtargetInfo(TT, CPU, FS)
  , VC4ArchVersion(VC4Default)
  , InstrInfo()
  , FrameLowering(*this)
  , TLInfo(TM, *this)
  , TSInfo() {

  if (VC4ArchVersion == VC4Default)
    VC4ArchVersion = VPU;

  // Don't even attempt to generate code for QPU.
  if (VC4ArchVersion == QPU)
    report_fatal_error("Code generation for QPU is not implemented", false);
}
