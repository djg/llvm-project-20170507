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
  VC4Disassembler(const MCSubtargetInfo &STI, MCContext &Ctx) :
    MCDisassembler(STI, Ctx) {}

  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &VStream,
                              raw_ostream &CStream) const override;
};
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
  Insn = (Bytes[0] << 16) | (Bytes[1] << 24) | (Bytes[2] << 0) | (Bytes[3] << 8);
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
  Insn =
    ((uint64_t) Bytes[0] << 32) | ((uint64_t) Bytes[1] << 40) |
    (Bytes[2] << 0) | (Bytes[3] << 8) | (Bytes[4] << 16) | (Bytes[5] << 24);
  return true;
}

static unsigned getReg(const void *D, unsigned RC, unsigned RegNo) {
  const VC4Disassembler *Dis = static_cast<const VC4Disassembler *>(D);
  const MCRegisterInfo *RegInfo = Dis->getContext().getRegisterInfo();
  return *(RegInfo->getRegClass(RC).begin() + RegNo);
}

static DecodeStatus DecodeGRegsRegisterClass(MCInst &Inst, unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder);

static DecodeStatus DecodeERegsRegisterClass(MCInst &Inst, unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder);

static DecodeStatus DecodeGRegsRegisterClass(MCInst &Inst, unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder) {
  if (RegNo > 15)
    return MCDisassembler::Fail;
  unsigned Reg = getReg(Decoder, VC4::GRegsRegClassID, RegNo);
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeERegsRegisterClass(MCInst &Inst, unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder) {
  if (RegNo > 23)
    return MCDisassembler::Fail;
  unsigned Reg = getReg(Decoder, VC4::ERegsRegClassID, RegNo);
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

DecodeStatus
VC4Disassembler::getInstruction(
    MCInst &instr, uint64_t &Size, ArrayRef<uint8_t> Bytes, uint64_t Address,
    raw_ostream &vStream, raw_ostream &cStream) const {
  uint16_t insn16;

  if (!readInstruction16(Bytes, Address, Size, insn16))
    return Fail;

  return Fail;
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
