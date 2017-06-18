// -*- tablegen -*- //

// VideoCore-IV ALU instructions

class VC4ALU<bits<6> val, string opcode, string suffix = ""> {
  bits<6> Value = val;
  string OpCode = opcode;
  string AsmSuffix = suffix;
}

// Move                - rd = ra
def VC4ALU_mov         : VC4ALU<0b000000, "mov">;
// Add                 - rd = rd + ra
def VC4ALU_add         : VC4ALU<0b000010, "add">;
// Multiply            - rd = rd * ra
def VC4ALU_mul         : VC4ALU<0b000100, "mul">;
// Subtract            - rd = rd - ra
def VC4ALU_sub         : VC4ALU<0b000110, "sub">;
// Not                 - rd = ~ra
def VC4ALU_not         : VC4ALU<0b001000, "not">;
// Compare             - ZNCV = cc(rd - ra)
def VC4ALU_cmp         : VC4ALU<0b001010, "cmp">;
// Bit test            - Z = rd & bit(ra) == 0
def VC4ALU_btest       : VC4ALU<0b001100, "btest">;
// Mask left most bits - rd = rd & mask(ra)
def VC4ALU_bmask       : VC4ALU<0b001110, "bmask">;
// Bit set             - rd = rd | bit(ra)
def VC4ALU_bitset      : VC4ALU<0b010000, "bitset">;
// Bit clear           - rd = rd & ~bit(ra)
def VC4ALU_bitclear    : VC4ALU<0b010010, "bitclear">;
// Bit flip            - rd = rd ^ bit(ra)
def VC4ALU_bitflip     : VC4ALU<0b010100, "bitflip">;
// Add scaled by 8     - rd = rd + 8*ra
def VC4ALU_addscale8   : VC4ALU<0b010110, "addscale", " << 3">;
// Mask left most bits and signed extend - rd = sign_extend(rd & mask(ra))
def VC4ALU_signext     : VC4ALU<0b011000, "signext">;
// Logical shift right - rd = rd >> ra
def VC4ALU_lsr         : VC4ALU<0b011010, "lsr">;
// Logical shift left  - rd = rd << ra
def VC4ALU_shl         : VC4ALU<0b011100, "shl">;
// Arithmetic shift right - rd = rd >> ra
def VC4ALU_asr         : VC4ALU<0b011110, "asr">;

// Compare by addition - ZNCV = cc(rd + ra)
def VC4ALU_cmn         : VC4ALU<0b000001, "cmn">;
// Logical bit clear   - rd = rd & ~ra
def VC4ALU_bic         : VC4ALU<0b000011, "bic">;
// Exclusive Or        - rd = rd ^ ra
def VC4ALU_eor         : VC4ALU<0b000101, "eor">;
// Logical And         - rd = rd & ra
def VC4ALU_and         : VC4ALU<0b000111, "and">;
// Rotate right - rd = ror(rd, ra)
def VC4ALU_ror         : VC4ALU<0b001001, "ror">;
// rd                    - Reverse subtract - rd = ra
def VC4ALU_rsub        : VC4ALU<0b001011, "rsub">;
// Logical Or - rd = rd | ra
def VC4ALU_or          : VC4ALU<0b001101, "or">;
// Maximum - rd = max(rd, ra)
def VC4ALU_max         : VC4ALU<0b001111, "max">;
// Minimum - rd = min(rd, ra)
def VC4ALU_min         : VC4ALU<0b010001, "min">;
// Add scaled by 2 - rd = rd + 2*ra
def VC4ALU_addscale2   : VC4ALU<0b010011, "addscale", " << 1">;
// Add scaled by 4 - rd = rd + 4*ra
def VC4ALU_addscale4   : VC4ALU<0b010101, "addscale", " << 2">;
// Add scaled by 16 - rd = rd + 16*ra
def VC4ALU_addscale16  : VC4ALU<0b010111, "addscale", " << 4">;
// a                        - Negate - rd =
def VC4ALU_neg         : VC4ALU<0b011001, "neg">;
// Position of most significant 1 bit, (msb(0) == -1) - rd = msb(ra)
def VC4ALU_msb         : VC4ALU<0b011011, "msb">;
// ra)   - Reverse bits and shift right - rd = reverse(rd) >> (32
def VC4ALU_brev        : VC4ALU<0b011101, "brev">;
// Absolute value - rd = abs(ra)
def VC4ALU_abs         : VC4ALU<0b011111, "abs">;

