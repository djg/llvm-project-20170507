// -*- C++ -*- //

#ifndef LLVM_LIB_TARGET_VC4_MCTARGETDESC_VC4MCTARGETDESC_H
#define LLVM_LIB_TARGET_VC4_MCTARGETDESC_VC4MCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

namespace llvm {

class Target;

Target& getTheVC4Target();

} // namespace llvm

#define GET_REGINFO_ENUM
#include "VC4GenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#include "VC4GenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "VC4GenSubtargetInfo.inc"

#endif // !LLVM_LIB_TARGET_VC4_MCTARGETDESC_VC4MCTARGETDESC_H

