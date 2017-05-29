//===-- VC4InstrFormats.td - VideoCore IV Instruction Formats -*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

class LoadStoreWidth<bits<2> val> {
  bits<2> Value = val;
}
def LSWu32   : LoadStoreWidth<0>;
def LSWu16   : LoadStoreWidth<1>;
def LSWu8    : LoadStoreWidth<2>;
def LSWs16s8 : LoadStoreWidth<3>;

class VC4CondCode<bits<4> val> {
  bits<4> Value = val;
}

def VC4CC_eq   : VC4CondCode<0b0000>; // == 0
def VC4CC_ne   : VC4CondCode<0b0001>; // != 0
def VC4CC_cslo : VC4CondCode<0b0010>; // Unsigned <
def VC4CC_cchi : VC4CondCode<0b0011>; // Unsigned >=
def VC4CC_mi   : VC4CondCode<0b0100>; // Negative
def VC4CC_pl   : VC4CondCode<0b0101>; // Positive
def VC4CC_vs   : VC4CondCode<0b0110>; // Overflow set
def VC4CC_vc   : VC4CondCode<0b0111>; // Overflow clear
def VC4CC_hi   : VC4CondCode<0b1000>; // Unsigned >
def VC4CC_ls   : VC4CondCode<0b1001>; // Unsigned <=
def VC4CC_ge   : VC4CondCode<0b1010>; // Signed >=
def VC4CC_lt   : VC4CondCode<0b1011>; // Signed <
def VC4CC_gt   : VC4CondCode<0b1100>; // Signed >
def VC4CC_le   : VC4CondCode<0b1101>; // Signed <=
def VC4CC_t    : VC4CondCode<0b1110>; // Always
def VC4CC_f    : VC4CondCode<0b1111>; // Never

class VC4ALUOp<bits<6> val> {
  bits<6> Value = val;
}

def VC4ALU_mov         : VC4ALUOp<0b000000>; // rd = ra                         - Move
def VC4ALU_cmn         : VC4ALUOp<0b000001>; // ZNCV = cc(rd + ra)              - Compare by addition
def VC4ALU_add         : VC4ALUOp<0b000010>; // rd = rd + ra                    - Add
def VC4ALU_bic         : VC4ALUOp<0b000011>; // rd = rd & ~ra                   - Logical bit clear
def VC4ALU_mul         : VC4ALUOp<0b000100>; // rd = rd * ra                    - Multiply
def VC4ALU_xor         : VC4ALUOp<0b000101>; // rd = rd ^ ra                    - Exclusive Or
def VC4ALU_sub         : VC4ALUOp<0b000110>; // rd = rd                         - ra - Subtract
def VC4ALU_and         : VC4ALUOp<0b000111>; // rd = rd & ra                    - Logical And
def VC4ALU_not         : VC4ALUOp<0b001000>; // rd = ~ra                        - Not
def VC4ALU_ror         : VC4ALUOp<0b001001>; // rd = ror(rd, ra)                - Rotate right
def VC4ALU_cmp         : VC4ALUOp<0b001010>; // ZNCV = cc(rd - ra)              - Compare
def VC4ALU_rsub        : VC4ALUOp<0b001011>; // rd = ra - rd                    - Reverse subtract
def VC4ALU_btest       : VC4ALUOp<0b001100>; // Z = rd & bit(ra) == 0           - Bit test
def VC4ALU_or          : VC4ALUOp<0b001101>; // rd = rd | ra                    - Logical Or
def VC4ALU_bmask       : VC4ALUOp<0b001110>; // rd = rd & mask(ra)              - Mask left most bits
def VC4ALU_max         : VC4ALUOp<0b001111>; // rd = max(rd, ra)                - Maximum
def VC4ALU_bitset      : VC4ALUOp<0b010000>; // rd = rd | bit(ra)               - Bit set
def VC4ALU_min         : VC4ALUOp<0b010001>; // rd = min(rd, ra)                - Minimum
def VC4ALU_bitclear    : VC4ALUOp<0b010010>; // rd = rd & ~bit(ra)              - Bit clear
def VC4ALU_addscale2   : VC4ALUOp<0b010011>; // rd = rd + 2*ra                  - Add scaled by 2
def VC4ALU_bitflip     : VC4ALUOp<0b010100>; // rd = rd ^ bit(ra)               - Bit flip
def VC4ALU_addscale4   : VC4ALUOp<0b010101>; // rd = rd + 4*ra                  - Add scaled by 4
def VC4ALU_addscale8   : VC4ALUOp<0b010110>; // rd = rd + 8*ra                  - Add scaled by 8
def VC4ALU_addscale16  : VC4ALUOp<0b010111>; // rd = rd + 16*ra                 - Add scaled by 16
def VC4ALU_signext     : VC4ALUOp<0b011000>; // rd = sign_extend(rd & mask(ra)) - Mask left most bits and signed extend
def VC4ALU_neg         : VC4ALUOp<0b011001>; // rd = -ra                        - Negate
def VC4ALU_lsr         : VC4ALUOp<0b011010>; // rd = rd >> ra                   - Logical shift right
def VC4ALU_msb         : VC4ALUOp<0b011011>; // rd = msb(ra)                    - Position of most significant 1 bit, (msb(0) == -1)
def VC4ALU_shl         : VC4ALUOp<0b011100>; // rd = rd << ra                   - Logical shift left
def VC4ALU_brev        : VC4ALUOp<0b011101>; // rd = reverse(rd) >> (32 - ra)   - Reverse bits and shift right
def VC4ALU_asr         : VC4ALUOp<0b011110>; // rd = rd >> ra                   - Arithmetic shift right
def VC4ALU_abs         : VC4ALUOp<0b011111>; // rd = abs(ra)                    - Absolute value

