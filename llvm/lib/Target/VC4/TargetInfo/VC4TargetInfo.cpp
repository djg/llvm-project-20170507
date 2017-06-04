//===-- VC4TargetInfo.cpp - VC4 Target Implementation ---------------------===//

#include "VC4.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

Target&
llvm::getTheVC4Target() {
  static Target TheVC4Target;
  return TheVC4Target;
}

extern "C"
void LLVMInitializeVC4TargetInfo() {
  // Broadcom VideoCore III matches the description returned by readelf
  RegisterTarget<Triple::videocore3, /*HasJIT=*/false> X(getTheVC4Target(), "vc3", "Broadcom VideoCore III");
}
