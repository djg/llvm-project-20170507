//===-- VC4ISelLowering.cpp - VC4 DAG Lowering Implementation ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the VC4TargetLowering class.
//
//===----------------------------------------------------------------------===//

#include "VC4ISelLowering.h"
#include "VC4.h"
//#include "VC4MachineFunctionInfo.h"
#include "VC4Subtarget.h"
#include "VC4TargetMachine.h"
#include "VC4TargetObjectFile.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalAlias.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include <algorithm>

using namespace llvm;

#define DEBUG_TYPE "vc4-lower"

const char *VC4TargetLowering::
getTargetNodeName(unsigned Opcode) const
{
  switch ((VC4ISD::NodeType)Opcode)
  {
    case VC4ISD::FIRST_NUMBER      : break;
    case VC4ISD::BL                : return "VC4ISD::BL";
    case VC4ISD::PCRelativeWrapper : return "VC4ISD::PCRelativeWrapper";
    case VC4ISD::GPRelativeWrapper : return "VC4ISD::GPRelativeWrapper";
    case VC4ISD::RET               : return "VC4ISD::RET";
  }
  return nullptr;
}

VC4TargetLowering::VC4TargetLowering(const TargetMachine &TM,
                                     const VC4Subtarget &Subtarget)
  : TargetLowering(TM), TM(TM), Subtarget(Subtarget) {

}

//===----------------------------------------------------------------------===//
//                      Calling Convention Implementation
//===----------------------------------------------------------------------===//

#include "VC4GenCallingConv.inc"

//===----------------------------------------------------------------------===//
//             Formal Arguments Calling Convention Implementation
//===----------------------------------------------------------------------===//

namespace {
  struct ArgDataPair { SDValue SDV; ISD::ArgFlagsTy Flags; };
}

/// VC4 formal arguments implementation
SDValue
VC4TargetLowering::LowerFormalArguments(
  SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
  const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &dl,
  SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {
  switch (CallConv)
  {
    default:
      llvm_unreachable("Unsupported calling convention");
    case CallingConv::C:
    case CallingConv::Fast:
      // return LowerCCCArguments(Chain, CallConv, isVarArg,
      //                          Ins, dl, DAG, InVals);
      return Chain;
  }
}

SDValue
VC4TargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                               bool isVarArg,
                               const SmallVectorImpl<ISD::OutputArg> &Outs,
                               const SmallVectorImpl<SDValue> &OutVals,
                               const SDLoc &dl, SelectionDAG &DAG) const {
  // TODO:
  return DAG.getNode(VC4ISD::RET, dl, MVT::Other,
                     Chain, DAG.getRegister(VC4::LR, MVT::i32));
}