// 6-bit opcodes
// High half of 32x32 -> 64-bit product; ra, rb both signed
def VC4ALU_mulhdss     : VC4ALU<0b100000, "mulhd.ss">;
// High half of 32x32 -> 64-bit product; ra is signed, rb is unsigned
def VC4ALU_mulhdsu     : VC4ALU<0b100001, "mulhd.su">;
// High half of 32x32 -> 64-bit product; ra is unsigned, rb is signed
def VC4ALU_mulhdus     : VC4ALU<0b100010, "mulhd.us">;
// High half of 32x32 -> 64-bit product; ra, rb both unsigned
def VC4ALU_mulhduu     : VC4ALU<0b100011, "mulhs.uu">;
// Divide; ra, rb both signed
def VC4ALU_divss       : VC4ALU<0b100100, "div.ss">;
// Divide; ra is signed, rb is unsigned
def VC4ALU_divsu       : VC4ALU<0b100101, "div.su">;
// Divide; ra is unsigned, rb is signed
def VC4ALU_divus       : VC4ALU<0b100110, "div.us">;
// Divide; ra, rb both unsigned
def VC4ALU_divuu       : VC4ALU<0b100111, "div.uu">;
// rd = saturate32(ra + rb) - Add with Saturate
def VC4ALU_adds        : VC4ALU<0b101000, "adds">;
// rd = saturate32(ra - rb) - Sub with Saturate
def VC4ALU_subs        : VC4ALU<0b101001, "subs">;
// rd = saturate32(ra << rb) - Shift left with Saturate
def VC4ALU_shls        : VC4ALU<0b101010, "shls">;
// rd = saturate16(rb) - Clip to Half with Saturate
def VC4ALU_clipsh      : VC4ALU<0b101011, "clipsh">;
// rd = ra + 32*rb - Add scaled by 32
def VC4ALU_addscale32  : VC4ALU<0b101100, "addscale", " << 5">;
// rd = ra + 64*rb - Add scaled by 64
def VC4ALU_addscale64  : VC4ALU<0b101101, "addscale", " << 6">;
// rd = ra + 128*rb - Add scaled by 128
def VC4ALU_addscale128 : VC4ALU<0b101110, "addscale", " << 7">;
// rd = ra + 256*rb - Add scaled by 256
def VC4ALU_addscale256 : VC4ALU<0b101111, "addscale", " << 8">;
// rd = count(rb) - Population Count
def VC4ALU_count       : VC4ALU<0b110000, "count">;
// rd = ra - 2*rb - Sub scaled by 2
def VC4ALU_subscale2   : VC4ALU<0b110001, "subscale", " << 1">;
// rd = ra - 4*rb - Sub scaled by 4
def VC4ALU_subscale4   : VC4ALU<0b110010, "subscale", " << 2">;
// rd = ra - 8*rb - Sub scaled by 8
def VC4ALU_subscale8   : VC4ALU<0b110011, "subscale", " << 3">;
// rd = ra - 16*rb - Sub scaled by 16
def VC4ALU_subscale16  : VC4ALU<0b110100, "subscale", " << 4">;
// rd = ra - 32*rb - Sub scaled by 32
def VC4ALU_subscale32  : VC4ALU<0b110101, "subscale", " << 5">;
// rd = ra - 64*rb - Sub scaled by 64
def VC4ALU_subscale64  : VC4ALU<0b110110, "subscale", " << 6">;
// rd = ra - 128*rb - Sub scaled by 128
def VC4ALU_subscale128 : VC4ALU<0b110111, "subscale", " << 7">;
// rd = ra - 256*rb - Sub scaled by 256
def VC4ALU_subscale256 : VC4ALU<0b111000, "subscale", " << 8">;

