// -*- tablegen -*- //

// Instruction format superclass

include "VC4InstrFormats.td"
include "VC4Operators.td"

//===----------------------------------------------------------------------===//
// Instruction Pattern Stuff
//===----------------------------------------------------------------------===//

//===---===//
// Operands, Complex Patterns and Transformations Definitions.
//===---===//

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

def s16imm : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;
def u6imm : PatLeaf<(imm), [{ return isInt<6>(N->getZExtValue()); }]>;

// Instruction operand types
def U6ImmOp : Operand<i32> {
  let DecoderMethod = "DecodeU6Imm";
}

def S5ImmOp : Operand<i32> {
  let DecoderMethod = "DecodeS6Imm";
}

// Address operand
def mem : Operand<iPTR> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops CRegs, s16imm);
  let EncoderMethod = "getMemEncoding";
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

//===----------------------------------------------------------------------===//
// ALU Instructions
//===----------------------------------------------------------------------===//

def ADDrr : VC4Inst<16, (outs ERegs:$dst),
                    (ins ERegs:$src1, ERegs:$src2),
                    "add $dst, $src1, $src2",
                    [(set i32:$dst, (add i32:$src1, i32:$src2))]>;

//===----------------------------------------------------------------------===//
// Return Instructions
//===----------------------------------------------------------------------===//

let isTerminator = 1, isReturn = 1, isBarrier = 1, Uses = [LR] in {
  def RET : VC4Inst<16, (outs),
                    (ins variable_ops),
                    "br lr",
                    [(VC4RetFlag)]>;
}
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
