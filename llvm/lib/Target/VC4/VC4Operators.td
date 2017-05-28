//===-- VC4Operators.td - VideoCore-IV-specific operators ---*- tablegen-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Type profiles
//===----------------------------------------------------------------------===//
def MoveImm32Ty : SDTypeProfile<1, 1, [ SDTCisSameAs<0, 1>, SDTCisInt<0>]>;

def VC4RetFlag : SDNode<"VC4ISD::RET_FLAG", SDTNone,
                        [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

//===----------------------------------------------------------------------===//
// Custom SDNodes
//===----------------------------------------------------------------------===//

def VC4MoveI32 : SDNode<"VC4ISD::MOVE_I32", MoveImm32Ty>;