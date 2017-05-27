//===-------------------------------------------------------*- tablegen -*-===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Register File, Calling Conv, Instruction Desciptions
//===----------------------------------------------------------------------===//

include "VC4RegisterInfo.td"
include "VC4InstrInfo.td"
include "VC4CallingConv.td"

def VC4InstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// VideoCore-IV processors supported.
//===----------------------------------------------------------------------===//

def FeatureVPU : SubtargetFeature<"vpu", "VC4ArchVersion",
                                  "VPU", "VideoCore-IV VPU Support",
                                  []>;
def FeatureQPU : SubtargetFeature<"qpu", "VC4ArchVersion",
                                  "QPU", "VideoCore-IV QPU Support",
                                  []>;

class Proc<string Name, list<SubtargetFeature> Features>
  : Processor<Name, NoItineraries, Features>;

def : Proc<"vpu", [FeatureVPU]>;
def : Proc<"qpu", [FeatureQPU]>;

//===----------------------------------------------------------------------===//
//  Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def VC4 : Target {
  let InstructionSet = VC4InstrInfo;
}
