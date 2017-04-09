//===-- VC4TargetTransformInfo.h - VC4 specific TTI ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// This file a TargetTransformInfo::Concept conforming object specific to the
/// VC4 target machine. It uses the target's detailed information to
/// provide more precise answers to certain TTI queries, while letting the
/// target independent and default TTI implementations handle the rest.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_VC4_VC4TARGETTRANSFORMINFO_H
#define LLVM_LIB_TARGET_VC4_VC4TARGETTRANSFORMINFO_H

#include "VC4.h"
#include "VC4TargetMachine.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/BasicTTIImpl.h"
#include "llvm/Target/TargetLowering.h"

namespace llvm {

class VC4TTIImpl : public BasicTTIImplBase<VC4TTIImpl> {
  typedef BasicTTIImplBase<VC4TTIImpl> BaseT;
  typedef TargetTransformInfo TTI;
  friend BaseT;

  const VC4Subtarget *ST;
  const VC4TargetLowering *TLI;

  const VC4Subtarget *getST() const { return ST; }
  const VC4TargetLowering *getTLI() const { return TLI; }

public:
  explicit VC4TTIImpl(const VC4TargetMachine *TM, const Function &F)
    : BaseT(TM, F.getParent()->getDataLayout()), ST(TM->getSubtargetImpl()),
      TLI(ST->getTargetLowering()) {}

  unsigned getNumberOfRegisters(bool Vector) {
    if (Vector) {
      return 0;
    }
    return 24;
  }
};

} // end namespace llvm

#endif
