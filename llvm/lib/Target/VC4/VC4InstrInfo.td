// -*- tablegen -*- //

// Instruction format superclass

include "VC4InstrFormats.td"

//===----------------------------------------------------------------------===//
// Instruction Pattern Stuff
//===----------------------------------------------------------------------===//

def div2 : SDNodeXForm<imm, [{
  // Transform: imm/2
  assert(N->getSExtValue() % 2 == 0);
  return getI32Imm(N->getSExtValue()/2, SDLoc(N));
}]>;

def div4 : SDNodeXForm<imm, [{
  // Transform: imm/4
  assert(N->getSExtValue() % 4 == 0);
  return getI32Imm(N->getSExtValue()/4, SDLoc(N));
}]>;

def u6imm : PatLeaf<(imm), [{ return isInt<6>(N->getZExtValue()); }]>;

// Instruction operand types
def U6ImmOp : Operand<i32> {
  let DecoderMethod = "DecodeU6Imm";
}

def S5ImmOp : Operand<i32> {
  let DecoderMethod = "DecodeS6Imm";
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

// No operands
def BKPT : S16_0<0b0000, "bkpt", []>;
def NOP : S16_0<0b0001, "nop", []>;
def SLEEP : S16_0<0b0010, "sleep", []>;
def USER  : S16_0<0b0011, "user", []>;
def EI    : S16_0<0b0100, "ei", []>;
def DI    : S16_0<0b0101, "di", []>;
def CBCLR : S16_0<0b0110, "cbclr", []>;
def CBADD1 : S16_0<0b0111, "cbadd1", []>;
def CBADD2 : S16_0<0b1000, "cdadd2", []>;
def CBADD3 : S16_0<0b1001, "cdadd3", []>;
def RTI    : S16_0<0b1010, "rti", []>;

// Software Interrupt - Raise 0x20+(rd & 0x1f)
def SWIrd : S16_rd5_1<(outs), (ins ERegs:$rd), 0b001, "swi $rd", []>;
def SWIu  : S16_swi<(outs), (ins U6ImmOp:$u), "swi $u", []>;

// Unconditional branch
let isBranch = 1, isIndirectBranch=1, isTerminator=1, isBarrier=1 in
def B  : S16_rd5_1<(outs), (ins ERegs:$rd), 0b010, "b $rd", []>;

let isCall=1, Defs = [R0, R1, R2, R3, R4, R5, LR] in
def BL : S16_rd5_1<(outs), (ins ERegs:$rd), 0b011, "bl $rd", []>;

// Jump table
//todo:-)

// Version
def VERSION : S16_rd5_1<(outs ERegs:$rd), (ins), 0b111, "version $rd", []>;

// Memory Operations

let mayLoad=1, hasExtraDefRegAllocReq=1 in {
def LDM : S16_mem_mult<(outs), (ins), "ldm ", 0, 0, []>;
def LDMpc : S16_mem_mult<(outs), (ins), "ldm ", 0, 1, []>;
}

let mayStore=1 in {
def STM : S16_mem_mult<(outs), (ins), "stm ", 1, 0, []>;
def STMlr : S16_mem_mult<(outs), (ins), "stm ", 1, 1, []>;
}

let Uses=[SP] in {
let mayLoad=1 in
def LDsp : S16_mem_sp<(outs CRegs:$rd), (ins S5ImmOp:$o), "ld $rd, (sp+$o)", 0, []>;

let mayStore=1 in
def STsp : S16_mem_sp<(outs), (ins CRegs:$rd, S5ImmOp:$o), "st $rd, (sp+$o)", 1, []>;
}
// Store multiple registers

//===----------------------------------------------------------------------===//
// Pseudo Instructions
//===----------------------------------------------------------------------===//

let Defs=[SP], Uses=[SP] in {
def ADJCALLSTACKDOWN : VC4PseudoInst<(outs), (ins i32imm:$amt),
                                     "# ADJCALLSTACKDOWN $amt",
                                     []>;
def ADJCALLSTACKUP : VC4PseudoInst<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                                   "# ADJCALLSTACKUP $amt1",
                                   []>;
}
