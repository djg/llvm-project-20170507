//===-- VC4InstrFormats.td - VideoCore IV Instruction Formats -*- tablegen -*-===//

class LoadStoreWidth<bits<2> val> {
  bits<2> Value = val;
}
def LSWu32   : LoadStoreWidth<0>;
def LSWu16   : LoadStoreWidth<1>;
def LSWu8    : LoadStoreWidth<2>;
def LSWs16s8 : LoadStoreWidth<3>;

// Instruction format superclass
class VC4Inst<int sz, dag outs, dag ins, string asmstr, list<dag> pattern>
    : Instruction {
  field bits<16> Inst;

  let Namespace = "VC4";
  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = asmstr;
  let Pattern = pattern;

  field bits<16> SoftFail = 0;
}

class VC4PseudoInst<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<0, outs, ins, asmstr, pattern> {
  let isPseudo = 1;
}

// Instruction formats

// 16 bit instructions

class S16<dag outs, dag ins, string asmstr, list<dag> pattern>
    : VC4Inst<2, outs, ins, asmstr, pattern> {
  let Inst{15} = 0;
}

class S16_0<bits<4> opc, string asmstr, list<dag> pattern>
    : S16<(outs), (ins), asmstr, pattern> {
  let Inst{14-4} = 0b00000000000;
  let Inst{3-0} = opc;
}

class S16_rd4<dag outs, dag ins, string asmstr, list<dag> pattern>
    : S16<outs, ins, asmstr, pattern    > {
  bits<4> rd;

  let Inst{3-0} = rd;
}

class S16_rd4_1<bits<4> opc, dag outs, dag ins, string asmstr, list<dag> pattern>
    : S16_rd4<outs, ins, asmstr, pattern> {
  let Inst{14-8} = 0b0000000;
  let Inst{7-4} = opc;
}

class S16_rd5<dag outs, dag ins, string asmstr, list<dag> pattern>
    : S16<outs, ins, asmstr, pattern> {
  bits<5> rd;
  
  let Inst{4-0} = rd;
}

class S16_rd5_1<dag outs, dag ins, bits<3> opc, string asmstr, list<dag> pattern>
    : S16_rd5<outs, ins, asmstr, pattern> {
  let Inst{14-8} = 0b0000000;
  let Inst{7-5} = opc;
}

class S16_swi<dag outs, dag ins, string asmstr, list<dag> pattern>
    : S16<outs, ins, asmstr, pattern> {
  bits<6> u;

  let Inst{14-6} = 0b000000111;
  let Inst{5-0} = u;
}

class S16_mem_mult<dag outs, dag ins, string asmstr, bit S_bit, bit L_bit, list<dag> pattern>
    : S16<outs, ins, asmstr, pattern> {
  bits<5> m;
  bits<2> b;

  let Inst{14-9} = 0b000001;
  let Inst{8} = L_bit;
  let Inst{7} = S_bit;
}

class S16_mem_sp<dag outs, dag ins, string asmstr, bit S_bit, list<dag> pattern>
    : S16_rd4<outs, ins, asmstr, pattern> {
  bits<5> o;

  let Inst{14-10} = 0b00001;
  let Inst{9} = S_bit;
  let Inst{8-4} = o;
}

class S16_mem<dag outs, dag ins, string asmstr, list<dag> pattern>
    : S16_rd4<outs, ins, asmstr, pattern> {
  bits<4> rs;

  let Inst{7-4} = rs;
}

class S16_mem_w<dag outs, dag ins, bit S_bit, LoadStoreWidth lswVal, string asmstr, list<dag> pattern>
    : S16_mem<outs, ins, asmstr, pattern> {
  LoadStoreWidth lsw;

  let lsw = lswVal;

  let Inst{14-11} = 0b0001;
  let Inst{10-9} = lsw.Value;
  let Inst{8} = S_bit;
}

class S16_mem_off<dag outs, dag ins, bit S_bit, string asmstr, list<dag> pattern>
    : S16_mem<outs, ins, asmstr, pattern> {
  bits<4> u;

  let Inst{14-13} = 0b01;
  let Inst{12} = S_bit;
  let Inst{11-8} = u;
}

class S16_add_sp<dag outs, dag ins, string asmstr, list<dag> pattern>
    : S16_rd5<outs, ins, asmstr, pattern> {
  bits<6> o;

  let Inst{14-11} = 0b0010;
  let Inst{10-5} = o;
}

class S16_bcc<dag outs, dag ins, string asmstr, list<dag> pattern>
    : S16<outs, ins, asmstr, pattern> {
  bits<4> cc;
  bits<7> o;

  let Inst{14-11} = 0b0011;
  let Inst{10-7} = cc;
  let Inst{6-0} = 0;
}

