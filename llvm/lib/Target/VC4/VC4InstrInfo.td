// -*- tablegen -*- //

// Instruction format superclass

include "VC4InstrFormats.td"
include "VC4Operators.td"

//===----------------------------------------------------------------------===//
// Instruction Pattern Stuff
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Operands, Complex Patterns and Transformations Definitions.
//===----------------------------------------------------------------------===//

class BinOpFrag<dag res> : PatFrag<(ops node:$LHS, node:$RHS), res>;
class UnOpFrag<dag res> : PatFrag<(ops node:$LHS), res>;

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

def bit_xform : SDNodeXForm<imm, [{
  assert(isPowerOf2_32(N->getZExtValue()) != -1);
  return getI32Imm(Log2_32(N->getZExtValue()), SDLoc(N));
}]>;

// Instruction operand types
def immSExt5    : Operand<i32>, ImmLeaf<i32, [{ return isInt<5>(Imm); }]>;
def immSExt5x4  : Operand<i32>, ImmLeaf<i32, [{ return isShiftedInt<5,2>(Imm); }], div4>;
def immSExt6x4  : Operand<i32>, ImmLeaf<i32, [{ return isShiftedInt<6,2>(Imm); }], div4>;
def immSExt7x2  : Operand<i32>, ImmLeaf<i32, [{ return isShiftedInt<7,1>(Imm); }], div2>;
def immSExt8x2  : Operand<i32>, ImmLeaf<i32, [{ return isShiftedInt<8,1>(Imm); }], div2>;
def immSExt10x2 : Operand<i32>, ImmLeaf<i32, [{ return isShiftedInt<10,1>(Imm); }], div2>;
def immSExt16   : Operand<i32>, ImmLeaf<i32, [{ return isInt<16>(Imm); }]>;
def immSExt23x2 : Operand<i32>, ImmLeaf<i32, [{ return isShiftedInt<23,1>(Imm); }], div2>;
def immSExt27   : Operand<i32>, ImmLeaf<i32, [{ return isInt<27>(Imm); }]>;
def immSExt27x2 : Operand<i32>, ImmLeaf<i32, [{ return isShiftedInt<27,1>(Imm); }], div2>;
def immSExt32   : Operand<i32>, ImmLeaf<i32, [{ return isInt<32>(Imm); }]>;

def immZExt4  : Operand<i32>, ImmLeaf<i32, [{ return isUInt<4>(Imm); }]>;
def immZExt5  : Operand<i32>, ImmLeaf<i32, [{ return isUInt<5>(Imm); }]>;
def immZExt6  : Operand<i32>, ImmLeaf<i32, [{ return isUInt<6>(Imm); }]>;
def immZExt16 : Operand<i16>, ImmLeaf<i16, [{ return isUInt<16>(Imm); }]>;
def immZext32 : Operand<i32>, ImmLeaf<i32, [{ return isUInt<32>(Imm); }]>;

def immBit : Operand<i32>, ImmLeaf<i32, [{ return Imm != 0 && isPowerOf2_32(Imm); }], bit_xform>;

// Address operand
def mem : Operand<iPTR> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops GRegs, immSExt16);
  let EncoderMethod = "getMemEncoding";
}

// Branch target
def brtarget8 : Operand<OtherVT>, ImmLeaf<i8, [{}], div2>;
def brtarget : Operand<OtherVT>;

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

// No operands
def BKPT   : _S16_0<0b0000, "bkpt">;
def NOP    : _S16_0<0b0001, "nop">;
def SLEEP  : _S16_0<0b0010, "sleep">;
def USER   : _S16_0<0b0011, "user">;
def EI     : _S16_0<0b0100, "ei">;
def DI     : _S16_0<0b0101, "di">;
def CBCLR  : _S16_0<0b0110, "cbclr">;
def CBADD1 : _S16_0<0b0111, "cbadd1">;
def CBADD2 : _S16_0<0b1000, "cbadd2">;
def CBADD3 : _S16_0<0b1001, "cbadd3">;
def RTI    : _S16_0<0b1010, "rti">;

