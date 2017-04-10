// -*- C++ -*- //

#ifndef LLVM_LIB_TARGET_VC4_MCTARGETDESC_VC4MCTARGETDESC_H
#define LLVM_LIB_TARGET_VC4_MCTARGETDESC_VC4MCTARGETDESC_H

namespace llvm {

class Target;

Target& getTheVC4Target();

} // namespace llvm

#define GET_REGINFO_ENUM
#include "VC4GenRegisterInfo.inc"

// Defines symbolic names for the VC4 instructions.
//
#define GET_INSTRINFO_ENUM
#include "VC4GenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "VC4GenSubtargetInfo.inc"

#endif
