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

static MCInstrInfo*
createVC4MCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitVC4MCInstrInfo(X);
  return X;
}

static MCRegisterInfo*
createVC4MCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitVC4MCRegisterInfo(X, VC4::LR);
  return X;
}

static MCSubtargetInfo*
createVC4MCSubtargetInfo(const Triple &TT, StringRef CPU, StringRef FS) {
  return createVC4MCSubtargetInfoImpl(TT, CPU, FS);
}

static MCInstPrinter*
createVC4MCInstPrinter(const Triple &/*TT*/,
                       unsigned /*SyntaxVariant*/,
                       const MCAsmInfo &MAI,
                       const MCInstrInfo &MII,
                       const MCRegisterInfo &MRI) {
  return new VC4InstPrinter(MAI, MII, MRI);
}

// Force static initialization.
extern "C"
void LLVMInitializeVC4TargetMC() {
  // Register the MC asm info.
  RegisterMCAsmInfoFn X(getTheVC4Target(), createVC4MCAsmInfo);

  // Register the MC instruction info.
  TargetRegistry::RegisterMCInstrInfo(getTheVC4Target(),
                                      createVC4MCInstrInfo);

  // Register the MC register info.
  TargetRegistry::RegisterMCRegInfo(getTheVC4Target(),
                                    createVC4MCRegisterInfo);

  // Register the MC subtarget info.
  TargetRegistry::RegisterMCSubtargetInfo(getTheVC4Target(),
                                          createVC4MCSubtargetInfo);

  // Register the MCInstPriner
  TargetRegistry::RegisterMCInstPrinter(getTheVC4Target(),
                                        createVC4MCInstPrinter);
}
