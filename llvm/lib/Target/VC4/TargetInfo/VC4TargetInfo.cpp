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
  RegisterTarget<Triple::vc4, /*HasJIT=*/false> X(getTheVC4Target(), "vc4", "VideoCore IV");
}
