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

// Stack relative load/store

def SDT_ldwsp    : SDTypeProfile<1, 1, [SDTCisInt<1>]>;
def ldwsp : SDNode<"VC4ISD::LDWSP", SDT_ldwsp, [SDNPHasChain, SDNPMayLoad]>;
def SDT_stwsp    : SDTypeProfile<0, 2, [SDTCisInt<1>]>;
def stwsp : SDNode<"VC4ISD::STWSP", SDT_stwsp, [SDNPHasChain, SDNPMayStore]>;

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

// SPOffsetImm5x4 - An SP relative offset of form 4*o where o is sign
// ext 5-bit int.
def SPOffsetImm5x4AsmOperand : AsmOperandClass {
  let Name = "SPOffsetImm5x4";
  let ParserMethod = "parseSPOffsetImm5x4";
}
def spoffset5x4_imm : Operand<i32>, ImmLeaf<i32, [{ return isShiftedInt<5,2>(Imm); }], div4> {
    let PrintMethod = "printSPOffset5x4ImmOperand";
    let ParserMatchClass = SPOffsetImm5x4AsmOperand;
}

// Instruction operand types
def immSExt5    : Operand<i32>, ImmLeaf<i32, [{ return isInt<5>(Imm); }]>;
def immSExt6    : Operand<i32>, ImmLeaf<i32, [{ return isInt<6>(Imm); }]>;
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
def immZExt32 : Operand<i32>, ImmLeaf<i32, [{ return isUInt<32>(Imm); }]>;

def immBit : Operand<i32>, ImmLeaf<i32, [{ return Imm != 0 && isPowerOf2_32(Imm); }], bit_xform>;

// Addressing modes
def ADDRspii : ComplexPattern<i32, 2, "SelectADDRspii", [frameindex], []>;

// Address operand
def MEMii : Operand<i32> {
  let MIOperandInfo = (ops i32imm, i32imm);
}

// Branch target
def brtarget8 : Operand<OtherVT>, ImmLeaf<i8, [{}], div2>;
def brtarget : Operand<OtherVT>;

// These are target-independent nodes, but have target-specific formats.
def SDT_VC4CallSeqStart : SDCallSeqStart<[ SDTCisVT<0, i32> ]>;
def SDT_VC4CallSeqEnd   : SDCallSeqEnd<[ SDTCisVT<0, i32>, SDTCisVT<1, i32> ]>;

