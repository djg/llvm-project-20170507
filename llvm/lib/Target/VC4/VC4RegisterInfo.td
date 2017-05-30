//===-- VC4RegisterInfo.td - VideoCore-IV Register defs ----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

class VC4ScalarReg<string n> : Register<n> {
  field bits<5> Num;
  let Namespace = "VC4";
}

// Registers are identified with 5-bit ID numbers
// Ri - 32-bit scalar register
class Ri<bits<5> num, string n> : VC4ScalarReg<n> {
  let Num = num;
}

//===----------------------------------------------------------------------===//
//  Registers
//===----------------------------------------------------------------------===//

// General purpose scalar registers:
foreach I = 0-15 in
def R#I : Ri<I, "r"#I>, DwarfRegNum<[I]>;

// Extended scalar registers
foreach I = 16-23 in
def R#I : Ri<I, "r"#I>, DwarfRegNum<[I]>;

// Special registers
def GP  : Ri<24, "gp">, DwarfRegNum<[24]>;
def SP  : Ri<25, "sp">, DwarfRegNum<[25]>;
def LR  : Ri<26, "lr">, DwarfRegNum<[26]>;
def TP  : Ri<29, "tp">,  DwarfRegNum<[29]>;
def SR  : Ri<30, "sr">,  DwarfRegNum<[30]>;
def PC  : Ri<31, "pc">,  DwarfRegNum<[31]>;

// Processor Control Registers
foreach I = 0-31 in
def P#I : Ri<I, "p"#I>, DwarfRegNum<[!add(I, 32)]>;

//===----------------------------------------------------------------------===//
//  Register Classes
//===----------------------------------------------------------------------===//

// General purpose registers
def GRegs : RegisterClass<"VC4", [i32, f32], 32,
  // Return values and arguments
  (add R0, R1, R2, R3, R4, R5,
  // Callee save
  R6, R7, R8, R9, R10, R11, R14, R15)>;

// Extended allocatable registers
def ERegs : RegisterClass<"VC4", [i32, f32], 32,
  (add R0, R1, R2, R3, R4, R5,
   R6, R7, R8, R9, R10, R11, R14, R15,
   // Extended
   R16, R17, R18, R19, R20, R21, R22, R23)>;

// Reserved
def RRegs : RegisterClass<"VC4", [i32, f32], 32,
  (add R0, R1, R2, R3, R4, R5,
   R6, R7, R8, R9, R10, R11, R14, R15,
   // Extended
   R16, R17, R18, R19, R20, R21, R22, R23,
   // Unallocatable
   GP, SP, LR, TP, SR, PC)> {
  let isAllocatable = 0;
}

// Control registers
def PRegs : RegisterClass<"VC4", [i32], 32,
  (add P0, P1, P2, P3, P4, P5, P6, P7,
   P8, P9, P10, P11, P12, P13, P14, P15,
   P16, P17, P18, P19, P20, P21, P22, P23,
   P24, P25, P26, P27, P28, P29, P30, P31)>;