class BinOpFrag<dag res> : PatFrag<(ops node:$LHS, node:$RHS), res>;

//***----------------------------------------------------------------------***//
// 4-bit opcode instructions
//***----------------------------------------------------------------------***//

let Constraints = "$ra = $rd" in {
// Rd = Rd <op> u - 011p pppu uuuu dddd
class _ALU_1r4i5<VC4ALU opc>
    : _S16_1r4i5<{0b11, opc.Value{4-1}}, (outs GRegs:$rd), (ins GRegs:$ra, immZExt5:$imm),
                 opc.OpCode # "\t$rd, $imm" # opc.AsmSuffix, []>;

//***----------------------------------------------------------------------***//
// 5-bit opcode instructions
//***----------------------------------------------------------------------***//

// Rd = Rd <op> Ra - 010p pppp ssss dddd
class _ALU_2r4<VC4ALU opc>
    : _S16_2r4<{0b10, opc.Value{4-0}}, (outs GRegs:$rd), (ins GRegs:$ra, GRegs:$rb),
               opc.OpCode # "\t$ra, $rb" # opc.AsmSuffix, []>;

// Rd = Rd <op> i - 1011 00pp pppd dddd iiii iiii iiii iiii
class _ALU_1r5i16<VC4ALU opc>
    : _S32_1r5i16<{0b01100, opc.Value{4-0}}, (outs ERegs:$rd), (ins ERegs:$ra, immSExt16:$imm),
                  opc.OpCode # "\t$rd, $imm" # opc.AsmSuffix, []>;

// Rd = Rd <op> u - 1110 10pp pppd dddd uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
class _ALU_1r5i32<VC4ALU opc>
    : _S48_1r5i32<{0b10, opc.Value{4-0}}, (outs ERegs:$rd), (ins ERegs:$ra, immSExt32:$imm),
                  opc.OpCode # "\t$rd, $imm" # opc.AsmSuffix, []>;
} // let Constraints

//***----------------------------------------------------------------------***//
// 6-bit opcode instructions
//***----------------------------------------------------------------------***//

// 1100 0ppp pppd dddd aaaa accc c1ii iiii
class _ALU_2r5i6<VC4ALU opc>
    : _S32_2r5i6<{0b1000, opc.Value{5-0}}, 0b00001, (outs ERegs:$rd), (ins ERegs:$ra, immSExt6:$imm),
                 opc.OpCode # ".{p}\t$rd, $ra, $imm" # opc.AsmSuffix, []> {
  bits<4> p;

  let Inst{10-7} = p;
}

// 1100 0ppp pppd dddd aaaa accc c00b bbbb
class _ALU_3r5<VC4ALU opc>
    : _S32_3r5<{0b1000, opc.Value{5-0}}, 0b000000, (outs ERegs:$rd), (ins ERegs:$ra, ERegs:$rb),
               opc.OpCode # ".{p}\t$rd, $ra, $rb" # opc.AsmSuffix, []> {
  bits<4> p;

  let Inst{10-7} = p;
}

//===----------------------------------------------------------------------===//
// ALU operations defined by 0....0 pattern
//===----------------------------------------------------------------------===//
multiclass _ALU4<VC4ALU opc, bit commutable = 0> {
  let isReMaterializable = 1 in {
  def _1r4i5  : _ALU_1r4i5<opc>;
  def _1r5i16 : _ALU_1r5i16<opc>;
  def _1r5i32 : _ALU_1r5i32<opc>;
  }
  def _2r4    : _ALU_2r4<opc>;
  // Register-immediate version is re-materializable.
  let isReMaterializable = 1 in
  def _2r5i6  : _ALU_2r5i6<opc>;
  def _3r5    : _ALU_3r5<opc> {
    let isCommutable = commutable;
  }
}