def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_VC4CallSeqStart, [SDNPHasChain, SDNPOutGlue]>;
def callseq_end : SDNode<"ISD::CALLSEQ_END", SDT_VC4CallSeqEnd, [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;


//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

// No operands
class _S16_simple<bits<4> opc, string asmstr> : _S16_0<{ 0b00000000000, opc}, asmstr>;
def BKPT   : _S16_simple<0b0000, "bkpt">;
def NOP    : _S16_simple<0b0001, "nop">;
def SLEEP  : _S16_simple<0b0010, "sleep">;
def USER   : _S16_simple<0b0011, "user">;
def EI     : _S16_simple<0b0100, "ei">;
def DI     : _S16_simple<0b0101, "di">;
def CBCLR  : _S16_simple<0b0110, "cbclr">;
def CBADD1 : _S16_simple<0b0111, "cbadd1">;
def CBADD2 : _S16_simple<0b1000, "cbadd2">;
def CBADD3 : _S16_simple<0b1001, "cbadd3">;
def RTI    : _S16_simple<0b1010, "rti">;

// Software Interrupt - Raise 0x20+(rd & 0x1f)
multiclass _SWI {
  // 0000 0000 001d dddd - swi rd    Software Interrupt.  Raise interrupt 0x20+(rd&0x1f)
  def _1r5 : _S16_1r5<0b0000000001, (outs), (ins ERegs:$rd), "swi $rd", []>;
  // 0000 0001 11uu uuuu - swi u
  def _i6 : _S16_i6<0b000000111, (outs), (ins immZExt6:$imm), "swi $imm", []>;
}
defm SWI : _SWI;

// Table branch byte.  pc = pc + 2*(*(s8 *)(pc+rd))
// 0000 0000 1000 dddd
def SWITCHB : _S16_1r4<0b00000001000, (outs), (ins GRegs:$rd), "switch.b\t$rd", []>;

// Table branch short. pc = pc + 2*(*(s16 *)(pc+rd))
// 0000 0000 1010 dddd
def SWITCH : _S16_1r4<0b00000001010, (outs), (ins GRegs:$rd), "switch\t$rd", []>;

// Version - Get cpu version and core number.
class VERSION_DESC {
  dag OutOperandList = (outs ERegs:$rd);
  string AsmString = "version\t$rd";
  string BaseOpcode = "version";
}

// 0000 0000 111d dddd
def VERSION : _S16_1r5<0b0000000111, (outs ERegs:$rd), (ins), "version\t$rd", []>;

//===----------------------------------------------------------------------===//
// ALU Instructions
//===----------------------------------------------------------------------===//
include "VC4InstrALU.td"


//===----------------------------------------------------------------------===*/
// Add register + immediate
//===----------------------------------------------------------------------===*/

multiclass _ADD {
  // 1011 01ss sssd dddd iiii iiii iiii iiii   add rd, rs, i
  def _2r5i16 : _S32_2r5i16<0b01101, (outs ERegs:$rd), (ins ERegs:$rs, immSExt16:$imm),
                  "add\t$rd, $rs, $imm",
                  [(set ERegs:$rd, (add ERegs:$rs, immSExt16:$imm))]>;

  // 1110 11ss sssd dddd uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
  def _2r5i32 : _S48_2r5i32<0b11, (outs ERegs:$rd), (ins ERegs:$rs, immZExt32:$imm),
                  "add\t$rd, $rs, $imm",
                  [(set ERegs:$rd, (add ERegs:$rs, immZExt32:$imm))]>;
}

defm ADD : _ADD;

multiclass _ADDpc {
  // 1011 1111 111d dddd oooo oooo oooo oooo   add rd, pc, o
  def _1r5i16 : _S32_1r5i16<0b0111111111, (outs ERegs:$rd), (ins immSExt16:$imm),
                 "add\t$rd, pc, $imm",
                 []>;

  // 1110 0101 000d dddd oooo oooo oooo oooo oooo oooo oooo oooo   add rd, pc, o                      rd = pc + o
  def _1r5i32 : _S48_1r5i32<0b0101000, (outs ERegs:$rd), (ins immZExt32:$imm),
                  "add\t$rd, pc, $imm",
                  []>;
}

defm ADDpc : _ADDpc;

// 0001 0ooo oood dddd - add  rd, sp, o*4     rd = sp + o*4
def ADDsp_1r5i6 : _S16_1r5i6<0b0010, (outs ERegs:$rd), (ins immSExt6x4:$imm),
                             "add\t$rd, sp, $imm",
                             []>;

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
let isBranch = 1, isTerminator = 1 in {
// 0001 1111 0ooo oooo -
def B_o8: _S16_i7<0b00111110, (outs), (ins brtarget8:$imm), "b\t$imm", []>;
// 1110 0001 0000 0000 oooo oooo oooo oooo oooo oooo oooo oooo   b $+o                              Branch to target.
def B_o32: _S48_i32<0b000100000000, (outs), (ins brtarget:$imm), "b\t$imm", []>;
}

//===----------------------------------------------------------------------===//
// Indirect branch

// Indirect branch - b $rd
let isBranch = 1, isIndirectBranch = 1, isTerminator = 1, isBarrier = 1 in {
  def BRIND_1r5 : _S16_1r5<0b0000000010, (outs), (ins ERegs:$rd), "b\t$rd", [(brind ERegs:$rd)]>;
}

multiclass _BL {
  def _1r5 : _S16_1r5<0b0000000011, (outs), (ins ERegs:$rd), "bl\t$rd", []>;
  def _o28 : _S32_i27<0b001, 0b1, (outs), (ins immSExt27x2:$imm), "bl\t$imm", []>;
  def _o32 : _S48_i32<0b001100000000, (outs), (ins immSExt32:$imm), "bl\t$imm", []>;
}

// Branch and Link - bl rd; bl $+o
let isCall=1, Defs = [R0, R1, R2, R3, R4, R5, LR] in {
  defm BL : _BL;
}

//===----------------------------------------------------------------------===//
// Conditional Branch

// 0001 1ccc cooo oooo - b<cc> $+2*o
class _BCC_o8<VC4CondCode cc, string instr_asm>
    : _S16_i7<{0b0011, cc.Value{3-0}}, (outs), (ins brtarget:$imm),
              instr_asm # "\t$imm", []>;

// 1001 cccc 0ooo oooo oooo oooo oooo oooo - b<cc> $+2*o
class _BCC_o24<VC4CondCode cc, string instr_asm>
    : _S32_i23<{0b001, cc.Value{3-0}, 0b0}, (outs), (ins brtarget:$imm),
              instr_asm # "\t$imm", []>;

multiclass _BCC<VC4CondCode cc, string instr_asm> {
  def _o8 : _BCC_o8<cc, instr_asm>;
  def _o24 : _BCC_o24<cc, instr_asm>;
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

let Uses = [SP] in {
  let mayLoad = 1 in {
// 0000 010o oooo dddd - ld    rd, (sp+o*4)   Load from memory relative to stack pointer.
    def LDWSP_1r4o7 : _S16_1r4i5<0b000010, (outs GRegs:$rd), (ins spoffset5x4_imm:$imm),
                                 "ld\t$rd, (sp+$imm)",
                                 [(set GRegs:$rd, (ldwsp spoffset5x4_imm:$imm))]>;
// 1010 1001 000d dddd oooo oooo oooo oooo   ld rd, (sp+o)
    def LDWSP_1r5o16 : _S32_1r5i16<0b0101001000, (outs ERegs:$rd), (ins i32imm:$imm),
                                   "ld\t$rd, (sp+$imm)",
                                   [(set ERegs:$rd, (ldwsp immSExt16:$imm))]>;
// 1110 0110 000d dddd 1100 1ooo oooo oooo oooo oooo oooo oooo   ld<w>  rd, (rs+o)
    def LDWSP_1r5o27 : _S48_1r5i27<0b0110000, 0b11001, (outs ERegs:$rd), (ins i32imm:$imm),
                                   "ld\t$rd, (sp+$imm)",
                                   [(set ERegs:$rd, (ldwsp immSExt32:$imm))]>;
  }

  let mayStore = 1 in {
// 0000 011o oooo dddd - st    rd, (sp+o*4)   Store to memory relative to stack pointer.
    def STWSP_1r4o7 : _S16_1r4i5<0b000011, (outs), (ins GRegs:$rd, spoffset5x4_imm:$imm),
                                 "st\t$rd, (sp+$imm)",
                                 [(stwsp GRegs:$rd, spoffset5x4_imm:$imm)]>;
// 1010 1001 001d dddd oooo oooo oooo oooo   st<w> rd, (sp+o)
    def STWSP_1r5o16 : _S32_1r5i16<0b0101001001, (outs), (ins ERegs:$rd, i32imm:$imm),
                                   "st\t$rd, (sp+$imm)",
                                   [(stwsp ERegs:$rd, immSExt16:$imm)]>;
// 1110 0110 001d dddd 1100 1ooo oooo oooo oooo oooo oooo oooo   st<w>  rd, (rs+o)
    def STWSP_1r5o27 : _S48_1r5i27<0b0110001, 0b11001, (outs), (ins ERegs:$rd, i32imm:$imm),
                                   "st\t$rd, (sp+$imm)",
                                   [(stwsp ERegs:$rd, immSExt32:$imm)]>;
  }
}


//===----------------------------------------------------------------------===//
// Return Instructions
//===----------------------------------------------------------------------===//

def VC4retflag : SDNode<"VC4ISD::RET_FLAG", SDTNone,
                        [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

let isTerminator = 1, isReturn = 1, isBarrier = 1, Uses = [LR] in {
  def BLR_RET : _S16_0<0b000000001011010, "b\tlr", [(VC4retflag)]>;
}

//===----------------------------------------------------------------------===//
// Pseudo Instructions
//===----------------------------------------------------------------------===//

let Defs=[SP], Uses=[SP] in {
def ADJCALLSTACKDOWN : VC4PseudoInst<(outs), (ins i32imm:$amt),
                                     "# ADJCALLSTACKDOWN $amt",
                                     [(callseq_start timm:$amt)]>;
def ADJCALLSTACKUP : VC4PseudoInst<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                                   "# ADJCALLSTACKUP $amt1",
                                   [(callseq_end timm:$amt1, timm:$amt2)]>;
}

// Load Word from Frame Index
def LDWFI : VC4PseudoInst<(outs ERegs:$dst), (ins MEMii:$addr),
                          "# LDWFI $dst, $addr",
                          [(set ERegs:$dst, (load ADDRspii:$addr))]>;

def STWFI : VC4PseudoInst<(outs), (ins ERegs:$src, MEMii:$addr),
                          "# STWFI $src, $addr",
                          [(store ERegs:$src, ADDRspii:$addr)]>;