multiclass _SWI {
  // 0000 0000 001d dddd - swi rd    Software Interrupt.  Raise interrupt 0x20+(rd&0x1f)
  def _1r5 : _S16_1r5<(outs), (ins ERegs:$rd), "swi $rd", []> { let Inst{14-5} = 0b0000000001; }
  // 0000 0001 11uu uuuu - swi u
  def _i6 : _S16_i6<(outs), (ins immZExt6:$imm), "swi $imm", []> { let Inst{14-6} = 0b000000111; }
}

// Software Interrupt - Raise 0x20+(rd & 0x1f)
defm SWI : _SWI;

class _SWITCH<bit w, string instr_asm>
    : _S16_1r4<(outs), (ins GRegs:$rd), instr_asm # "\t$rd", []> {
  let Inst{14-6} = 0b000000010;
  let Inst{5} = w;
  let Inst{4} = 0b0;
}

// Table branch byte.  pc = pc + 2*(*(s8 *)(pc+rd))
// 0000 0000 1000 dddd
def SWITCHB : _SWITCH<0, "switch.b">;

// Table branch short. pc = pc + 2*(*(s16 *)(pc+rd))
// 0000 0000 1010 dddd
def SWITCH : _SWITCH<1, "switch">;

// Version - Get cpu version and core number.
class VERSION_DESC {
  dag OutOperandList = (outs ERegs:$rd);
  string AsmString = "version\t$rd";
  string BaseOpcode = "version";
}

// 0000 0000 111d dddd
def VERSION : _S16_1r5<(outs ERegs:$rd), (ins), "version\t$rd", []>;

//===----------------------------------------------------------------------===//
// ALU Instructions
//===----------------------------------------------------------------------===//

let Constraints="$_rd=$rd" in {
// 011p pppu uuuu dddd - Rd = Rd op u
class _ALU4_1r4i5<VC4ALUOp opc, dag outs, dag ins, string asmstr, list<dag> pattern>
   : _S16_1r4i5<outs, ins, asmstr, pattern> {
  let Inst{14-13} = 0b11;
  let Inst{12-9} = opc.Value{4-1};
}

// 010p pppp ssss dddd
class _ALU5_2r4<VC4ALUOp opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16_2r4<outs, ins, asmstr, pattern> {
  let Inst{14-13} = 0b10;
  let Inst{12-8} = opc.Value{4-0};
}

// 1011 00pp pppd dddd iiii iiii iiii iiii
class _ALU5_1r5i16<VC4ALUOp opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_1r5i16<outs, ins, asmstr, pattern> {
  let Inst{30-26} = 0b01100;
  let Inst{25-21} = opc.Value{4-0};
}

// 1110 10pp pppd dddd uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
class _ALU5_1r5i32<VC4ALUOp opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S48_1r5i32<outs, ins, asmstr, pattern> {
  let Inst{46-42} = 0b11010;
  let Inst{41-37} = opc.Value{4-0};
}

}

/*
// 1100 0ppp pppd dddd aaaa accc c00b bbbb
class ALU6CC_3r5_ENC<VC4ALUOp opc, VC4CondCode cc>
    : _S32_3r5<outs, ins, asmstr, pattern> {
  let Inst{30-27} = 0b11000;
  let Inst{26-21} = opc.Value;
  let Inst{10-7} = cc.Value;
  let Inst{6} = 0b1;
}

// 1100 0ppp pppd dddd aaaa accc c1ii iiii
class ALU6CC_2r5i6<VC4ALUOp opc, VC4CondCode cc>
    : S32_2r5i6_FMT {
  let Inst{30-27} = 0b11000;
  let Inst{26-21} = opc.Value;
  let Inst{10-7} = cc.Value;
  let Inst{6} = 0b1;
}
*/

// Register with Immediate logical and arithmetic operations.