multiclass _ALU4U<VC4ALU opc> {
  let isReMaterializable = 1 in {
  def _1r4i5  : _ALU_1r4i5<opc>;
  def _1r5i16 : _ALU_1r5i16<opc>;
  def _1r5i32 : _ALU_1r5i32<opc>;
  }
  def _2r4    : _ALU_2r4<opc>;
  // Register-immediate version is re-materializable.
  let isReMaterializable = 1 in
  def _2r5i6  : _ALU_2r5i6<opc> {
    let TwoOperandAliasConstraint = "$ra = $rd";
  }
  def _3r5    : _ALU_3r5<opc> {
    let TwoOperandAliasConstraint = "$ra = $rb";
  }
}

//===----------------------------------------------------------------------===//
// ALU operations defined by 0..... pattern
//===----------------------------------------------------------------------===//
multiclass _ALU5<VC4ALU alu, bit commutable = 0> {
  let isReMaterializable = 1 in {
  def _1r5i16 : _ALU_1r5i16<alu>;
  def _1r5i32 : _ALU_1r5i32<alu>;
  }
  def _2r4    : _ALU_2r4<alu>;
  // Register-immediate version is re-materializable.
  let isReMaterializable = 1 in
  def _2r5i6  : _ALU_2r5i6<alu>;
  def _3r5    : _ALU_3r5<alu> {
    let isCommutable = commutable;
  }
}

multiclass _ALU5U<VC4ALU opc> {
  let isReMaterializable = 1 in {
  def _1r5i16 : _ALU_1r5i16<opc>;
  def _1r5i32 : _ALU_1r5i32<opc>;
  }
  def _2r4    : _ALU_2r4<opc>;
  // Register-immediate version is re-materializable.
  let isReMaterializable = 1 in
  def _2r5i6  : _ALU_2r5i6<opc> {
    let TwoOperandAliasConstraint = "$ra = $rd";
  }
  def _3r5    : _ALU_3r5<opc> {
    let TwoOperandAliasConstraint = "$ra = $rb";
  }
}

//===----------------------------------------------------------------------===//
// ALU operations defined by ...... pattern
//===----------------------------------------------------------------------===//
multiclass _ALU6<VC4ALU alu, bit commutable = 0> {
  // Register-immediate version is re-materializable.
  let isReMaterializable = 1 in
  def _2r5i6 : _ALU_2r5i6<alu>;
  def _3r5 : _ALU_3r5<alu> {
    let isCommutable = commutable;
  }
}

//***----------------------------------------------------------------------***/
// Move
//***----------------------------------------------------------------------***/

// Load constants into registers
def MOV_1r4u5 : _S16_1r4i5<0b110000, (outs GRegs:$rd), (ins i32imm:$imm),
                           "mov\t$rd, $imm",
                           [(set GRegs:$rd, immZExt5:$imm)]>;

def MOV_1r5i16 : _S32_1r5i16<0b0110000000, (outs ERegs:$rd), (ins i32imm:$imm),
                             "mov\t$rd, $imm",
                             [(set ERegs:$rd, immSExt16:$imm)]>;

def MOV_1r5i32 : _S48_1r5i32<0b1000000, (outs ERegs:$rd), (ins i32imm:$imm),
                             "mov\t$rd, $imm",
                             [(set ERegs:$rd, immSExt32:$imm)]>;

// Move register to register
def MOV_2r4  : _S16_2r4<0b1000000, (outs GRegs:$rd), (ins GRegs:$rb),
                        "mov\t$rd, $rb", []>;


