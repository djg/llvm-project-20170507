//===-- VC4TargetMachine.h - Define TargetMachine for VC4 ---*- C++ -*-===//
//
//===------------------------------------------------------------------===//
//
// VideoCore-IV specific subclass of TargetMachine.
//
//===------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_VC4_VC4TARGETMACHINE_H
#define LLVM_LIB_TARGET_VC4_VC4TARGETMACHINE_H

#include "VC4Subtarget.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/ADT/Optional.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Target/TargetMachine.h"
#include <memory>

namespace llvm {

class VC4TargetMachine : public LLVMTargetMachine {
  std::unique_ptr<TargetLoweringObjectFile> TLOF;
  VC4Subtarget Subtarget;

public:
  VC4TargetMachine(const Target& T, const Triple& TT, StringRef CPU,
                   StringRef FS, const TargetOptions& Options,
                   Optional<Reloc::Model> RM, CodeModel::Model CM,
                   CodeGenOpt::Level OL);
  ~VC4TargetMachine() override;

  const VC4Subtarget *getSubtargetImpl() const { return &Subtarget; }
  const VC4Subtarget *getSubtargetImpl(const Function &) const override {
    return &Subtarget;
  }

  // Pass Pipeline Configuration
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

  TargetIRAnalysis getTargetIRAnalysis() override;
  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }
};

} // namespace llvm

#endif // !LLVM_LIB_TARGET_VC4_VC4TARGETMACHINE_H
