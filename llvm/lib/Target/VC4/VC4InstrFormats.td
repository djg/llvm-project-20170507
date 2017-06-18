//===-- VC4InstrFormats.td - VideoCore IV Instruction Formats -*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

class VC4LS<bit val> {
  bit Value = val;
}
def VC4LS_load : VC4LS<0>;
def VC4LS_store : VC4LS<1>;

class LoadStoreWidth<bits<2> val> {
  bits<2> Value = val;
}
def LSWu32   : LoadStoreWidth<0>;
def LSWu16   : LoadStoreWidth<1>;
def LSWu8    : LoadStoreWidth<2>;
def LSWs16s8 : LoadStoreWidth<3>;

class VC4CC<bits<4> val> {
  bits<4> Value = val;
}

def VC4CC_eq : VC4CC<0b0000>; // == 0
def VC4CC_ne : VC4CC<0b0001>; // != 0
def VC4CC_cs : VC4CC<0b0010>; // Unsigned <
def VC4CC_cc : VC4CC<0b0011>; // Unsigned >=
def VC4CC_mi : VC4CC<0b0100>; // Negative
def VC4CC_pl : VC4CC<0b0101>; // Positive
def VC4CC_vs : VC4CC<0b0110>; // Overflow set
def VC4CC_vc : VC4CC<0b0111>; // Overflow clear
def VC4CC_hi : VC4CC<0b1000>; // Unsigned >
def VC4CC_ls : VC4CC<0b1001>; // Unsigned <=
def VC4CC_ge : VC4CC<0b1010>; // Signed >=
def VC4CC_lt : VC4CC<0b1011>; // Signed <
def VC4CC_gt : VC4CC<0b1100>; // Signed >
def VC4CC_le : VC4CC<0b1101>; // Signed <=
def VC4CC_t  : VC4CC<0b1110>; // Always
def VC4CC_f  : VC4CC<0b1111>; // Never


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

  string Arch = "vpu";
}

class VC4PseudoInst<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<0, outs, ins, asmstr, pattern> {
  let isPseudo = 1;
}

//===----------------------------------------------------------------------===//
// 16-bit Scalar Instructions
//===----------------------------------------------------------------------===//

class _S16<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<2, outs, ins, asmstr, pattern> {
  let Inst{15} = 0;
}

class _S16_0<bits<15> opc, string asmstr, list<dag> pattern = []>
    : _S16<(outs), (ins), asmstr, pattern> {
  let Inst{14-0} = opc;
}

// S16_1r4 - 0... .... .... dddd
class _S16_1r4<bits<11> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16<outs, ins, asmstr, pattern> {
  bits<4> rd;

  let Inst{14-4} = opc;
  let Inst{3-0} = rd;
}

// S16_1r4i5 - 0... ...u uuuu dddd
class _S16_1r4i5<bits<6> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16<outs, ins, asmstr, pattern> {
  bits<4> rd;
  bits<5> imm;

  let Inst{14-9} = opc;
  let Inst{8-4} = imm;
  let Inst{3-0} = rd;
}

// S16_1r5 - 0... .... ...d dddd
class _S16_1r5<bits<10> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16<outs, ins, asmstr, pattern> {
  bits<5> rd;

  let Inst{14-5} = opc;
  let Inst{4-0} = rd;
}

// S16_1r5i6 - 0... .ooo oood dddd
class _S16_1r5i6<bits<4> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16<outs, ins, asmstr, pattern> {
  bits<6> imm;
  bits<5> rd;

  let Inst{14-11} = opc;
  let Inst{10-5} = imm;
  let Inst{4-0} = rd;
}

// S16_2r4 - 0... .... ssss dddd
class _S16_2r4<bits<7> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16<outs, ins, asmstr, pattern> {
  bits<4> rd;
  bits<4> rb;

  let Inst{14-8} = opc;
  let Inst{7-4} = rb;
  let Inst{3-0} = rd;
}

// S16_2r4i4 - 0... uuuu ssss dddd
class _S16_2r4i4<bits<3> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16<outs, ins, asmstr, pattern> {
  bits<4> rd;
  bits<4> rs;
  bits<4> imm;

