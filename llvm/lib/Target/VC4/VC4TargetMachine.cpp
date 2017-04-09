//===-- VC4TargetMachine.cpp - Define TargetMachine for VC4 -----------===//
//
//===------------------------------------------------------------------===//

#include "MCTargetDesc/VC4MCTargetDesc.h"
#include "VC4.h"
#include "VC4TargetMachine.h"
#include "VC4TargetObjectFile.h"
#include "VC4TargetTransformInfo.h"
#include "llvm/ADT/Optional.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "vc4"

static Reloc::Model getEffectiveRelocModel(Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

/// Create an ILP32 architecture model
///
VC4TargetMachine::VC4TargetMachine(const Target &T, const Triple &TT,
                                   StringRef CPU, StringRef FS,
                                   const TargetOptions &Options,
                                   Optional<Reloc::Model> RM,
                                   CodeModel::Model CM,
                                   CodeGenOpt::Level OL)
  : LLVMTargetMachine(
      T, "e-m:e-p:32:32-i1:8:32-i8:8:32-i16:16:16:32-f32:32-a:0:32-n32",
      TT, CPU, FS, Options, getEffectiveRelocModel(RM), CM, OL),
    TLOF(llvm::make_unique<VC4TargetObjectFile>()),
    Subtarget(TT, CPU, FS, *this) {
}

VC4TargetMachine::~VC4TargetMachine() = default;

namespace {

class VC4PassConfig : public TargetPassConfig {
public:
  VC4PassConfig(VC4TargetMachine *TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {}

  VC4TargetMachine &getVC4TargetMachine() const {
    return getTM<VC4TargetMachine>();
  }
};

} // end anonymous namespace

TargetPassConfig*
VC4TargetMachine::createPassConfig(PassManagerBase &PM) {
  return new VC4PassConfig(this, PM);
}

extern "C" void LLVMInitializeVC4Target() {
  // Register the target.
  RegisterTargetMachine<VC4TargetMachine> X(getTheVC4Target());
}

TargetIRAnalysis
VC4TargetMachine::getTargetIRAnalysis() {
  return TargetIRAnalysis([this](const Function &F) {
      return TargetTransformInfo(VC4TTIImpl(this, F));
  });
}