def MOV_2r5 : _S32_3r5<0b1000000000, 0b111000, (outs ERegs:$rd), (ins ERegs:$ra, ERegs:$rb),
                         "mov\t$rd, $rb", []>;

//===----------------------------------------------------------------------===//
// Arithmetic instructions
//===----------------------------------------------------------------------===//

// Add/Sub
let isAdd = 1 in
defm ADD  : _ALU4<VC4ALU_add, 1>;
defm SUB  : _ALU4<VC4ALU_sub>;
defm RSUB : _ALU5<VC4ALU_rsub>; 

// Saturating add/substract
let isAdd = 1 in
defm ADDS : _ALU6<VC4ALU_adds>;
defm SUBS : _ALU6<VC4ALU_subs>;
defm SHLS : _ALU6<VC4ALU_shls>;
defm CLIPSH : _ALU6<VC4ALU_clipsh>;

// Add with scale
let isAdd = 1 in {
defm ADDSCALE2   : _ALU5<VC4ALU_addscale2, 1>;
defm ADDSCALE4   : _ALU5<VC4ALU_addscale4, 1>;
defm ADDSCALE8   : _ALU4<VC4ALU_addscale8, 1>;
defm ADDSCALE16  : _ALU5<VC4ALU_addscale16, 1>;
defm ADDSCALE32  : _ALU6<VC4ALU_addscale32, 1>;
defm ADDSCALE64  : _ALU6<VC4ALU_addscale64, 1>;
defm ADDSCALE128 : _ALU6<VC4ALU_addscale128, 1>;
defm ADDSCALE256 : _ALU6<VC4ALU_addscale256, 1>;
}

// Subtract with scale
defm SUBSCALE2   : _ALU6<VC4ALU_subscale2>;
defm SUBSCALE4   : _ALU6<VC4ALU_subscale4>;
defm SUBSCALE8   : _ALU6<VC4ALU_subscale8>;
defm SUBSCALE16  : _ALU6<VC4ALU_subscale16>;
defm SUBSCALE32  : _ALU6<VC4ALU_subscale32>;
defm SUBSCALE64  : _ALU6<VC4ALU_subscale64>;
defm SUBSCALE128 : _ALU6<VC4ALU_subscale128>;
defm SUBSCALE256 : _ALU6<VC4ALU_subscale256>;

//===----------------------------------------------------------------------===//
// Logical instructions
//===----------------------------------------------------------------------===//

defm LSR : _ALU4<VC4ALU_lsr>;
defm SHL : _ALU4<VC4ALU_shl>;
defm ASR : _ALU4<VC4ALU_asr>;
defm ROR : _ALU4<VC4ALU_ror>;

//===----------------------------------------------------------------------===//
// Bitwise Instructions
//===----------------------------------------------------------------------===//
defm AND : _ALU5<VC4ALU_and>;
defm OR  : _ALU5<VC4ALU_or>;
defm EOR : _ALU5<VC4ALU_eor>;
defm BIC : _ALU5<VC4ALU_bic>;

defm BMASK    : _ALU4<VC4ALU_bmask>;
defm BITCLEAR : _ALU4<VC4ALU_bitclear>;
defm BITSET   : _ALU4<VC4ALU_bitset>;
defm BITFLIP  : _ALU4<VC4ALU_bitflip>;

//===----------------------------------------------------------------------===//
// Multiply Instructions
//===----------------------------------------------------------------------===//

defm MUL     : _ALU4<VC4ALU_mul, 1>;
defm MULHDSS : _ALU6<VC4ALU_mul, 1>;
defm MULHDSU : _ALU6<VC4ALU_mul>;
defm MULHDUS : _ALU6<VC4ALU_mul>;
defm MULHDUU : _ALU6<VC4ALU_mul, 1>;

