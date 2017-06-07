#include "VC4.h"
#include "VC4RegisterInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCFixedLenDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "vc4-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {

/// \brief A disassembler class for VC4.
class VC4Disassembler : public MCDisassembler {
public:
  VC4Disassembler(const MCSubtargetInfo &STI, MCContext &Ctx)
      : MCDisassembler(STI, Ctx) {}

  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &VStream,
                              raw_ostream &CStream) const override;
};
}

template <typename InsnType>
static InsnType fieldFromInstruction(InsnType Insn, unsigned StartBit,
                                     unsigned NumBits) {
  assert(StartBit + NumBits <= (sizeof(InsnType) * 8) &&
         "Instruction field out of bounds!");
  InsnType fieldMask;
  if (NumBits == sizeof(InsnType) * 8) {
    fieldMask = (InsnType)(~0LL);
  } else {
    fieldMask = (((InsnType)1 << NumBits) - 1) << StartBit;
  }
  return (Insn & fieldMask) >> StartBit;
}

static bool readInstruction16(ArrayRef<uint8_t> Bytes, uint64_t Address,
                              uint64_t &Size, uint16_t &Insn) {
  // We want to read exactly 2 bytes of data.
  if (Bytes.size() < 2) {
    Size = 0;
    return false;
  }
  // Encoded as a little-endian 16-bit word in the stream.
  Insn = (Bytes[0] << 0) | (Bytes[1] << 8);
  Size = 2;
  DEBUG(dbgs() << format("%x: %02x %02x - 0x%04x\n", Address, Bytes[0],
                         Bytes[1], Insn));
  return true;
}

static bool readInstruction32(ArrayRef<uint8_t> Bytes, uint64_t Address,
                              uint64_t &Size, uint32_t &Insn) {
  // We want to read exactly 4 bytes of data.
  if (Bytes.size() < 4) {
    Size = 0;
    return false;
  }
  // Encoded as two little-endian 16-bit word in the stream.
  Insn =
      (Bytes[0] << 16) | (Bytes[1] << 24) | (Bytes[2] << 0) | (Bytes[3] << 8);
  Size = 4;
  DEBUG(dbgs() << format("%x: %02x %02x %02x %02x - 0x%08x\n", Address,
                         Bytes[0], Bytes[1], Bytes[2], Bytes[3], Insn));
  return true;
}

static bool readInstruction48(ArrayRef<uint8_t> Bytes, uint64_t Address,
                              uint64_t &Size, uint64_t &Insn) {
  // We want to read exactly 6 bytes of data.
  if (Bytes.size() < 6) {
    Size = 0;
    return false;
  }

  // Encoded as a little-endian 16-bit word followed by little-endian 32-bit
  // word in the stream.
  Insn = ((uint64_t)Bytes[0] << 32) | ((uint64_t)Bytes[1] << 40) |
         (Bytes[2] << 0) | (Bytes[3] << 8) | (Bytes[4] << 16) |
         (Bytes[5] << 24);
  Size = 6;
  DEBUG(dbgs() << format("%x: %02x %02x %02x %02x %02x %02x - 0x%012x\n",
                         Address, Bytes[0], Bytes[1], Bytes[2], Bytes[3],
                         Bytes[4], Bytes[5], Insn));
  return true;
}

static unsigned getReg(const void *D, unsigned RC, unsigned RegNo) {
  const VC4Disassembler *Dis = static_cast<const VC4Disassembler *>(D);
  const MCRegisterInfo *RegInfo = Dis->getContext().getRegisterInfo();
  return *(RegInfo->getRegClass(RC).begin() + RegNo);
}

