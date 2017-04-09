//===-- VC4ISelLowering.h - VideoCore-IV DAG Lowering Interface -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that VC4 uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_VC4_VC4ISELLOWERING_H
#define LLVM_LIB_TARGET_VC4_VC4ISELLOWERING_H

#include "VC4.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/Target/TargetLowering.h"

namespace llvm {

  // Forward delcarations
  class VC4Subtarget;
  class VC4TargetMachine;

  namespace VC4ISD {
    enum NodeType : unsigned {
      // Start the numbering where the builtin ops and target ops leave off.
      FIRST_NUMBER = ISD::BUILTIN_OP_END,

      // Branch and link (call)
      BL,

      // pc relative address
      PCRelativeWrapper,

      // gp relative address
      GPRelativeWrapper,

      // Ret
      RET,
    };
  }

  //===--------------------------------------------------------------------===//
  // TargetLowering Implementation
  //===--------------------------------------------------------------------===//
  class VC4TargetLowering : public TargetLowering
  {
  public:
    explicit VC4TargetLowering(const TargetMachine &TM,
                               const VC4Subtarget &Subtarget);

    /// getTargetNodeName - This method returns the name of a target specific
    //  DAG node.
    const char *getTargetNodeName(unsigned Opcode) const override;

  private:
    const TargetMachine &TM;
    const VC4Subtarget &Subtarget;

    SDValue
    LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                         const SmallVectorImpl<ISD::InputArg> &Ins,
                         const SDLoc &dl, SelectionDAG &DAG,
                         SmallVectorImpl<SDValue> &InVals) const override;

    SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                        const SmallVectorImpl<ISD::OutputArg> &Outs,
                        const SmallVectorImpl<SDValue> &OutVals,
                        const SDLoc &dl, SelectionDAG &DAG) const override;
  };
} // end namespace llvm

#endif