//===----------------------------------------------------------------------===//
// Division Instructions
//===----------------------------------------------------------------------===//
defm DIVSS : _ALU6<VC4ALU_divss>;
defm DIVSU : _ALU6<VC4ALU_divsu>;
defm DIVUS : _ALU6<VC4ALU_divus>;
defm DIVUU : _ALU6<VC4ALU_divuu>;

//===----------------------------------------------------------------------===//
// Miscellaneous Instructions
//===----------------------------------------------------------------------===//
// TODO
defm SIGNEXT : _ALU4<VC4ALU_signext>;
defm MSB     : _ALU5<VC4ALU_msb>;
defm BREV    : _ALU5<VC4ALU_brev>;
defm COUNT   : _ALU6<VC4ALU_count>;

//===----------------------------------------------------------------------===//
// Comparison Instructions
//===----------------------------------------------------------------------===//
let isCompare = 1, Defs = [SR] in {
defm CMP : _ALU4<VC4ALU_cmp>;
defm CMN : _ALU5<VC4ALU_cmn>;
defm BTEST : _ALU4<VC4ALU_btest>;
}

//===----------------------------------------------------------------------===//
// Min/Max Instructions
//===----------------------------------------------------------------------===//
// TODO: check signed nature of min/max
defm MAX : _ALU5<VC4ALU_max, 1>;
defm MIN : _ALU5<VC4ALU_max, 1>;

// Unary Instructions
defm NOT : _ALU4U<VC4ALU_not>;
defm NEG : _ALU5U<VC4ALU_not>;
defm ABS : _ALU5U<VC4ALU_abs>;

//===----------------------------------------------------------------------===//
// Patterns
//===----------------------------------------------------------------------===//

class _ALU_Pat<dag pat, dag result> : Pattern<pat, [result]>;