// 4-bit opcode - 0oooo0
multiclass ALU4B_pat<VC4ALUOp opc, string instr_asm, list<dag> pattern = [], string asm_suffix = ""> {
  def _2r4:  _ALU5_2r4<opc, (outs GRegs:$rd), (ins GRegs:$_rd, GRegs:$ra),
                      instr_asm # "\t$rd, $ra" # asm_suffix,
                      pattern>;
  def _1r4i5: _ALU4_1r4i5<opc, (outs GRegs:$rd), (ins GRegs:$_rd, immZExt5:$imm),
                        instr_asm # "\t$rd, $imm" # asm_suffix,
                        pattern>;
}

multiclass ALU4B<VC4ALUOp opc, string instr_asm, SDPatternOperator op, string asm_suffix = ""> {
  def _1r4i5: _ALU4_1r4i5<opc, (outs GRegs:$rd), (ins GRegs:$_rd, immZExt5:$imm),
                        instr_asm # "\t$rd, $imm" # asm_suffix,
                        [(set GRegs:$rd, (op GRegs:$_rd, immZExt5:$imm))]>;
  def _1r5i16: _ALU5_1r5i16<opc, (outs ERegs:$rd), (ins ERegs:$_rd, immSExt16:$imm),
                           instr_asm # "\t$rd, $imm" # asm_suffix,
                           [(set ERegs:$rd, (op ERegs:$_rd, immSExt16:$imm))]>;
  def _i15i32: _ALU5_1r5i32<opc, (outs ERegs:$rd), (ins ERegs:$_rd, immSExt32:$imm),
                           instr_asm # "\t$rd, $imm" # asm_suffix,
                           [(set ERegs:$rd, (op ERegs:$_rd, immSExt32:$imm))]>;
  def _2r4:  _ALU5_2r4<opc, (outs GRegs:$rd), (ins GRegs:$_rd, GRegs:$ra),
                      instr_asm # "\t$rd, $ra" # asm_suffix,
                      [(set GRegs:$rd, (op GRegs:$_rd, GRegs:$ra))]>;
}

multiclass ALU4U<VC4ALUOp opc, string instr_asm, SDPatternOperator op, string asm_suffix = ""> {
  def _1r4i5: _ALU4_1r4i5<opc, (outs GRegs:$rd), (ins immZExt5:$imm),
                        instr_asm # "\t$rd, $imm" # asm_suffix,
                        [(set GRegs:$rd, (op immZExt5:$imm))]>;
  def _1r5i16: _ALU5_1r5i16<opc, (outs ERegs:$rd), (ins immSExt16:$imm),
                           instr_asm # "\t$rd, $imm" # asm_suffix,
                           [(set ERegs:$rd, (op immSExt16:$imm))]>;
  def _i15i32: _ALU5_1r5i32<opc, (outs ERegs:$rd), (ins immSExt32:$imm),
                           instr_asm # "\t$rd, $imm" # asm_suffix,
                           [(set ERegs:$rd, (op immSExt32:$imm))]>;
  def _2r4:  _ALU5_2r4<opc, (outs GRegs:$rd), (ins GRegs:$ra),
                      instr_asm # "\t$rd, $ra" # asm_suffix,
                      [(set GRegs:$rd, (op GRegs:$ra))]>;
}

// 5-bit opcode - 0ooooo
multiclass ALU5B<VC4ALUOp opc, string instr_asm, SDPatternOperator op, string asm_suffix = ""> {
  def _2r4:    _ALU5_2r4<opc, (outs GRegs:$rd), (ins GRegs:$_rd, GRegs:$ra),
                         instr_asm # "\t$rd, $ra" # asm_suffix,
                         [(set GRegs:$rd, (op GRegs:$_rd, GRegs:$ra))]>;
  def _1r5i16: _ALU5_1r5i16<opc, (outs ERegs:$rd), (ins ERegs:$_rd, immSExt16:$imm),
                           instr_asm # "\t$rd, $imm" # asm_suffix,
                           [(set ERegs:$rd, (op ERegs:$_rd, immSExt16:$imm))]>;
  def _i15i32: _ALU5_1r5i32<opc, (outs ERegs:$rd), (ins ERegs:$_rd, immSExt32:$imm),
                           instr_asm # "\t$rd, $imm" # asm_suffix,
                           [(set ERegs:$rd, (op ERegs:$_rd, immSExt32:$imm))]>;
}