  let Inst{14-12} = opc;
  let Inst{11-8} = imm;
  let Inst{7-4} = rs;
  let Inst{3-0} = rd;
}

// S16_bm - 0... .... .bbm mmmm
class _S16_bm<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16<outs, ins, asmstr, pattern> {
  bits<2> rb;
  bits<5> rm;

  let Inst{6-5} = rb;
  let Inst{4-0} = rm;
}

// S16_i6 - 0... .... ..ii iiii
class _S16_i6<bits<9> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S16<outs, ins, asmstr, pattern> {
  bits<6> imm;

  let Inst{14-6} = opc;
  let Inst{5-0} = imm;
}

// S16_i7 - 0... .... .iii iiii
class _S16_i7<bits<8> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
   : _S16<outs, ins, asmstr, pattern> {
  bits<7> imm;

  let Inst{14-7} = opc;
  let Inst{6-0} = imm;
}

//===----------------------------------------------------------------------===//
// 32-bit Scalar Instructions
//===----------------------------------------------------------------------===//

// S32 - 1... .... .... .... .... .... .... ....
class _S32<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<4, outs, ins, asmstr, pattern> {
  let Inst{31} = 0b1;
}

// S32_1r4 - 1... .... .... dddd .... .... .... ....
class _S32_1r4<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32<outs, ins, asmstr, pattern> {
  bits<4> rd;

  let Inst{19-16} = rd;
}

// S32_1r4i4 - 1... .... iiii dddd .... .... .... ....
class _S32_1r4i4<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_1r4<outs, ins, asmstr, pattern> {
  bits<4> imm;

  let Inst{23-20} = imm;
}

// S32_1r4i4u6o8 - 1... .... iiii dddd ..uu uuuu oooo oooo
class _S32_1r4i4u6o8<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_1r4i4<outs, ins, asmstr, pattern> {
  bits<6> imm2;
  bits<8> off;

  let Inst{13-8} = imm2;
  let Inst{7-0} = off;
}

// S32_1r5 - 1... .... ...d dddd .... .... .... ....
class _S32_1r5<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32<outs, ins, asmstr, pattern> {
  bits<5> rd;

  let Inst{20-16} = rd;
}

// S32_1r5i16 - 1... .... ...d dddd iiii iiii iiii iiii
class _S32_1r5i16<bits<10> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<16> imm;

  let Inst{30-21} = opc;
  let Inst{20-16} = rd;
  let Inst{15-0} = imm;
}

// S32_2r4i4o10 - 1... .... iiii dddd ..ss ssoo oooo oooo
class _S32_2r4i4o10<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_1r4i4<outs, ins, asmstr, pattern> {
  bits<4> rs;
  bits<10> off;

  let Inst{13-10} = rs;
  let Inst{9-0} = off;
}

// S32_2r4u6o8 - 1... .... aaaa dddd ..uu uuuu oooo oooo
class _S32_2r4u6o8<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_1r4<outs, ins, asmstr, pattern> {
  bits<4> ra;
  bits<6> imm2;
  bits<8> off;

  let Inst{23-20} = ra;
  let Inst{13-8} = imm2;
  let Inst{7-0} = off;
}

// S32_2r5 - 1... .... ...d dddd aaaa a... .... ....
class _S32_2r5<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<5> ra;

  let Inst{20-16} = rd;
  let Inst{15-11} = ra;
}

// S32_2r5i6 - 1... .... ...d dddd aaaa a... ..ii iiii
class _S32_2r5i6<bits<10> opc1, bits<5> opc2, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_2r5<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<5> ra;
  bits<6> imm;

  let Inst{30-21} = opc1;
  let Inst{20-16} = rd;
  let Inst{15-11} = ra;
  let Inst{10-6} = opc2;
  let Inst{5-0} = imm;
}

// S32_2r5i16 - 1... ..ss sssd dddd iiii iiii iiii iiii
class _S32_2r5i16<bits<5> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_1r5<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<5> rs;
  bits<16> imm;

  let Inst{30-26} = opc;
  let Inst{25-21} = rs;
  let Inst{20-16} = rd;
  let Inst{15-0} = imm;
}

