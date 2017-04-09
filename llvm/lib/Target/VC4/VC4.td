include "llvm/Target/Target.td"

// Register File, Calling Conv, Instruction Desciptions

include "VC4RegisterInfo.td"
include "VC4InstrInfo.td"
include "VC4CallingConv.td"

def VC4InstrInfo : InstrInfo;

// VC4 Subtarget features

// Asm Parser
//def VC4AsmParser : AsmParser {
//}

//===----------------------------------------------------------------------===//
//  Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def VC4 : Target {
  let InstructionSet = VC4InstrInfo;
}