//defm MOV        : _ALU4<VC4ALU_mov, "mov", []>;
defm ADD        : ALU4B<VC4ALU_add, "add", add>;
defm MUL        : ALU4B<VC4ALU_mul, "mul", mul>;
defm SUB        : ALU4B<VC4ALU_sub, "sub", sub>;
defm NOT        : ALU4U<VC4ALU_not, "not", UnOpFrag<(not node:$LHS)>>;
//defm CMP        : _ALU4<VC4ALU_cmp, "cmp", []>;
//defm BTEST      : _ALU4<VC4ALU_btest, "btest", []>;
//defm BMASK      : _ALU4<VC4ALU_bmask, "bmask", []>;
//defm BITSET     : ALU4B_2<"bitset", VC4ALU_bitset, BinOpFrag<(add node:$LHS>>;
//defm BITCLEAR   : _ALU4<VC4ALU_bitclear, "bitclear", []>;
//defm BITFLIP    : _ALU4<VC4ALU_bmask, "bitflip", []>;
defm ADDSCALE8  : ALU4B<VC4ALU_addscale8, "addscale", BinOpFrag<(add node:$LHS, (shl node:$RHS, 3))>, " << 3">;
//defm SIGNEXT    : _ALU4<VC4ALU_bmask, "signext", []>;
defm LSR        : ALU4B<VC4ALU_lsr, "lsr", srl>;
defm SHL        : ALU4B<VC4ALU_shl, "shl", shl>;
defm ASR        : ALU4B<VC4ALU_asr, "asr", sra>;

//defm CMN        : _ALU5<VC4ALU_cmn, "cmn", []>;
defm BIC        : ALU5B<VC4ALU_bic, "bic", BinOpFrag<(and node:$LHS, (not node:$RHS))>>;
defm EOR        : ALU5B<VC4ALU_eor, "eor", xor>;
defm AND        : ALU5B<VC4ALU_and, "and", and>;
defm ROR        : ALU5B<VC4ALU_ror, "ror", rotr>;
//defm RSUB       : _ALU5<VC4ALU_rsub, "rsub", []>;
defm OR         : ALU5B<VC4ALU_or, "or", or>;
//defm MAX        : _ALU5<VC4ALU_max, "max", []>;
//defm MIN        : _ALU5<VC4ALU_min, "min", []>;
defm ADDSCALE2  : ALU5B<VC4ALU_addscale2, "addscale", BinOpFrag<(add node:$LHS, (shl node:$RHS, 1))>, " << 1">;
defm ADDSCALE4  : ALU5B<VC4ALU_addscale4, "addscale", BinOpFrag<(add node:$LHS, (shl node:$RHS, 2))>, " << 2">;
defm ADDSCALE16 : ALU5B<VC4ALU_addscale16, "addscale", BinOpFrag<(add node:$LHS, (shl node:$RHS, 4))>, " << 4">;
//defm NEG        : _ALU5<VC4ALU_neg, "neg", []>;
//defm MSB        : _ALU5<VC4ALU_msb, "msb", []>;
//defm BREV       : _ALU5<VC4ALU_brev, "brev", []>;
//defm ABS        : _ALU5<VC4ALU_abs, "abs", []>;


//===----------------------------------------------------------------------===*/
// Add register + immediate
//===----------------------------------------------------------------------===*/

// add rd, rs, i
class ADD_RRI_DESC<string instr_asm, RegisterClass RC, Operand ImmOpnd,
                   SDPatternOperator ImmPat> {
  dag OutOperandList = (outs RC:$rd);
  dag InOperandList =  (ins RC:$rs, ImmOpnd:$imm);
  string AsmString = instr_asm # "\t$rd, $rs, $imm";
  list<dag> Pattern = [(set RC:$rd, (add RC:$rs, ImmPat:$imm))];
  string BaseOpcode = instr_asm;
}

