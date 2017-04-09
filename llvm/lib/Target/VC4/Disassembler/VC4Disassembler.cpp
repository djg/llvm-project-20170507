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


DecodeStatus
VC4Disassembler::getInstruction(
    MCInst &instr, uint64_t &Size, ArrayRef<uint8_t> Bytes, uint64_t Address,
    raw_ostream &vStream, raw_ostream &cStream) const {
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
