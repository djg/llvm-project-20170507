//=== -*- C++ -*- ===//

#ifndef LLVM_LIB_TARGET_VC4_VC4TARGETOBJECTFILE_H
#define LLVM_LIB_TARGET_VC4_VC4TARGETOBJECTFILE_H

#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

namespace llvm {
  class VC4TargetMachine;

  class VC4TargetObjectFile : public TargetLoweringObjectFileELF {
    MCSection* SmallDataSection;
    MCSection* SmallBSSSection;
    const VC4TargetMachine* TM;

  public:
    void Initialize(MCContext& Ctx, const TargetMachine& TM) override;
  };
} // end namespace llvm

#endif // !LLVM_LIB_TARGET_VC4_VC4TARGETOBJECTFILE_H