def VC4ALU_mulhdss     : VC4ALUOp<0b100000>; // High half of 32x32 -> 64-bit product; ra, rb both signed
def VC4ALU_mulhdsu     : VC4ALUOp<0b100001>; // High half of 32x32 -> 64-bit product; ra is signed, rb is unsigned
def VC4ALU_mulhdus     : VC4ALUOp<0b100010>; // High half of 32x32 -> 64-bit product; ra is unsigned, rb is signed
def VC4ALU_mulhduu     : VC4ALUOp<0b100011>; // High half of 32x32 -> 64-bit product; ra, rb both unsigned
def VC4ALU_divss       : VC4ALUOp<0b100100>; // Divide; ra, rb both signed
def VC4ALU_divsu       : VC4ALUOp<0b100101>; // Divide; ra is signed, rb is unsigned
def VC4ALU_divus       : VC4ALUOp<0b100110>; // Divide; ra is unsigned, rb is signed
def VC4ALU_divuu       : VC4ALUOp<0b100111>; // Divide; ra, rb both unsigned
def VC4ALU_adds        : VC4ALUOp<0b101000>; // rd = saturate32(ra + rb) - Add with Saturate
def VC4ALU_subs        : VC4ALUOp<0b101001>; // rd = saturate32(ra - rb) - Sub with Saturate
def VC4ALU_shls        : VC4ALUOp<0b101010>; // rd = saturate32(ra << rb) - Shift left with Saturate
def VC4ALU_clipsh      : VC4ALUOp<0b101011>; // rd = saturate16(rb) - Clip to Half with Saturate
def VC4ALU_addscale32  : VC4ALUOp<0b101100>; // rd = ra + 32*rb - Add scaled by 32
def VC4ALU_addscale64  : VC4ALUOp<0b101101>; // rd = ra + 64*rb - Add scaled by 64
def VC4ALU_addscale128 : VC4ALUOp<0b101110>; // rd = ra + 128*rb - Add scaled by 128
def VC4ALU_addscale256 : VC4ALUOp<0b101111>; // rd = ra + 256*rb - Add scaled by 256
def VC4ALU_count       : VC4ALUOp<0b110000>; // rd = count(rb) - Population Count
def VC4ALU_subscale2   : VC4ALUOp<0b110001>; // rd = ra - 2*rb - Sub scaled by 2
def VC4ALU_subscale4   : VC4ALUOp<0b110010>; // rd = ra - 4*rb - Sub scaled by 4
def VC4ALU_subscale8   : VC4ALUOp<0b110011>; // rd = ra - 8*rb - Sub scaled by 8
def VC4ALU_subscale16  : VC4ALUOp<0b110100>; // rd = ra - 16*rb - Sub scaled by 16
def VC4ALU_subscale32  : VC4ALUOp<0b110101>; // rd = ra - 32*rb - Sub scaled by 32
def VC4ALU_subscale64  : VC4ALUOp<0b110110>; // rd = ra - 64*rb - Sub scaled by 64
def VC4ALU_subscale128 : VC4ALUOp<0b110111>; // rd = ra - 128*rb - Sub scaled by 128
def VC4ALU_subscale256 : VC4ALUOp<0b111000>; // rd = ra - 256*rb - Sub scaled by 256

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//
class VC4Inst<int sz, dag outs, dag ins, string asmstr, list<dag> pattern>
    : Instruction {
  field bits<48> Inst;

  let Namespace = "VC4";
  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = asmstr;
  let Pattern = pattern;
  let Size = sz;

  field bits<16> SoftFail = 0;
}

