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

// Forward declarations
class VC4Subtarget;
class VC4TargetMachine;

namespace VC4ISD {
  enum NodeType  {
    // Start the numbering where the builtin ops and target ops leave off.
    FIRST_NUMBER = ISD::BUILTIN_OP_END,

    // PC relative address
    PC_RELATIVE,

    // GP relative address
    GP_RELATIVE,

    // R0 relative address
    R0_RELATIVE,

    // Load word from stack
    LDWSP,

    // Store word to stack
    STWSP,

    CALL,         // Branch and Link (call)
    CALL_NOLINK,  // Function all with branch not branch-and-link.
    RET_FLAG,
  };
}

//===----------------------------------------------------------------------===//
// TargetLowering Implementation
//===----------------------------------------------------------------------===//
class VC4TargetLowering : public TargetLowering {
public:
  explicit VC4TargetLowering(const TargetMachine &TM,
                             const VC4Subtarget &Subtarget);

  /// LowerOperation - Provide custom lowering hooks for some operations.
  virtual SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

  /// getTargetNodeName - This method returns the name of a target specific
  /// DAG node.
  virtual const char *getTargetNodeName(unsigned Opcode) const override;

private:
  const VC4Subtarget &Subtarget;

  SDValue LowerFormalArguments(SDValue Chain,
                               CallingConv::ID CallConv,
                               bool isVarArg,
                               const SmallVectorImpl<ISD::InputArg> &Ins,
                               const SDLoc &dl,
                               SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) const override;

  SDValue LowerCall(TargetLowering::CallLoweringInfo &CLI,
                    SmallVectorImpl<SDValue>& InVals) const override;

  SDValue LowerReturn(SDValue Chain,
                      CallingConv::ID CallConv,
                      bool isVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &Outs,
                      const SmallVectorImpl<SDValue> &OutVals,
                      const SDLoc &dl,
                      SelectionDAG &DAG) const override;

  SDValue LowerCallResult(SDValue Chain,
                          SDValue InGlue,
                          CallingConv::ID CallConv,
                          bool isVarArg,
                          const SmallVectorImpl<ISD::InputArg> &Ins,
                          const SDLoc& dl,
                          SelectionDAG &DAG,
                          SmallVectorImpl<SDValue> &InVals) const;

  bool CanLowerReturn(CallingConv::ID CallConv,
                      MachineFunction &MF,
                      bool isVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &Outs,
                      LLVMContext &Context) const override;

  // LowerGlobalAddress - Emit a constant load to the global address.
  SDValue LowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
};

} // end namespace llvm

#endif