// 1011 01ss sssd dddd iiii iiii iiii iiii
class ADD_2r5i16_ENC : _S16_2r4_FMT {
  let Inst{30-26} = 0b01101;
}

// 1110 11ss sssd dddd uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
class ADD_2r5i32_ENC : S16_2r4_FMT {
  let Inst{30-26} = 0b11011;
}

multiclass ADDrri<string instr_asm> {
  def _2r5i16: ADD_2r5i16_ENC, ADD_RRI_DESC<instr_asm, ERegs, immSExt16, immSExt16>;
  def _2r5i32: ADD_2r5i32_ENC, ADD_RRI_DESC<instr_asm, ERegs, immSExt32, immSExt32>;
}

defm ADD : ADDrri<"add">;

//===----------------------------------------------------------------------===*/
// AddCmpBCC Instructions
//===----------------------------------------------------------------------===*/

/*
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
*/



//- 1011 1111 111d dddd oooo oooo oooo oooo   add rd, pc, o                   rd = pc + o
//- 1110 0101 000d dddd oooo oooo oooo oooo oooo oooo oooo oooo   add rd, pc, o                      rd = pc + o

class ADDpc_DESC<string instr_asm, SDPatternOperator OpNode, RegisterClass RC> {
  dag OutOperandList = (outs RC:$rd);
  dag InOperandList =  (ins RC:$_rd, RC:$rs);
  string AsmString = instr_asm # "\t$rd, $rs";
  list<dag> Pattern = [(set RC:$rd, (OpNode RC:$_rd, RC:$rs))];
  string Constraints = "$_rd = $rd";
  string BaseOpcode = instr_asm;
}

// Add Stack Relative
// 0001 0ooo oood dddd - add  rd, sp, o*4     rd = sp + o*4
//def ADDsp : S16_1r5o6_FMT<(outs), (ins ExRegs:$rd, simm6:$off), "add $rd, sp, $off", []>;

//===----------------------------------------------------------------------===*/
// Branch Instructions
//===----------------------------------------------------------------------===*/

//===----------------------------------------------------------------------===//
// Direct branch

// Branch on condition to target - b<cc>  $+o*2
class B_DESC<dag ins, list<dag> pat> {
  dag InOperandList = ins;
  string AsmString = "b\t$off";
  list<dag> Pattern = pat;
  string BaseOpcode = "b";
}

// 0001 1111 0ooo oooo -
class B_o7_ENC : S16_o7_FMT {
  let Inst{14-7} = 0b00111110;
}

// 1110 0001 0000 0000 oooo oooo oooo oooo oooo oooo oooo oooo   b $+o                              Branch to target.
class B_o32_ENC : S48_o32_FMT {
  let Inst{46-32} = 0b110000100000000;
}

let isBranch = 1, isTerminator = 1 in {
def B_o8: B_o7_ENC, B_DESC<(ins brtarget8:$off), []>;
def B_o32: B_o32_ENC, B_DESC<(ins brtarget:$off), []>;
}

//===----------------------------------------------------------------------===//
// Indirect branch
class BRIND_DESC {
  dag InOperandList = (ins ERegs:$rd);
  string AsmString = "b\t$rd";
  list<dag> Pattern = [(brind ERegs:$rd)];
  string BaseOpcode = "b";
}

// 0000 0000 010d dddd
class BRIND_1r5_ENC : S16_1r5_FMT {
  let Inst{14-5} = 0b0000000010;
}

// Indirect branch - b $rd
//let isBranch = 1, isIndirectBranch = 1, isTerminator = 1, isBarrier = 1 {
def BRIND_1r5 : BRIND_1r5_ENC, BRIND_DESC;
//}

class BL_r_DESC<string instr_asm> {
  dag InOperandList = (ins ERegs:$rd);
  string AsmString = instr_asm # "\t$rd";
  string BaseOpcode = instr_asm;
}

