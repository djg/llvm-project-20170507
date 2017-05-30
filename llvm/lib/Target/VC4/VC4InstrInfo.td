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

// Instruction operand types
def immSExt5  : Operand<i32>, ImmLeaf<i32, [{ return isInt<5>(Imm); }]>;
def immSExt16 : Operand<i32>, ImmLeaf<i32, [{ return isInt<16>(Imm); }]>;
def immSExt32 : Operand<i32>, ImmLeaf<i32, [{ return isInt<32>(Imm); }]>;

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
class S16_0_DESC<string instr_asm> {
  string AsmString = instr_asm;
  string BaseOpcode = instr_asm;
}

class BKPT_DESC : S16_0_DESC<"bkpt">;
class NOP_DESC : S16_0_DESC<"nop">;
class SLEEP_DESC : S16_0_DESC<"sleep">;
class USER_DESC : S16_0_DESC<"user">;
class EI_DESC : S16_0_DESC<"ei">;
class DI_DESC : S16_0_DESC<"di">;
class CBCLR_DESC : S16_0_DESC<"cbclr">;
class CBADD1_DESC : S16_0_DESC<"cbadd1">;
class CBADD2_DESC : S16_0_DESC<"cbadd2">;
class CBADD3_DESC : S16_0_DESC<"cbadd3">;
class RTI_DESC : S16_0_DESC<"rti">;

class BKPT_ENC : S16_0_FMT<0b0000>;
class NOP_ENC : S16_0_FMT<0b0001>;
class SLEEP_ENC : S16_0_FMT<0b0010>;
class USER_ENC : S16_0_FMT<0b0011>;
class EI_ENC : S16_0_FMT<0b0100>;
class DI_ENC : S16_0_FMT<0b0101>;
class CBCLR_ENC : S16_0_FMT<0b0110>;
class CBADD1_ENC : S16_0_FMT<0b0111>;
class CBADD2_ENC : S16_0_FMT<0b1000>;
class CBADD3_ENC : S16_0_FMT<0b1001>;
class RTI_ENC : S16_0_FMT<0b1010>;

def BKPT   : BKPT_ENC, BKPT_DESC;
def NOP    : NOP_ENC, NOP_DESC;
def SLEEP  : SLEEP_ENC, SLEEP_DESC;
def USER   : USER_ENC, USER_DESC;
def EI     : EI_ENC, EI_DESC;
def DI     : DI_ENC, DI_DESC;
def CBCLR  : CBCLR_ENC, CBCLR_DESC;
def CBADD1 : CBADD1_ENC, CBADD1_DESC;
def CBADD2 : CBADD2_ENC, CBADD2_DESC;
def CBADD3 : CBADD3_ENC, CBADD3_DESC;
def RTI    : RTI_ENC, RTI_DESC;

/*multiclass _SWI {
  // 0000 0000 001d dddd - swi rd    Software Interrupt.  Raise interrupt 0x20+(rd&0x1f)
  def _1r5 : S16_1r5_FMT<(outs), (ins), "swi $rd", []> { let Inst{14-5} = 0b0000000001; }
  // 0000 0001 11uu uuuu - swi u
  def _i6 : S16_i6_FMT<(outs), (ins), "swi $imm", []> { let Inst{14-6} = 0b000000111; }
}

// Software Interrupt - Raise 0x20+(rd & 0x1f)
defm SWI : _SWI;

// Table branch byte.  pc = pc + 2*(*(s8 *)(pc+rd))
// 0000 0000 1000 dddd
def SWITCHB : S16_1r4<(outs), (ins), "switch.b $rd", []>;

// Table branch short. pc = pc + 2*(*(s16 *)(pc+rd))
// 0000 0000 1010 dddd
def SWITCH : S16_1r4<(outs), (ins), "switch $rd", []>;

// Version - Get cpu version and core number.
// 0000 0000 111d dddd
def VERSION : S16_1r5<(outs ExRegs:$rd), (ins), "version $rd", []> { let Inst{14-5} = 0b0000000111; }
*/

//===----------------------------------------------------------------------===//
// ALU Instructions
//===----------------------------------------------------------------------===//

class ALU_RI_DESC<string instr_asm, SDPatternOperator OpNode,
             SDPatternOperator ImmPat, RegisterClass RC,
             Operand ImmOpnd> {
  dag OutOperandList = (outs RC:$rd);
  dag InOperandList =  (ins RC:$_rd, ImmOpnd:$imm);
  string AsmString = instr_asm # "\t$rd, $imm";
  list<dag> Pattern = [(set RC:$rd, (OpNode RC:$_rd, ImmPat:$imm))];
  string Constraints = "$_rd = $rd";
  string BaseOpcode = instr_asm;
}

// 011o ooou uuuu dddd - Rd = Rd op u
class ALU_1r4i5_ENC<VC4ALUOp opc> : S16_2r4_FMT {
  let Inst{14-13} = 0b11;
  let Inst{12-9} = opc.Value{4-1};
}

// 1011 00oo oood dddd iiii iiii iiii iiii
class ALU_1r5i16_ENC<VC4ALUOp opc> : S32_1r5i16_FMT {
  let Inst{30-26} = 0b01100;
  let Inst{25-21} = opc.Value{4-0};
}

// 1110 10oo oood dddd uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
class ALU_1r5i32_ENC<VC4ALUOp opc> : S48_1r5i32_FMT {
  let Inst{46-42} = 0b11010;
  let Inst{41-37} = opc.Value{4-0};
}

class ALU_RR_DESC<string instr_asm, SDPatternOperator OpNode, RegisterClass RC> {
  dag OutOperandList = (outs RC:$rd);
  dag InOperandList =  (ins RC:$_rd, RC:$rs);
  string AsmString = instr_asm # "\t$rd, $rs";
  list<dag> Pattern = [(set RC:$rd, (OpNode RC:$_rd, RC:$rs))];
  string Constraints = "$_rd = $rd";
  string BaseOpcode = instr_asm;
}