// S32_2r5o12 - 1... ...o ...d dddd aaaa aooo oooo oooo
class _S32_2r5o12<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_2r5<outs, ins, asmstr, pattern> {
  bits<12> off;

  let Inst{24} =  off{11};
  let Inst{10-0} = off{10-0};
}

// S32_3r4o10 - 1... .... aaaa dddd ..ss ssoo oooo oooo
class _S32_3r4o10<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_1r4i4<outs, ins, asmstr, pattern> {
  bits<4> ra;
  bits<4> rs;
  bits<10> off;

  let Inst{23-20} = ra;
  let Inst{13-10} = rs;
  let Inst{9-0} = off;
}

// S32_3r5 - 1... .... ...d dddd aaaa a... ...b bbbb
class _S32_3r5<bits<10> opc1, bits<6> opc2, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<5> ra;
  bits<5> rb;

  let Inst{30-21} = opc1;
  let Inst{20-16} = rd;
  let Inst{15-11} = ra;
  let Inst{10-5} = opc2;
  let Inst{4-0} = rb;
}

// S32_o23 - 1... .... 0ooo oooo oooo oooo oooo oooo
class _S32_i23<bits<8> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32<outs, ins, asmstr, pattern> {
  bits<23> off;

  let Inst{30-23} = opc;
  let Inst{22-0} = off{22-0};
}

// S32_i27 - 1... oooo .ooo oooo oooo oooo oooo oooo
class _S32_i27<bits<3> opc1, bit opc2, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32<outs, ins, asmstr, pattern> {
  bits<27> off;

  let Inst{30-28} = opc1;
  let Inst{27-24} = off{26-23};
  let Inst{23} = opc2;
  let Inst{22-0} = off{22-0};
}

// S32_c2r5 - 1... .... ...d dddd .... .... ...a aaaa
class _S32_c2r5<dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S32_1r5<outs, ins, asmstr, pattern> {
  bits<5> rs;

  let Inst{4-0} = rs;
}

//===----------------------------------------------------------------------===//
// 48-bit Scalar Instructions
//===----------------------------------------------------------------------===//

// S48 - 1110 .... .... .... .... .... .... .... .... .... .... ....
class _S48<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<6, outs, ins, asmstr, pattern> {
  let Inst{47-44} = 0b1110;
}

// S48_1r5i27 - 1110 .... ...d dddd 1111 1ooo oooo oooo oooo oooo oooo oooo
class _S48_1r5i27<bits<7> opc1, bits<5> opc2, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S48<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<27> imm;

  let Inst{43-37} = opc1;
  let Inst{36-32} = rd;
  let Inst{31-27} = opc2;
  let Inst{26-0} = imm;
}

// S48_i32 - 1110 .... .... .... uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
class _S48_i32<bits<12> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S48<outs, ins, asmstr, pattern> {
  bits<32> imm;

  let Inst{43-32} = opc;
  let Inst{31-0} = imm;
}

// S48_1r5i32 - 1110 .... ...d dddd uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
class _S48_1r5i32<bits<7> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S48<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<32> imm;

  let Inst{43-37} = opc;
  let Inst{36-32} = rd;
  let Inst{31-0} = imm;
}

// S48_2r5i27 - 1110 .... ...d dddd ssss sooo oooo oooo oooo oooo oooo oooo
class _S48_2r5i27<bits<7> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S48<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<5> rs;
  bits<27> imm;

  let Inst{43-37} = opc;
  let Inst{36-32} = rd;
  let Inst{31-27} = rs;
  let Inst{26-0} = imm;

}

// S48_2r5i32 - 1110 ..ss sssd dddd uuuu uuuu uuuu uuuu uuuu uuuu uuuu uuuu
class _S48_2r5i32<bits<2> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : _S48<outs, ins, asmstr, pattern> {
  bits<5> rd;
  bits<5> rs;
  bits<32> imm;

  let Inst{43-42} = opc;
  let Inst{41-37} = rs;
  let Inst{36-32} = rd;
  let Inst{31-0} = imm;
}