class BL_off_DESC<string instr_asm> {
  dag InOperandList = (ins brtarget:$off);
  string AsmString = instr_asm # "\t$off";
  string BaseOpcode = instr_asm;
}

// 0000 0000 011d dddd
class BL_1r5_ENC : S16_1r5_FMT {
  let Inst{14-5} = 0b0000000011;
}

// 1001 oooo 1ooo oooo oooo oooo oooo oooo
class BL_o28_ENC : S32_o27_FMT {
  let Inst{30-28} = 0b001;
  let Inst{23} = 0b1;
}

// 1110 0011 0000 0000 oooo oooo oooo oooo oooo oooo oooo oooo
class BL_o32_ENC : S48_o32_FMT {
  let Inst{46-32} = 0b110001100000000;
}

// Branch and Link - bl rd; bl $+o
let isCall=1, Defs = [R0, R1, R2, R3, R4, R5, LR] in {
def BL_1r5 : BL_1r5_ENC, BL_r_DESC<"bl">;
def BL_o28 : BL_o28_ENC, BL_off_DESC<"bl">;
def BL_o32 : BL_o32_ENC, BL_off_DESC<"bl">;
}

//===----------------------------------------------------------------------===//
// Conditional Branch

class BCC_DESC<string instr_asm> {
  dag InOperandList = (ins brtarget:$off);
  string AsmString = instr_asm # "\t$off";
  string BaseOpcode = instr_asm;
}

// 0001 1ccc cooo oooo - b<cc> $+2*o
class BCC_o8_ENC<VC4CondCode cc> : S16_o7_FMT {
  let Inst{14-11} = 0b0011;
  let Inst{10-7} = cc.Value;
}

// 1001 cccc 0ooo oooo oooo oooo oooo oooo - b<cc> $+2*o
class BCC_o24_ENC<VC4CondCode cc> : S32_o23_FMT {
  let Inst{30-28} = 0b001;
  let Inst{27-24} = cc.Value;
  let Inst{23} = 0b0;
}

multiclass _BCC<VC4CondCode cc, string instr_asm> {
  def _o8 : BCC_o8_ENC<cc>, BCC_DESC<instr_asm>;
  def _o24 : BCC_o24_ENC<cc>, BCC_DESC<instr_asm>;
}

defm BEQ : _BCC<VC4CC_eq, "beq">;
defm BNE : _BCC<VC4CC_ne, "bne">;
defm BCS : _BCC<VC4CC_cs, "bcs">;
defm BCC : _BCC<VC4CC_cc, "bcc">;
defm BMI : _BCC<VC4CC_mi, "bmi">;
defm BPL : _BCC<VC4CC_pl, "bpl">;
defm BVS : _BCC<VC4CC_vs, "bvs">;
defm BVC : _BCC<VC4CC_vc, "bvc">;
defm BHI : _BCC<VC4CC_hi, "bhi">;
defm BLS : _BCC<VC4CC_ls, "bls">;
defm BGE : _BCC<VC4CC_ge, "bge">;
defm BLT : _BCC<VC4CC_lt, "blt">;
defm BGT : _BCC<VC4CC_gt, "bgt">;
defm BLE : _BCC<VC4CC_le, "ble">;

//===----------------------------------------------------------------------===//
// Floating Point Instructions
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Load/Store Instructions
//===----------------------------------------------------------------------===//