static DecodeStatus decodeGRegsRegisterClass(MCInst &Inst, unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder) {
  if (RegNo > 15)
    return MCDisassembler::Fail;
  unsigned Reg = getReg(Decoder, VC4::GRegsRegClassID, RegNo);
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus decodeERegsRegisterClass(MCInst &Inst, unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder) {
  if (RegNo > 23)
    return MCDisassembler::Fail;
  unsigned Reg = getReg(Decoder, VC4::ERegsRegClassID, RegNo);
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

template <typename InsnType>
static void decodeSignedImm(MCInst &Inst, InsnType Insn, unsigned StartBit,
                            unsigned NumBits) {
  InsnType f = fieldFromInstruction(Insn, StartBit, NumBits);
  int64_t simm = (f & (1 << (NumBits - 1))) ? -f : f;
  Inst.addOperand(MCOperand::createImm(simm));
}

static DecodeStatus decodeScalar16(MCInst &Inst, uint16_t Insn,
                                   uint64_t Address, const void *Decoder);

static DecodeStatus decodeScalar32(MCInst &Inst, uint32_t Insn,
                                   uint64_t Address, const void *Decoder);

static DecodeStatus decodeScalar48(MCInst &Inst, uint64_t Insn,
                                   uint64_t Address, const void *Decoder);

DecodeStatus VC4Disassembler::getInstruction(MCInst &instr, uint64_t &Size,
                                             ArrayRef<uint8_t> Bytes,
                                             uint64_t Address,
                                             raw_ostream &vStream,
                                             raw_ostream &cStream) const {
  DecodeStatus status = Fail;

  if (Bytes.size() < 2)
    return Fail;

  // The MSB of the first 16-bits contains the instruction size encoding.
  uint8_t insn_msb = Bytes[1];
  if ((insn_msb & 0xF) == 0xE0) {
    uint64_t insn48;
    // Scalar48 instruction
    if (!readInstruction48(Bytes, Address, Size, insn48))
      return Fail;
    status = decodeScalar48(instr, insn48, Address, this);
  } else if ((insn_msb & 0x80) == 0x80) {
    // Scalar32 instruction
    uint32_t insn32;
    if (!readInstruction32(Bytes, Address, Size, insn32))
      return Fail;
    status = decodeScalar32(instr, insn32, Address, this);
  } else {
    // Scalar16 instruction
    uint16_t insn16;
    if (!readInstruction16(Bytes, Address, Size, insn16))
      return Fail;
    status = decodeScalar16(instr, insn16, Address, this);
  }
  instr.dump();
  return status;
}

//===----------------------------------------------------------------------===//
// Scalar16 - 16-bit instructions

// 0000 0000 0000 xxxx
static DecodeStatus decodeScalar16_0(MCInst &Inst, uint16_t Insn,
                                     uint64_t Address, const void *Decoder) {
  switch (fieldFromInstruction(Insn, 0, 4)) {
  default:
    return MCDisassembler::Fail;
  case 0x0:
    Inst.setOpcode(VC4::BKPT);
    break;
  case 0x1:
    Inst.setOpcode(VC4::NOP);
    break;
  case 0x2:
    Inst.setOpcode(VC4::SLEEP);
    break;
  case 0x3:
    Inst.setOpcode(VC4::USER);
    break;
  case 0x4:
    Inst.setOpcode(VC4::EI);
    break;
  case 0x5:
    Inst.setOpcode(VC4::DI);
    break;
  case 0x6:
    Inst.setOpcode(VC4::CBCLR);
    break;
  case 0x7:
    Inst.setOpcode(VC4::CBADD1);
    break;
  case 0x8:
    Inst.setOpcode(VC4::CBADD2);
    break;
  case 0x9:
    Inst.setOpcode(VC4::CBADD3);
    break;
  case 0xA:
    Inst.setOpcode(VC4::RTI);
    break;
  }

  return MCDisassembler::Success;
}

static DecodeStatus decodeScalar16_1r(MCInst &Inst, uint16_t Insn,
                                      uint64_t Address, const void *Decoder) {
  assert(fieldFromInstruction(Insn, 8, 8) == 0 && "Invalid Instruction");
  unsigned regNo = fieldFromInstruction(Insn, 0, 5);

  switch (fieldFromInstruction(Insn, 5, 3)) {
  default:
    return MCDisassembler::Fail;
  case 0x1:
    // Inst.setOpcode(VC4::SWI_1r5);
    return decodeERegsRegisterClass(Inst, regNo, Address, Decoder);
  case 0x2:
    // Inst.setOpcode(VC4::B_1r5);
    return decodeERegsRegisterClass(Inst, regNo, Address, Decoder);
  case 0x3:
    Inst.setOpcode(VC4::BL_1r5);
    return decodeERegsRegisterClass(Inst, regNo, Address, Decoder);
  case 0x4:
    Inst.setOpcode(VC4::SWITCHB);
    return decodeGRegsRegisterClass(Inst, regNo, Address, Decoder);
  case 0x5:
    Inst.setOpcode(VC4::SWITCH);
    return decodeGRegsRegisterClass(Inst, regNo, Address, Decoder);
  case 0x7:
    Inst.setOpcode(VC4::VERSION);
    return decodeERegsRegisterClass(Inst, regNo, Address, Decoder);
  }
}

// 011o ooou uuuu dddd - op  rd, u
static DecodeStatus decodeScalar16_ALU(MCInst &Inst, uint16_t Insn,
                                       uint64_t Address, const void *Decoder) {
  bool imm = fieldFromInstruction(Insn, 13, 1);
  DEBUG(
      dbgs()
      << (imm ? "Register with Immediate logical and arithmetic operations\n"
              : "Register with Register logical and arithmetic operations\n"));

  unsigned opcode = imm ? fieldFromInstruction(Insn, 9, 4) << 1
                        : fieldFromInstruction(Insn, 8, 5);

  switch (opcode) {
  case 0x0: // MOV
    DEBUG(dbgs() << "MOV\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0x1: // CMN
    DEBUG(dbgs() << "CMN\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0x2: // ADD
    DEBUG(dbgs() << "ADD\n");
    Inst.setOpcode(imm ? VC4::ADD_1r4i5 : VC4::ADD_2r4);
    break;
  case 0x3: // BIC
    DEBUG(dbgs() << "BIC\n");
    Inst.setOpcode(VC4::BIC_2r4);
    break;
  case 0x4: // MUL
    DEBUG(dbgs() << "MUL\n");
    Inst.setOpcode(imm ? VC4::MUL_1r4i5 : VC4::MUL_2r4);
    break;
  case 0x5: // EOR
    DEBUG(dbgs() << "EOR\n");
    Inst.setOpcode(VC4::EOR_2r4);
    break;
  case 0x6: // SUB
    DEBUG(dbgs() << "SUB\n");
    Inst.setOpcode(imm ? VC4::SUB_1r4i5 : VC4::SUB_2r4);
    break;
  case 0x7: // AND
    DEBUG(dbgs() << "AND\n");
    Inst.setOpcode(VC4::AND_2r4);
    break;
  case 0x8: // NOT
    DEBUG(dbgs() << "NOT\n");
    Inst.setOpcode(imm ? VC4::NOT_1r4i5 : VC4::NOT_2r4);
    break;
  case 0x9: // ROR
    DEBUG(dbgs() << "ROR\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0xA: // CMP
    DEBUG(dbgs() << "CMP\n");
    Inst.setOpcode(imm ? VC4::ADD_1r4i5 : VC4::ADD_2r4);
    break;
  case 0xB: // RSUB
    DEBUG(dbgs() << "RSUB\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0xC: // BTEST
    DEBUG(dbgs() << "BTEST\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0xD: // OR
    DEBUG(dbgs() << "OR\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0xE: // BMASK
    DEBUG(dbgs() << "BMASK\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0xF: // MAX
    DEBUG(dbgs() << "MAX\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0x10: // BITSET
    DEBUG(dbgs() << "BITSET\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0x11: // MIN
    DEBUG(dbgs() << "MIN\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0x12: // BITCLEAR
    DEBUG(dbgs() << "BITCLEAR\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0x13: // ADDSCALE2
    DEBUG(dbgs() << "ADDSCALE2\n");
    Inst.setOpcode(VC4::ADDSCALE2_2r4);
    break;
  case 0x14: // BITFLIP
    DEBUG(dbgs() << "BITFLIP\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0x15: // ADDSCALE4
    DEBUG(dbgs() << "ADDSCALE4\n");
    Inst.setOpcode(VC4::ADDSCALE4_2r4);
    break;
  case 0x16: // ADDSCALE8
    DEBUG(dbgs() << "ADDSCALE8\n");
    Inst.setOpcode(imm ? VC4::ADDSCALE8_1r4i5 : VC4::ADDSCALE8_2r4);
    break;
  case 0x17: // ADDSCALE16
    DEBUG(dbgs() << "ADDSCALE16\n");
    Inst.setOpcode(VC4::ADDSCALE16_2r4);
    break;
  case 0x18: // SIGNEXT
    DEBUG(dbgs() << "SIGNEXT\n");
    Inst.setOpcode(VC4::ADD_1r4i5);
    break;
  case 0x19: // NEG
    DEBUG(dbgs() << "NEG\n");
    Inst.setOpcode(VC4::ADD_2r4);
    break;
  case 0x1A: // LSR
    DEBUG(dbgs() << "LSR\n");
    Inst.setOpcode(imm ? VC4::LSR_1r4i5 : VC4::LSR_2r4);
    break;
  case 0x1B: // MSB
    DEBUG(dbgs() << "MSB\n");
    Inst.setOpcode(VC4::ADD_2r4);
    break;
  case 0x1C: // SHL
    DEBUG(dbgs() << "SHL\n");
    Inst.setOpcode(imm ? VC4::SHL_1r4i5 : VC4::SHL_2r4);
    break;
  case 0x1D: // BREV
    DEBUG(dbgs() << "BREV\n");
    Inst.setOpcode(VC4::ADD_2r4);
    break;
  case 0x1E: // ASR
    DEBUG(dbgs() << "ASR\n");
    Inst.setOpcode(imm ? VC4::ASR_1r4i5 : VC4::ASR_2r4);
    break;
  case 0x1F: // ABS
    DEBUG(dbgs() << "ABS\n");
    Inst.setOpcode(VC4::ADD_2r4);
    break;
  }

  unsigned rd = fieldFromInstruction(Insn, 0, 4);
  decodeGRegsRegisterClass(Inst, rd, Address, Decoder);
  decodeGRegsRegisterClass(Inst, rd, Address, Decoder);

  if (imm) {
    decodeSignedImm(Inst, Insn, 4, 5);
  } else {
    decodeGRegsRegisterClass(Inst, fieldFromInstruction(Insn, 4, 4), Address,
                             Decoder);
  }

  return MCDisassembler::Success;
}

static DecodeStatus decodeScalar16(MCInst &Inst, uint16_t Insn,
                                   uint64_t Address, const void *Decoder) {
  if (fieldFromInstruction(Insn, 14, 1)) {
    return decodeScalar16_ALU(Inst, Insn, Address, Decoder);
  } else if (fieldFromInstruction(Insn, 13, 1)) {
    DEBUG(dbgs() << "Load/Store with Register relative offset\n");
  } else if (fieldFromInstruction(Insn, 12, 1)) {
    if (fieldFromInstruction(Insn, 11, 1)) {
      DEBUG(dbgs() << "Branch on condition to target\n");
    } else {
      DEBUG(dbgs() << "Add relative to stack pointer\n");
    }
  } else if (fieldFromInstruction(Insn, 11, 1)) {
    DEBUG(dbgs() << "Load/Store via Register\n");
  } else if (fieldFromInstruction(Insn, 10, 1)) {
    DEBUG(dbgs() << "Load/Store relative to stack pointer\n");
  } else if (fieldFromInstruction(Insn, 9, 1)) {
    DEBUG(dbgs() << "Load/Store multiple\n");
  } else if (fieldFromInstruction(Insn, 8, 1)) {
    DEBUG(dbgs() << "Software Interrupt - Immediate\n");
  } else if (fieldFromInstruction(Insn, 5, 3)) {
    return decodeScalar16_1r(Inst, Insn, Address, Decoder);
  } else {
    return decodeScalar16_0(Inst, Insn, Address, Decoder);
  }

  return MCDisassembler::Fail;
}

//===----------------------------------------------------------------------===//
static DecodeStatus decodeScalar32(MCInst &Inst, uint32_t Insn,
                                   uint64_t Address, const void *Decoder) {
  return MCDisassembler::Fail;
}

//===----------------------------------------------------------------------===//
static DecodeStatus decodeScalar48(MCInst &Inst, uint64_t Insn,
                                   uint64_t Address, const void *Decoder) {
  return MCDisassembler::Fail;
}

namespace llvm {
Target &getTheVC4Target();
}

static MCDisassembler *createVC4Disassembler(const Target &T,
                                             const MCSubtargetInfo &STI,
                                             MCContext &Ctx) {
  return new VC4Disassembler(STI, Ctx);
}

extern "C" void LLVMInitializeVC4Disassembler() {
  // Register the disassembler.
  TargetRegistry::RegisterMCDisassembler(getTheVC4Target(),
                                         createVC4Disassembler);
}