// Is there a way to conditionally defined the defs?
multiclass _ALU4_Pat<SDPatternOperator op, string insn> {
  // 4-bit Op
  def : _ALU_Pat<(op GRegs:$ra, immZExt5:$imm),
                 (!cast<Instruction>(insn # "_1r4i5") GRegs:$ra, immZExt5:$imm)>;
  // 6-bit Op
  def : _ALU_Pat<(op ERegs:$ra, immSExt6:$imm),
                 (!cast<Instruction>(insn # "_2r5i6") ERegs:$ra, immSExt6:$imm)>;
  // 5-bit Op
  def : _ALU_Pat<(op ERegs:$ra, immSExt16:$imm),
                 (!cast<Instruction>(insn # "_1r5i16") ERegs:$ra, immSExt16:$imm)>;
  def : _ALU_Pat<(op ERegs:$ra, immSExt32:$imm),
                 (!cast<Instruction>(insn # "_1r5i32") ERegs:$ra, immSExt32:$imm)>;
  def : _ALU_Pat<(op GRegs:$ra, GRegs:$rb),
                 (!cast<Instruction>(insn # "_2r4") GRegs:$ra, GRegs:$rb)>;
  // 6-bit Op
  def : _ALU_Pat<(op ERegs:$ra, ERegs:$rb),
                 (!cast<Instruction>(insn # "_3r5") ERegs:$ra, ERegs:$rb)>;  
}

multiclass _ALU5_Pat<SDPatternOperator op, string insn> {
  // 6-bit Op
  def : _ALU_Pat<(op ERegs:$ra, immSExt6:$imm),
                 (!cast<Instruction>(insn # "_2r5i6") ERegs:$ra, immSExt6:$imm)>;
  // 5-bit Op
  def : _ALU_Pat<(op ERegs:$ra, immSExt16:$imm),
                 (!cast<Instruction>(insn # "_1r5i16") ERegs:$ra, immSExt16:$imm)>;
  def : _ALU_Pat<(op ERegs:$ra, immSExt32:$imm),
                 (!cast<Instruction>(insn # "_1r5i32") ERegs:$ra, immSExt32:$imm)>;
  def : _ALU_Pat<(op GRegs:$ra, GRegs:$rb),
                 (!cast<Instruction>(insn # "_2r4") GRegs:$ra, GRegs:$rb)>;
  // 6-bit Op
  def : _ALU_Pat<(op ERegs:$ra, ERegs:$rb),
                 (!cast<Instruction>(insn # "_3r5") ERegs:$ra, ERegs:$rb)>;  
}

multiclass _ALU6_Pat<SDPatternOperator op, string insn> {
  // 6-bit Op
  def : _ALU_Pat<(op ERegs:$ra, immSExt6:$imm),
                 (!cast<Instruction>(insn # "_2r5i6") ERegs:$ra, immSExt6:$imm)>;
  def : _ALU_Pat<(op ERegs:$ra, ERegs:$rb),
                 (!cast<Instruction>(insn # "_3r5") ERegs:$ra, ERegs:$rb)>;  
}

defm : _ALU4_Pat<add, "ADD">;
defm : _ALU4_Pat<sub, "SUB">;
// RSUB - swap operand order
def : _ALU_Pat<(sub immSExt6:$imm, ERegs:$ra), (RSUB_2r5i6 ERegs:$ra, immSExt16:$imm)>; 
def : _ALU_Pat<(sub immSExt16:$imm, ERegs:$ra), (RSUB_1r5i16 ERegs:$ra, immSExt16:$imm)>;
def : _ALU_Pat<(sub immSExt32:$imm, ERegs:$ra), (RSUB_1r5i32 ERegs:$ra, immSExt32:$imm)>;
def : _ALU_Pat<(sub GRegs:$rb, GRegs:$ra), (RSUB_2r4 GRegs:$ra, GRegs:$rb)>;

// Saturating add/subtract
//6 101000    adds     rd, ra, rb          rd = saturate32(ra + rb)
//6 101001    subs     rd, ra, rb          rd = saturate32(ra - rb)
//6 101010    shls     rd, ra, rb          rd = saturate32(ra << rb)
//6 101011    clipsh   rd, rb              rd = saturate16(rb)

// Add with scale
class _ALU_AddScaleFrag<int i> : BinOpFrag<(add node:$LHS, (shl node:$RHS, i))>;

defm : _ALU5_Pat<_ALU_AddScaleFrag<1>, "ADDSCALE2">;
defm : _ALU5_Pat<_ALU_AddScaleFrag<2>, "ADDSCALE4">;
defm : _ALU4_Pat<_ALU_AddScaleFrag<3>, "ADDSCALE8">;
defm : _ALU5_Pat<_ALU_AddScaleFrag<4>, "ADDSCALE16">;
defm : _ALU6_Pat<_ALU_AddScaleFrag<5>, "ADDSCALE32">;
defm : _ALU6_Pat<_ALU_AddScaleFrag<6>, "ADDSCALE64">;
defm : _ALU6_Pat<_ALU_AddScaleFrag<7>, "ADDSCALE128">;
defm : _ALU6_Pat<_ALU_AddScaleFrag<8>, "ADDSCALE256">;

// Subtract with scale
class _ALU_SubScaleFrag<int i> : BinOpFrag<(sub node:$LHS, (shl node:$RHS, i))>;

defm : _ALU6_Pat<_ALU_SubScaleFrag<1>, "SUBSCALE2">;
defm : _ALU6_Pat<_ALU_SubScaleFrag<2>, "SUBSCALE4">;
defm : _ALU6_Pat<_ALU_SubScaleFrag<3>, "SUBSCALE8">;
defm : _ALU6_Pat<_ALU_SubScaleFrag<4>, "SUBSCALE16">;
defm : _ALU6_Pat<_ALU_SubScaleFrag<5>, "SUBSCALE32">;
defm : _ALU6_Pat<_ALU_SubScaleFrag<6>, "SUBSCALE64">;
defm : _ALU6_Pat<_ALU_SubScaleFrag<7>, "SUBSCALE128">;
defm : _ALU6_Pat<_ALU_SubScaleFrag<8>, "SUBSCALE256">;

// Logical Instructions
defm : _ALU4_Pat<srl, "LSR">;
defm : _ALU4_Pat<shl, "SHL">;
defm : _ALU4_Pat<sra, "ASR">;
defm : _ALU5_Pat<rotr, "ROR">;

// Bitwise Instructions
defm : _ALU5_Pat<and, "AND">;
defm : _ALU5_Pat<or, "OR">;
defm : _ALU5_Pat<xor, "EOR">;
defm : _ALU5_Pat<BinOpFrag<(and node:$LHS, (not node:$RHS))>, "BIC">;

// 4 001110    bmask    rd, ra              rd = rd & mask(ra)                    Mask left most bits.
// 4 010010    bitclear rd, ra              rd = rd & ~bit(ra)                    Bit clear.
// 4 010000    bitset   rd, ra              rd = rd | bit(ra)                     Bit set.
// 4 010100    bitflip  rd, ra              rd = rd ^ bit(ra)                     Bit flip.

// Multiply Instructions
defm : _ALU4_Pat<mul, "MUL">;
defm : _ALU6_Pat<mulhs, "MULHDSS">;
defm : _ALU6_Pat<mulhu, "MULHDUU">;

// Division Instructions
defm : _ALU6_Pat<sdiv, "DIVSS">;
defm : _ALU6_Pat<udiv, "DIVUU">;

// Misc
//4 011000    signext  rd, ra              rd = sign_extend(rd & mask(ra))       Mask left most bits and sign extend.
//5 011011    msb      rd, ra              rd = msb(ra)                          Position of most significant 1 bit, (msb(0)==-1)
//5 011101    brev     rd, ra              rd = reverse(rd) >> (32-ra)           Reverse bits and shift right.
//6 110000    count    rd, rb              rd = count(rb)

// Comparison Instructions
//4 001010    cmp      rd, ra              ZNCV = cc(rd - ra)                    Compare values.
//5 000001    cmn      rd, ra              ZNCV = cc(rd + ra)                    Compare values by addition.
//4 001100    btest    rd, ra              Z = rd & bit(ra) == 0                 Bit test.

// TODO - check signedness of VPU min/max
defm : _ALU5_Pat<smax, "MAX">;
defm : _ALU5_Pat<smin, "MIN">;

// Unary Instructions
// 001000    not      rd, ra              rd = ~ra                              Not / 1s Complement.
//def : _ALU_Pat<(not immZExt5:$imm), (NOT_1r4i5 immZExt5:$imm)>;
//def : _ALU_Pat<(not ERegs:$rb), (NOT_2r5i6 ERegs:$rb)>;
//def : _ALU_Pat<(not immSExt16:$imm), (NOT_1r5i16 immSExt16:$imm)>;
//def : _ALU_Pat<(not immSExt32:$imm), (NOT_1r5i32 immSExt32:$imm)>;
//def : _ALU_Pat<(not GRegs:$rb), (NOT_2r4 GRegs:$rb)>;
//def : _ALU_Pat<(not ERegs:$rb), (NOT_3r5 ERegs:$rb)>;  

// 011001    neg      rd, ra              rd = -ra                              Negate.
//def : _ALU_Pat<(ineg immSExt6:$imm), (NEG_2r5i6 ERegs:$ra, immSExt6:$imm)>;
//def : _ALU_Pat<(ineg immSExt16:$imm), (NEG_1r5i16 immSExt16:$imm)>;
//def : _ALU_Pat<(ineg immSExt32:$imm), (NEG_1r5i32 immSExt32:$imm)>;
//def : _ALU_Pat<(ineg GRegs:$rb), (NEG_2r4 GRegs:$rb)>;
//def : _ALU_Pat<(ineg ERegs:$rb), (NEG_3r5 ERegs:$rb)>;  