class VC4PseudoInst<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<0, outs, ins, asmstr, pattern> {
  let isPseudo = 1;
}

// Instruction formats

//===----------------------------------------------------------------------===//
// Instruction meta-classes
//===----------------------------------------------------------------------===//

class VC4Scalar16<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<2, outs, ins, asmstr, pattern> {
  let Inst{15} = 0;
}

class VC4Scalar32<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<4, outs, ins, asmstr, pattern> {
  let Inst{31} = 1;
}

class VC4Scalar48<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<6, outs, ins, asmstr, pattern> {
  let Inst{47-44} = 0b1110;
}

//===----------------------------------------------------------------------===//
// 16-bit Scalar Instructions
//===----------------------------------------------------------------------===//

class S16_1r4<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar16<outs, ins, asmstr, pattern> {
  bits<4> rd;

  let Inst{3-0} = rd;
}

class S16_1r4imm5<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar16<outs, ins, asmstr, pattern> {
  bits<5> imm;

  let Inst{8-4} = imm;

  let DecoderMetho
}

class S16_1r5<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar16<outs, ins, asmstr, pattern> {
  bits<5> rd;

  let Inst{4-0} = rd;
}

class S16_1r5imm6<dag outs, dag ins, string asmstr, list<dag> pattern>
    : S16_1r5<outs, ins, asmstr, pattern> {
  bits<5> imm;

  let Inst{9-5} = imm;
}

class S16_2r4<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar16<outs, ins, asmstr, pattern> {
  bits<4> rd;
  bits<4> rs;

  let Inst{7-4} = rs;
  let Inst{3-0} = rd;
}

class S16_2r4imm4<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar16<outs, ins, asmstr, pattern> {
  bits<4> imm;

  let Inst{12-9} = imm;
}

class S16_bcc<bits<4> cc, dag outs, dag ins, string asmstr, list<dag> pattern>
  : VC4Scalar16<outs, ins, asmstr, pattern> {
  bits<7> o;

  let Inst{14-11} = 0b0011;
  let Inst{10-7} = cc;
  let Inst{6-0} = o;

  let DecoderMethod = "DecodeBccInstruction";
}

//===----------------------------------------------------------------------===//
// 32-bit Scalar Instructions
//===----------------------------------------------------------------------===//
class S32_addcmpbcc<VC4CondCode cc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar32<outs, ins, asmstr, pattern> {
  bits<4> rd;

  let Inst{30-28} = 0b000;
  let Inst{27-24} = cc.Value;
  let Inst{19-16} = rd;
}

class S32_1r5imm16<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar32<outs, ins, asmstr, pattern> {
  bits<5>  rd;
  bits<16> imm;

  let Inst{20-16} = rd;
  let Inst{15-0} = imm;
}

class S32_1r5off16<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar32<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<16> off;

  let Inst{20-16} = rd;
  let Inst{15-0} = off;
}

class S32_2r5imm16<dag outs, dag ins, string asmstr, list<dag> pattern>
    : S32_1r5imm16<outs, ins, asmstr, pattern> {
  bits<5> rs;

  let Inst{25-21} = rs;
}

// 1100 0ooo oood dddd aaaa accc c1ii iiii
class S32_cc2r5imm6<VC4CondCode cc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar32<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<5> ra;
  bits<6> imm;

  let Inst{20-16} = rd;
  let Inst{15-11} = ra;
  let Inst{10-7}  = cc.Value;
  let Inst{6}     = 0b1;
  let Inst{5-0}   = imm;

  let DecoderMethod = "DecodeCC2R5Imm6Instruction";
}

// 1100 0ooo oood dddd aaaa accc c00b bbbb
class S32_cc3r5<VC4CondCode cc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Scalar32<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<5> ra;
  bits<5> rb;

  let Inst{20-16} = rd;
  let Inst{15-11} = ra;
  let Inst{10-7}  = cc.Value;
  let Inst{6-5}   = 0b00;
  let Inst{4-0}   = rb;

  let DecoderMethod = "DecodeCC3R5Instruction";
}

//===----------------------------------------------------------------------===//
// 48-bit Scalar Instructions
//===----------------------------------------------------------------------===//
