// -*- tablegen -*- //

// VideoCore-IV ALU instructions

class VC4ALU<bits<6> val, string opcode> {
  bits<6> Value = val;
  string OpCode = opcode;
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
def VC4ALU_addscale8   : VC4ALU<0b010110, "addscale">;
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
def VC4ALU_addscale2   : VC4ALU<0b010011, "addscale">;
// Add scaled by 4 - rd = rd + 4*ra
def VC4ALU_addscale4   : VC4ALU<0b010101, "addscale">;
// Add scaled by 16 - rd = rd + 16*ra
def VC4ALU_addscale16  : VC4ALU<0b010111, "addscale">;
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
def VC4ALU_addscale32  : VC4ALU<0b101100, "addscale">;
// rd = ra + 64*rb - Add scaled by 64
def VC4ALU_addscale64  : VC4ALU<0b101101, "addscale">;
// rd = ra + 128*rb - Add scaled by 128
def VC4ALU_addscale128 : VC4ALU<0b101110, "addscale">;
// rd = ra + 256*rb - Add scaled by 256
def VC4ALU_addscale256 : VC4ALU<0b101111, "addscale">;
// rd = count(rb) - Population Count
def VC4ALU_count       : VC4ALU<0b110000, "count">;
// rd = ra - 2*rb - Sub scaled by 2
def VC4ALU_subscale2   : VC4ALU<0b110001, "subscale">;
// rd = ra - 4*rb - Sub scaled by 4
def VC4ALU_subscale4   : VC4ALU<0b110010, "subscale">;
// rd = ra - 8*rb - Sub scaled by 8
def VC4ALU_subscale8   : VC4ALU<0b110011, "subscale">;
// rd = ra - 16*rb - Sub scaled by 16
def VC4ALU_subscale16  : VC4ALU<0b110100, "subscale">;
// rd = ra - 32*rb - Sub scaled by 32
def VC4ALU_subscale32  : VC4ALU<0b110101, "subscale">;
// rd = ra - 64*rb - Sub scaled by 64
def VC4ALU_subscale64  : VC4ALU<0b110110, "subscale">;
// rd = ra - 128*rb - Sub scaled by 128
def VC4ALU_subscale128 : VC4ALU<0b110111, "subscale">;
// rd = ra - 256*rb - Sub scaled by 256
def VC4ALU_subscale256 : VC4ALU<0b111000, "subscale">;

class BinOpFrag<dag res> : PatFrag<(ops node:$LHS, node:$RHS), res>;

//***----------------------------------------------------------------------***//
// 4-bit opcode instructions
//***----------------------------------------------------------------------***//

// Rd = Rd <op> u - 011p pppu uuuu dddd
let Constraints = "$ra = $rd" in {
class _ALU4_1r4i5<VC4ALU opc, string asm_suffix, dag ins, list<dag> pat>
   : _S16_1r4i5<{0b11, opc.Value{4-1}},
                (outs GRegs:$rd), ins,
                opc.OpCode # "\t$rd, $imm" # asm_suffix, pat>;
}

//***----------------------------------------------------------------------***//
// 5-bit opcode instructions
//***----------------------------------------------------------------------***//

// Rd = Rd <op> Ra - 010p pppp ssss dddd
let Constraints = "$ra = $rd" in {
class _ALU5_2r4<VC4ALU opc, string asm_suffix, dag ins, list<dag> pat>
    : _S16_2r4<{0b10, opc.Value{4-0}},
               (outs GRegs:$rd), ins,
               opc.OpCode # "\t$rd, $rb" # asm_suffix, pat>;
}


// Rd = Rd <op> i - 1011 00pp pppd dddd iiii iiii iiii iiii
let Constraints = "$ra = $rd" in {
class _ALU5_1r5i16<VC4ALU opc, string asm_suffix, dag ins, list<dag> pat>
    : _S32_1r5i16<{0b01100, opc.Value{4-0}},
                  (outs ERegs:$rd), ins,
                  opc.OpCode # "\t$rd, $imm" # asm_suffix, pat>;
}


// Rd = Rd <op> u - 1110 10pp pppd dddd uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
let Constraints = "$ra = $rd" in {
class _ALU5_1r5i32<VC4ALU opc, string asm_suffix, dag ins, list<dag> pat>
    : _S48_1r5i32<{0b10, opc.Value{4-0}},
                  (outs ERegs:$rd), ins,
                  opc.OpCode # "\t$rd, $imm" # asm_suffix, pat>;
}

//***----------------------------------------------------------------------***//
// 6-bit opcode instructions
//***----------------------------------------------------------------------***//

// 1100 0ppp pppd dddd aaaa accc c00b bbbb
let TwoOperandAliasConstraint = "$ra = $rd" in {
class _ALU6_3r5<VC4ALU opc, VC4CondCode cc, string asm_suffix, dag ins, list<dag> pat>
    : _S32_3r5<{0b1000, opc.Value{5-0}}, {cc.Value{3-0}, 0b00},
               (outs ERegs:$rd), ins,
               opc.OpCode # "\t$rd, $ra, $rb" # asm_suffix, pat>;
}

// 1100 0ppp pppd dddd aaaa accc c1ii iiii
let TwoOperandAliasConstraint = "$ra = $rd" in {
class _ALU6_2r5i6<VC4ALU opc, VC4CondCode cc, string asm_suffix, dag ins, list<dag> pat>
    : _S32_2r5i6<{0b1000, opc.Value{5-0}}, {cc.Value{3-0}, 0b1},
                 (outs ERegs:$rd), ins,
                 opc.OpCode # "\t$rd, $ra, $imm" # asm_suffix, pat>;
}

// Register with Immediate logical and arithmetic operations.

// 4-bit opcode - 0oooo0
multiclass _ALU4B<VC4ALU opc, SDPatternOperator op, string asm_suffix> {
  def _1r4i5: _ALU4_1r4i5<opc, asm_suffix, (ins GRegs:$ra, i32imm:$imm),
                          [(set GRegs:$rd, (op GRegs:$ra, immZExt5:$imm))]>;
}

multiclass _ALU5B<VC4ALU opc, SDPatternOperator op, string asm_suffix> {
  def _2r4    : _ALU5_2r4<opc, asm_suffix, (ins GRegs:$ra, GRegs:$rb),
                          [(set GRegs:$rd, (op GRegs:$ra, GRegs:$rb))]>;
  def _1r5i16 : _ALU5_1r5i16<opc, asm_suffix, (ins ERegs:$ra, i32imm:$imm),
                          [(set ERegs:$rd, (op ERegs:$ra, immSExt16:$imm))]>;
  def _1r5i32 : _ALU5_1r5i32<opc, asm_suffix, (ins ERegs:$ra, i32imm:$imm),
                          [(set ERegs:$rd, (op ERegs:$ra, immSExt32:$imm))]>;
}

multiclass _ALU6B<VC4ALU opc, SDPatternOperator op, string asm_suffix> {
  def _2r5i6 : _ALU6_2r5i6<opc, VC4CC_t, asm_suffix, (ins ERegs:$ra, i32imm:$imm),
                          [(set ERegs:$rd, (op ERegs:$ra, immSExt6:$imm))]>;
  def _3r5 : _ALU6_3r5<opc, VC4CC_t, asm_suffix, (ins ERegs:$ra, ERegs:$rb),
                          [(set ERegs:$rd, (op ERegs:$ra, ERegs:$rb))]>;
}

// Binary Operations
multiclass ALU4B<VC4ALU opc, SDPatternOperator op, string asm_suffix = "">
    : _ALU4B<opc, op, asm_suffix>, _ALU5B<opc, op, asm_suffix>, _ALU6B<opc, op, asm_suffix>;
multiclass ALU5B<VC4ALU opc, SDPatternOperator op, string asm_suffix = "">
    : _ALU5B<opc, op, asm_suffix>, _ALU6B<opc, op, asm_suffix>;
multiclass ALU6B<VC4ALU opc, SDPatternOperator op, string asm_suffix = "">
    : _ALU6B<opc, op, asm_suffix>;

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


//***----------------------------------------------------------------------***//
// ALU
//***----------------------------------------------------------------------***//

//defm MOV         : ALU4B<VC4ALU_mov, BinOpFrag<(i32 node:$RHS)>>;
defm ADD         : ALU4B<VC4ALU_add, add>;
defm MUL         : ALU4B<VC4ALU_mul, mul>;
defm SUB         : ALU4B<VC4ALU_sub, sub>;
//defm NOT         : ALU4U<VC4ALU_not, not>;
//defm CMP         : ALU4B<VC4ALU_cmp>;
//defm BTEST       : ALU4B<VC4ALU_btest>;
//defm BMASK       : ALU4B<VC4ALU_bmask>;
//defm BITSET      : ALU4B<VC4ALU_bitset>;
//defm BITCLEAR    : ALU4B<VC4ALU_bitclear>;
//defm BITFLIP     : ALU4B<VC4ALU_bmask>;
defm ADDSCALE8   : ALU4B<VC4ALU_addscale8, BinOpFrag<(add node:$LHS, (shl node:$RHS, 3))>, " << 3">;
//defm SIGNEXT     : ALU4B<VC4ALU_signext>;
defm LSR         : ALU4B<VC4ALU_lsr, srl>;
defm SHL         : ALU4B<VC4ALU_shl, shl>;
defm ASR         : ALU4B<VC4ALU_asr, sra>;

//defm CMN         : ALU5B<VC4ALU_cmn>;
//defm BIC         : ALU5B<VC4ALU_bic>;
defm EOR         : ALU5B<VC4ALU_eor, xor>;
defm AND         : ALU5B<VC4ALU_and, and>;
defm ROR         : ALU5B<VC4ALU_ror, rotr>;
//defm RSUB        : ALU5B<VC4ALU_rsub>;
defm OR          : ALU5B<VC4ALU_or, or>;
defm MAX         : ALU5B<VC4ALU_max, smax>;
defm MIN         : ALU5B<VC4ALU_min, smin>;
defm ADDSCALE2   : ALU5B<VC4ALU_addscale2, BinOpFrag<(add node:$LHS, (shl node:$RHS, 1))>, " << 1">;
defm ADDSCALE4   : ALU5B<VC4ALU_addscale4, BinOpFrag<(add node:$LHS, (shl node:$RHS, 2))>, " << 2">;
defm ADDSCALE16  : ALU5B<VC4ALU_addscale16, BinOpFrag<(add node:$LHS, (shl node:$RHS, 4))>, " << 4">;
//defm NEG         : ALU5U<VC4ALU_neg, ineg>;
//defm MSB         : ALU5B<VC4ALU_msb>;
//defm BREV        : ALU5B<VC4ALU_brev>;
//defm ABS         : ALU5B<VC4ALU_abs>;

defm MULHDSS     : ALU6B<VC4ALU_mulhdss, mulhs>;
//defm MULHDSU     : ALU6B<VC4ALU_mulhdsu>;
//defm MULHDUS     : ALU6B<VC4ALU_mulhdus>;
defm MULHDUU     : ALU6B<VC4ALU_mulhduu, mulhu>;
defm DIVSS       : ALU6B<VC4ALU_divss, sdiv>;
//defm DIVSU       : ALU6B<VC4ALU_divsu>;
//defm DIVUS       : ALU6B<VC4ALU_divus>;
defm DIVUU       : ALU6B<VC4ALU_divuu, udiv>;
//defm ADDS        : ALU6B<VC4ALU_adds>;
//defm SUBS        : ALU6B<VC4ALU_subs>;
//defm SHLS        : ALU6B<VC4ALU_shls>;
//defm CLIPSH      : ALU6B<VC4ALU_clipsh>;
defm ADDSCALE32  : ALU6B<VC4ALU_addscale32, BinOpFrag<(add node:$LHS, (shl node:$RHS, 5))>, " << 5">;
//defm ADDSCALE64  : ALU6B<VC4ALU_addscale64, BinOpFrag<(add node:$LHS, (shl node:$RHS, 6))>," << 6">;
//defm ADDSCALE128 : ALU6B<VC4ALU_addscale128, BinOpFrag<(add node:$LHS, (shl node:$RHS, 7))>," << 7">;
//defm ADDSCALE256 : ALU6B<VC4ALU_addscale256, BinOpFrag<(add node:$LHS, (shl node:$RHS, 8))>," << 8">;
//defm COUNT       : ALU6B<VC4ALU_count>;
//defm SUBSCALE2   : ALU6B<VC4ALU_subscale2, BinOpFrag<(sub node:$LHS, (shl node:$RHS, 1))>, " << 1">;
//defm SUBSCALE4   : ALU6B<VC4ALU_subscale4, BinOpFrag<(sub node:$LHS, (shl node:$RHS, 2))>, " << 2">;
//defm SUBSCALE8   : ALU6B<VC4ALU_subscale8, BinOpFrag<(sub node:$LHS, (shl node:$RHS, 3))>, " << 3">;
//defm SUBSCALE16  : ALU6B<VC4ALU_subscale16, BinOpFrag<(sub node:$LHS, (shl node:$RHS, 4))>, " << 4">;
//defm SUBSCALE32  : ALU6B<VC4ALU_subscale32, BinOpFrag<(sub node:$LHS, (shl node:$RHS, 5))>, " << 5">;
//defm SUBSCALE64  : ALU6B<VC4ALU_subscale64, BinOpFrag<(sub node:$LHS, (shl node:$RHS, 6))>, " << 6">;
//defm SUBSCALE128 : ALU6B<VC4ALU_subscale128, BinOpFrag<(sub node:$LHS, (shl node:$RHS, 7))>, " << 7">;
//defm SUBSCALE256 : ALU6B<VC4ALU_subscale256, BinOpFrag<(sub node:$LHS, (shl node:$RHS, 8))>, " << 8">;

