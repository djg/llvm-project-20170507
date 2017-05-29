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
def uimm5 : PatLeaf<(imm), [{
  return (uint32_t)N->getZExtValue() < (1 << 5);
}]>;

def U6ImmOp : Operand<i32> {
  let DecoderMethod = "DecodeU6Imm";
}

def S5ImmOp : Operand<i32> {
  let DecoderMethod = "DecodeS6Imm";
}

// Address operand
def mem : Operand<iPTR> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops GPRegs, s16imm);
  let EncoderMethod = "getMemEncoding";
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

// No operands
/*
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
def SWIrd : S16_rd5_1<(outs), (ins ExRegs:$rd), 0b001, "swi $rd", []>;
def SWIu  : S16_swi<(outs), (ins U6ImmOp:$u), "swi $u", []>;
*/

// Jump table
//todo:-)

// Version
//def VERSION : S16_rd5_1<(outs ExRegs:$rd), (ins), 0b111, "version $rd", []>;

//===----------------------------------------------------------------------===//
// ALU Instructions
//===----------------------------------------------------------------------===//

class _S16ALU2r4<VC4ALUOp opc, dag outs, dag ins, string asm, list<dag> pattern>
    : S16_2r4<outs, ins, asm, pattern> {
  let Inst{14-13} = 0b10;
  let Inst{12-8} = opc.Value{4-0};
}

class _S16ALU1r4imm5<VC4ALUOp opc, dag outs, dag ins, string asm, list<dag> pattern>
    : S16_1r4imm5<outs, ins, asm, pattern> {
  let Inst{14-13} = 0b11;
  let Inst{12-9} = opc.Value{4-1};
}

class S16ALU2r4<VC4ALUOp opc, string mnemonic, SDNode OpCode>
    : _S16ALU2r4<opc, (outs GPRegs:$rd), (ins GPRegs:$rdi, GPRegs:$rs),
                 !strconcat(mnemonic, " $rd, $rs"),
                 [(set GPRegs:$rd, (OpCode GPRegs:$rdi, GPRegs:$rs))]>;

multiclass S16ALU1r4i_2r4<VC4ALUOp opc, string mnemonic, SDNode OpCode> {
  def _1ri: _S16ALU1r4imm5<opc, (outs GPRegs:$rd), (ins GPRegs:$rdi, i32imm:$imm),
                         !strconcat(mnemonic, " $rd, $imm"),
                         [(set GPRegs:$rd, (OpCode GPRegs:$rdi, uimm5:$imm))]>;
  def _2r: S16ALU2r4<opc, mnemonic, OpCode>;
}

