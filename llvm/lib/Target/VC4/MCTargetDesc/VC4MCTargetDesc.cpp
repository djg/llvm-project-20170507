#include "InstPrinter/VC4InstPrinter.h"
#include "MCTargetDesc/VC4MCAsmInfo.h"
#include "MCTargetDesc/VC4MCTargetDesc.h"
//#include "VC4TargetStreamer.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#include "VC4GenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "VC4GenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "VC4GenRegisterInfo.inc"

static MCAsmInfo*
createVC4MCAsmInfo(const MCRegisterInfo &MRI,
                   const Triple &TT) {
  MCAsmInfo* MAI = new VC4MCAsmInfo(TT);

  // Initial state of the frame pointer is SP.
  MCCFIInstruction Inst = MCCFIInstruction::createDefCfa(nullptr, VC4::SP, 0);
  MAI->addInitialFrameState(Inst);

  return MAI;
}

// Force static initialization.
extern "C"
void LLVMInitializeVC4TargetMC() {
  // Register the MC asm info.
  RegisterMCAsmInfoFn X(getTheVC4Target(), createVC4MCAsmInfo);
}