// 010o oooo ssss dddd
class ALU_2r4_ENC<VC4ALUOp opc> : S16_2r4_FMT {
  let Inst{14-13} = 0b10;
  let Inst{12-8} = opc.Value{4-0};
}

// Register with Immediate logical and arithmetic operations.

// 4-bit opcode - 0oooo0
multiclass ALU4B<string instr_asm, VC4ALUOp opc, SDPatternOperator op> {
  def _1r4i5:  ALU_1r4i5_ENC<opc>,  ALU_RI_DESC<instr_asm, op, immSExt5,  GRegs, immSExt5>;
}

//defm MOV        : _ALU4<VC4ALU_mov, "mov", []>;
defm ADD        : ALU4B<"add", VC4ALU_add, add>;
defm MUL        : ALU4B<"mul", VC4ALU_mul, mul>;
defm SUB        : ALU4B<"sub", VC4ALU_sub, sub>;
//defm NOT        : ALU4B<"not", VC4ALU_not, not>;
//defm CMP        : _ALU4<VC4ALU_cmp, "cmp", []>;
//defm BTEST      : _ALU4<VC4ALU_btest, "btest", []>;
//defm BMASK      : _ALU4<VC4ALU_bmask, "bmask", []>;
//defm BITSET     : _ALU4<VC4ALU_bitset, "bitset", []>;
//defm BITCLEAR   : _ALU4<VC4ALU_bitclear, "bitclear", []>;
//defm ADDSCALE2  : _ALU5<VC4ALU_addscale2, "addscale $rd, $rs << 1", []>;
//defm BITFLIP    : _ALU4<VC4ALU_bmask, "bitflip", []>;
//defm ADDSCALE8  : _ALU4<VC4ALU_addscale8, "addscale $rd, $rs << 3", []>;
//defm SIGNEXT    : _ALU4<VC4ALU_bmask, "signext", []>;
//defm LSR        : _ALU4<VC4ALU_lsr, "lsr", srl>;
//defm SHL        : _ALU4<VC4ALU_shl, "shl", shl>;
//defm ASR        : _ALU4<VC4ALU_asr, "asr", sra>;


// 5-bit opcode - 0ooooo
multiclass ALU5B<string instr_asm, VC4ALUOp opc, SDPatternOperator op> {
  def _2r4:    ALU_2r4_ENC<opc>,    ALU_RR_DESC<instr_asm, op, GRegs>;
  def _1r5i16: ALU_1r5i16_ENC<opc>, ALU_RI_DESC<instr_asm, op, immSExt16, ERegs, immSExt16>;
  def _i15i32: ALU_1r5i32_ENC<opc>, ALU_RI_DESC<instr_asm, op, immSExt32, ERegs, immSExt32>;
}

//defm MOV        : _ALU4<VC4ALU_mov, "mov", []>;
//defm CMN        : _ALU5<VC4ALU_cmn, "cmn", []>;
defm ADD        : ALU5B<"add", VC4ALU_add, add>;
//defm BIC        : _ALU5<VC4ALU_bic, "bic", []>;
defm MUL        : ALU5B<"mul", VC4ALU_mul, mul>;
defm EOR        : ALU5B<"eor", VC4ALU_eor, xor>;
defm SUB        : ALU5B<"sub", VC4ALU_sub, sub>;
defm AND        : ALU5B<"and", VC4ALU_and, and>;
//defm NOT        : ALU5B<"not", VC4ALU_not, not>;
//defm ROR        : _ALU5<VC4ALU_ror, "ror", rotr>;
//defm CMP        : _ALU4<VC4ALU_cmp, "cmp", []>;
//defm RSUB       : _ALU5<VC4ALU_rsub, "rsub", []>;
//defm BTEST      : _ALU4<VC4ALU_btest, "btest", []>;
defm OR         : ALU5B<"or", VC4ALU_or, or>;
//defm BMASK      : _ALU4<VC4ALU_bmask, "bmask", []>;
//defm MAX        : _ALU5<VC4ALU_max, "max", []>;
//defm BITSET     : _ALU4<VC4ALU_bitset, "bitset", []>;
//defm MIN        : _ALU5<VC4ALU_min, "min", []>;
//defm BITCLEAR   : _ALU4<VC4ALU_bitclear, "bitclear", []>;
//defm ADDSCALE2  : _ALU5<VC4ALU_addscale2, "addscale $rd, $rs << 1", []>;
//defm BITFLIP    : _ALU4<VC4ALU_bmask, "bitflip", []>;
//defm ADDSCALE4  : _ALU5<VC4ALU_addscale4, "addscale $rd, $rs << 2", []>;
//defm ADDSCALE8  : _ALU4<VC4ALU_addscale8, "addscale $rd, $rs << 3", []>;
//defm ADDSCALE16 : _ALU5<VC4ALU_addscale16, "addscale $rd, $rs << 4", []>;
//defm SIGNEXT    : _ALU4<VC4ALU_bmask, "signext", []>;
//defm NEG        : _ALU5<VC4ALU_neg, "neg", []>;
defm LSR        : ALU5B<"lsr", VC4ALU_lsr, srl>;
//defm MSB        : _ALU5<VC4ALU_msb, "msb", []>;
defm SHL        : ALU5B<"shl", VC4ALU_shl, shl>;
//defm BREV       : _ALU5<VC4ALU_brev, "brev", []>;
defm ASR        : ALU5B<"asr", VC4ALU_asr, sra>;
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
class ADD_2r5i16_ENC : S16_2r4_FMT {
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