// Two operand ALU
// 0 - MOV
// 1 - CMN
let Constraints = "$rdi = $rd" in {
defm ADD: S16ALU1r4i_2r4<VC4ALU_add, "add", add>;
// 1 - BIC
defm MUL: S16ALU1r4i_2r4<VC4ALU_mul, "mul", mul>;
def  XOR: S16ALU2r4<VC4ALU_xor, "xor", xor>;
defm SUB: S16ALU1r4i_2r4<VC4ALU_sub, "sub", sub>;
def  AND: S16ALU2r4<VC4ALU_and, "and", and>;
// 0 - NOT
// 1 - ROR
// 0 - CMP
// 1 - RSUB
// 0 - BTEST
def  OR: S16ALU2r4<VC4ALU_or, "or", or>;
// 0 - BMASK
// 1 - MAX
// 0 - BITSET
// 1 - MIN
// 0 - BITCLEAR
def ADDSCALE2: _S16ALU2r4<VC4ALU_addscale2, (outs GPRegs:$rd), (ins GPRegs:$rdi, GPRegs:$rs),
                          "addscale $rd, $rs << 1",
                          [(set GPRegs:$rd, (add GPRegs:$rdi, (shl GPRegs:$rs, 1)))]>;
// 0 - BITFLIP
def ADDSCALE4: _S16ALU2r4<VC4ALU_addscale4, (outs GPRegs:$rd), (ins GPRegs:$rdi, GPRegs:$rs),
                          "addscale $rd, $rs << 2",
                          [(set GPRegs:$rd, (add GPRegs:$rdi, (shl GPRegs:$rs, 2)))]>;
def ADDSCALE8: _S16ALU2r4<VC4ALU_addscale8, (outs GPRegs:$rd), (ins GPRegs:$rdi, GPRegs:$rs),
                          "addscale $rd, $rs << 3",
                          [(set GPRegs:$rd, (add GPRegs:$rdi, (shl GPRegs:$rs, 3)))]>;
def ADDSCALE16: _S16ALU2r4<VC4ALU_addscale16, (outs GPRegs:$rd), (ins GPRegs:$rdi, GPRegs:$rs),
                          "addscale $rd, $rs << 4",
                          [(set GPRegs:$rd, (add GPRegs:$rdi, (shl GPRegs:$rs, 4)))]>;
// 0 - SIGNEXT
// 1 - NEG
defm LSR: S16ALU1r4i_2r4<VC4ALU_lsr, "lsr", srl>;
// 1 - MSB
defm SHL: S16ALU1r4i_2r4<VC4ALU_shl, "shl", shl>;
// 1 - BREV
defm ASR: S16ALU1r4i_2r4<VC4ALU_asr, "asr", sra>;
// 1 - ABS
}

//===----------------------------------------------------------------------===*/
// AddCmpBCC Instructions
//===----------------------------------------------------------------------===*/

class S32_addcmpbcc_0<VC4CondCode cc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : S32_addcmpbcc<cc, outs, ins, asmstr, pattern> {
  bits<4>  ra;
  bits<4>  rs;
  bits<10> off;

  let Inst{23-20} = ra;
  let Inst{15-14} = 0b00;
  let Inst{13-10} = rs;
  let Inst{9-0}   = off;
}

class S32_addcmpbcc_1<VC4CondCode cc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : S32_addcmpbcc<cc, outs, ins, asmstr, pattern> {
  bits<4>  imm;
  bits<4>  rs;
  bits<10> off;

  let Inst{23-20} = imm;
  let Inst{15-14} = 0b01;
  let Inst{13-10} = rs;
  let Inst{9-0}   = off;
}

class S32_addcmpbcc_2<VC4CondCode cc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : S32_addcmpbcc<cc, outs, ins, asmstr, pattern> {
  bits<4> ra;
  bits<6> u;
  bits<8> off;

  let Inst{23-20} = ra;
  let Inst{15-14} = 0b10;
  let Inst{13-8}  = u;
  let Inst{7-0}   = off;
}

class S32_addcmpbcc_3<VC4CondCode cc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : S32_addcmpbcc<cc, outs, ins, asmstr, pattern> {
  bits<4> imm;
  bits<6> u;
  bits<8> off;

  let Inst{23-20} = imm;
  let Inst{15-14} = 0b11;
  let Inst{13-8}  = u;
  let Inst{7-0}   = off;
}

//===----------------------------------------------------------------------===*/
// Branch Instructions
//===----------------------------------------------------------------------===*/

// Unconditional branch
let isBranch = 1, isIndirectBranch=1, isTerminator=1, isBarrier=1 in
def B : S16_1r5<(outs), (ins ExRegs:$rd), "b $rd", []> {
  let Inst{14-5} = 0b0000000010;
}

let isCall=1, Defs = [R0, R1, R2, R3, R4, R5, LR] in
def BL : S16_1r5<(outs), (ins ExRegs:$rd), "bl $rd", []> {
  let Inst{14-5} = 0b0000000011;
}

// Conditional branch
def BEQ : S16_bcc<VC4CC_eq.Value, (outs), (ins i32imm:$imm), "beq $imm", []>;

//===----------------------------------------------------------------------===//
// Load/Store Instructions
//===----------------------------------------------------------------------===//


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
