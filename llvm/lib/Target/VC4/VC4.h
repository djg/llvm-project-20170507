// -*- C++ -*- //

#ifndef LLVM_LIB_TARGET_VC4_VC4_H
#define LLVM_LIB_TARGET_VC4_VC4_H

#include "MCTargetDesc/VC4MCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class VC4TargetMachine;

FunctionPass* createVC4ISelDag(VC4TargetMachine &TM,
                               CodeGenOpt::Level OL);

} // end namespace llvm

#endif // !LLVM_LIB_TARGET_VC4_VC4_H