// Load/Store
/*
// Load/Store indirect via register - {ld,st}<w> rd, (rs)
class LDST_2r4_DESC<string instr_asm> {
  dag OutOperandList = (outs GRegs:$rd);
  dag InOperandList = (ins GRegs:$rs);
  string AsmString = instr_asm # "\t$rd, ($rs)";
  string BaseOpcode = instr_asm;
}

class LDST_2r4_ENC<bit ldst, bits<2> w> : S16_2r4_FMT {
  let Inst{14-11} = 0b0001;
  let Inst{10-9} = w;
  let Inst{8} = ldst;
}

multiclass _LDST<string instr_asm, VC4LS ls, LoadStoreWidth w> {
  def _2r4 : LDST_2r4_ENC<ls.Value, w.Value>, LDST_2r4_DESC<instr_asm>;
}

// 0000 1ww0 ssss dddd - Load from memory.
defm LDW : _LDST<"ld",  VC4LS_load, LSWu32>;
defm LDH : _LDST<"ldh", VC4LS_load, LSWu16>;
defm LDB : _LDST<"ldb", VC4LS_load, LSWu8>;

// 0000 1ww1 ssss dddd - Store to memory.
defm STW : _LDST<"st",  VC4LS_store, LSWu32>;
defm STH : _LDST<"sth", VC4LS_store, LSWu16>;
defm STB : _LDST<"stb", VC4LS_store, LSWu8>;
*/

// Load/Store Multiple Register
def RegListAsmOperand : AsmOperandClass { let Name = "RegList"; }
def reglist : Operand<i32> {
}

class LDSTM_DESC<bit lrpc, bit ldst> {
  dag InOperandList = (ins reglist:$regs, variable_ops);
  string BaseOpcode = !if(ldst, "stm", "ldm");
  string AsmString = BaseOpcode # "\t$regs"
                                # !if(lrpc, !if(ldst, ",lr", ",pc"), "")
                                # !if(ldst, ",(--sp)", "(sp++)");
}

// 0000 0010 0bbm mmmm - ldm rb-rm,(sp++)     Load registers from stack (highest first).
// 0000 0010 1bbm mmmm - stm rb-rm,(--sp)     Store registers to stack (lowest first).
// 0000 0011 0bbm mmmm - ldm rb-rm,pc,(sp++)  Load registers from stack and final value into pc.
// 0000 0011 1bbm mmmm - stm rb-rm,lr,(--sp)  Store lr followed by registers onto stack.
class LDSTM_ENC<bit lrpc, bit ldst> : S16_FMT {
  let Inst{14-9} = 0b000001;
  let Inst{8} = lrpc;
  let Inst{7} = ldst;
}

class _LDSTM<bit lrpc, VC4LS ls> : LDSTM_ENC<lrpc, ls.Value>, LDSTM_DESC<lrpc, ls.Value>;

def LDM    : _LDSTM<0, VC4LS_load>;
def LDM_pc : _LDSTM<1, VC4LS_load>;
def STM    : _LDSTM<0, VC4LS_store>;
def STM_lr : _LDSTM<1, VC4LS_store>;

// Load/Store - Stack Relative - {ld,st} rd, (sp+o*4)
class LDSTsp_DESC<bit ldst> {
  dag InOperandList = (ins GRegs:$rd, immSExt32:$off);
  string BaseOpcode = !if(ldst, "st", "ld");
  string AsmString = BaseOpcode # "\t$rd, (sp+$off)";
}

// 0000 010o oooo dddd
class LDSTsp_ENC<bit ldst> : S16_1r4o5_FMT {
  let Inst{14-10} = 0b00001;
  let Inst{9} = ldst;
}

class _LDSTsp<VC4LS ls> : LDSTsp_ENC<ls.Value>, LDSTsp_DESC<ls.Value>;

def LDWsp : _LDSTsp<VC4LS_load>;
def STWsp : _LDSTsp<VC4LS_store>;

//===----------------------------------------------------------------------===//
// Return Instructions
//===----------------------------------------------------------------------===//

def VC4retflag : SDNode<"VC4ISD::RET_FLAG", SDTNone,
                        [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

class BLR_DESC {
  string AsmString = "b\tlr";
  list<dag> Pattern = [(VC4retflag)];
  string BaseOpcode = "b";
}

// 0000 0000 010d dddd
class BLR_ENC : S16_1r5_FMT {
  let Inst{14-0} = 0b000000001011010;
}

let isTerminator = 1, isReturn = 1, isBarrier = 1, Uses = [LR] in {
  def BLR_RET : BLR_ENC, BLR_DESC;
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
