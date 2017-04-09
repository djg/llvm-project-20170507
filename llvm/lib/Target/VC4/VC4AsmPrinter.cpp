//===-- VC4AsmPrinter.cpp - VC4 LLVM assembly writer ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to the XAS-format VC4 assembly language.
//
//===----------------------------------------------------------------------===//

#include "VC4.h"
#include "InstPrinter/VC4InstPrinter.h"
#include "VC4InstrInfo.h"
//#include "VC4MCInstLower.h"
#include "VC4Subtarget.h"
#include "VC4TargetMachine.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Mangler.h"
#include "llvm/IR/Module.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include <algorithm>
#include <cctype>
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

namespace {
  class VC4AsmPrinter : public AsmPrinter {
  public:
    explicit VC4AsmPrinter(TargetMachine &TM,
                           std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

    StringRef getPassName() const override { return "VC4 Assembly Printer"; }

/*
    void printInlineJT(const MachineInstr *MI, int opNum, raw_ostream &O,
                       const std::string &directive = ".jmptable");
    void printInlineJT32(const MachineInstr *MI, int opNum, raw_ostream &O) {
      printInlineJT(MI, opNum, O, ".jmptable32");
    }
*/
    void printOperand(const MachineInstr *MI, int opNum, raw_ostream &O);
/*
    bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                         unsigned AsmVariant, const char *ExtraCode,
                         raw_ostream &O) override;
    bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNum,
                               unsigned AsmVariant, const char *ExtraCode,
                               raw_ostream &O) override;

    void emitArrayBound(MCSymbol *Sym, const GlobalVariable *GV);
    void EmitGlobalVariable(const GlobalVariable *GV) override;

    void EmitFunctionEntryLabel() override;
    void EmitInstruction(const MachineInstr *MI) override;
    void EmitFunctionBodyStart() override;
    void EmitFunctionBodyEnd() override;
*/
  };
} // end of anonymous namespace

/*
void
VC4AsmPrinter::emitArrayBound(MCSymbol *Sym, const GlobalVariable *GV) {
  assert( ( GV->hasExternalLinkage() || GV->hasWeakLinkage() ||
            GV->hasLinkOnceLinkage() || GV->hasCommonLinkage() ) &&
          "Unexpected linkage");
  if (ArrayType *ATy = dyn_cast<ArrayType>(GV->getValueType())) {

    MCSymbol *SymGlob = OutContext.getOrCreateSymbol(
                          Twine(Sym->getName() + StringRef(".globound")));
    OutStreamer->EmitSymbolAttribute(SymGlob, MCSA_Global);
    OutStreamer->EmitAssignment(SymGlob,
                                MCConstantExpr::create(ATy->getNumElements(),
                                                       OutContext));
    if (GV->hasWeakLinkage() || GV->hasLinkOnceLinkage() ||
        GV->hasCommonLinkage()) {
      OutStreamer->EmitSymbolAttribute(SymGlob, MCSA_Weak);
    }
  }
}

void VC4AsmPrinter::EmitGlobalVariable(const GlobalVariable *GV) {
  // Check to see if this is a special global used by LLVM, if so, emit it.
  if (!GV->hasInitializer() ||
      EmitSpecialLLVMGlobal(GV))
    return;

  const DataLayout &DL = getDataLayout();
  OutStreamer->SwitchSection(getObjFileLowering().SectionForGlobal(GV, TM));

  MCSymbol *GVSym = getSymbol(GV);
  const Constant *C = GV->getInitializer();
  unsigned Align = (unsigned)DL.getPreferredTypeAlignmentShift(C->getType());

  // Mark the start of the global
  getTargetStreamer().emitCCTopData(GVSym->getName());

  switch (GV->getLinkage()) {
  case GlobalValue::AppendingLinkage:
    report_fatal_error("AppendingLinkage is not supported by this target!");
  case GlobalValue::LinkOnceAnyLinkage:
  case GlobalValue::LinkOnceODRLinkage:
  case GlobalValue::WeakAnyLinkage:
  case GlobalValue::WeakODRLinkage:
  case GlobalValue::ExternalLinkage:
  case GlobalValue::CommonLinkage:
    emitArrayBound(GVSym, GV);
    OutStreamer->EmitSymbolAttribute(GVSym, MCSA_Global);

    if (GV->hasWeakLinkage() || GV->hasLinkOnceLinkage() ||
        GV->hasCommonLinkage())
      OutStreamer->EmitSymbolAttribute(GVSym, MCSA_Weak);
    LLVM_FALLTHROUGH;
  case GlobalValue::InternalLinkage:
  case GlobalValue::PrivateLinkage:
    break;
  default:
    llvm_unreachable("Unknown linkage type!");
  }

  EmitAlignment(Align > 2 ? Align : 2, GV);

  if (GV->isThreadLocal()) {
    report_fatal_error("TLS is not supported by this target!");
  }
  unsigned Size = DL.getTypeAllocSize(C->getType());
  if (MAI->hasDotTypeDotSizeDirective()) {
    OutStreamer->EmitSymbolAttribute(GVSym, MCSA_ELF_TypeObject);
    OutStreamer->emitELFSize(GVSym, MCConstantExpr::create(Size, OutContext));
  }
  OutStreamer->EmitLabel(GVSym);

  EmitGlobalConstant(DL, C);
  // The ABI requires that unsigned scalar types smaller than 32 bits
  // are padded to 32 bits.
  if (Size < 4)
    OutStreamer->EmitZeros(4 - Size);

  // Mark the end of the global
  getTargetStreamer().emitCCBottomData(GVSym->getName());
}

void VC4AsmPrinter::EmitFunctionBodyStart() {
  MCInstLowering.Initialize(&MF->getContext());
}

/// EmitFunctionBodyEnd - Targets can override this to emit stuff after
/// the last basic block in the function.
void VC4AsmPrinter::EmitFunctionBodyEnd() {
  // Emit function end directives
  getTargetStreamer().emitCCBottomFunction(CurrentFnSym->getName());
}

void VC4AsmPrinter::EmitFunctionEntryLabel() {
  // Mark the start of the function
  getTargetStreamer().emitCCTopFunction(CurrentFnSym->getName());
  OutStreamer->EmitLabel(CurrentFnSym);
}

void VC4AsmPrinter::
printInlineJT(const MachineInstr *MI, int opNum, raw_ostream &O,
              const std::string &directive) {
  unsigned JTI = MI->getOperand(opNum).getIndex();
  const MachineFunction *MF = MI->getParent()->getParent();
  const MachineJumpTableInfo *MJTI = MF->getJumpTableInfo();
  const std::vector<MachineJumpTableEntry> &JT = MJTI->getJumpTables();
  const std::vector<MachineBasicBlock*> &JTBBs = JT[JTI].MBBs;
  O << "\t" << directive << " ";
  for (unsigned i = 0, e = JTBBs.size(); i != e; ++i) {
    MachineBasicBlock *MBB = JTBBs[i];
    if (i > 0)
      O << ",";
    MBB->getSymbol()->print(O, MAI);
  }
}
*/
void VC4AsmPrinter::printOperand(const MachineInstr *MI, int opNum,
                                   raw_ostream &O) {
  const DataLayout &DL = getDataLayout();
  const MachineOperand &MO = MI->getOperand(opNum);
  switch (MO.getType()) {
  case MachineOperand::MO_Register:
    O << VC4InstPrinter::getRegisterName(MO.getReg());
    break;
  case MachineOperand::MO_Immediate:
    O << MO.getImm();
    break;
  case MachineOperand::MO_MachineBasicBlock:
    MO.getMBB()->getSymbol()->print(O, MAI);
    break;
  case MachineOperand::MO_GlobalAddress:
    getSymbol(MO.getGlobal())->print(O, MAI);
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    O << DL.getPrivateGlobalPrefix() << "CPI" << getFunctionNumber() << '_'
      << MO.getIndex();
    break;
  case MachineOperand::MO_BlockAddress:
    GetBlockAddressSymbol(MO.getBlockAddress())->print(O, MAI);
    break;
  default:
    llvm_unreachable("not implemented");
  }
}

/// PrintAsmOperand - Print out an operand for an inline asm expression.
///
/*
bool VC4AsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                    unsigned AsmVariant,const char *ExtraCode,
                                    raw_ostream &O) {
  // Print the operand if there is no operand modifier.
  if (!ExtraCode || !ExtraCode[0]) {
    printOperand(MI, OpNo, O);
    return false;
  }

  // Otherwise fallback on the default implementation.
  return AsmPrinter::PrintAsmOperand(MI, OpNo, AsmVariant, ExtraCode, O);
}
*/

/*
bool VC4AsmPrinter::
PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNum,
                      unsigned AsmVariant, const char *ExtraCode,
                      raw_ostream &O) {
  if (ExtraCode && ExtraCode[0]) {
    return true; // Unknown modifier.
  }
  printOperand(MI, OpNum, O);
  O << '[';
  printOperand(MI, OpNum + 1, O);
  O << ']';
  return false;
}
*/

/*
void VC4AsmPrinter::EmitInstruction(const MachineInstr *MI) {
  SmallString<128> Str;
  raw_svector_ostream O(Str);

  switch (MI->getOpcode()) {
  case VC4::DBG_VALUE:
    llvm_unreachable("Should be handled target independently");
  case VC4::ADD_2rus:
    if (MI->getOperand(2).getImm() == 0) {
      O << "\tmov "
        << VC4InstPrinter::getRegisterName(MI->getOperand(0).getReg()) << ", "
        << VC4InstPrinter::getRegisterName(MI->getOperand(1).getReg());
      OutStreamer->EmitRawText(O.str());
      return;
    }
    break;
  case VC4::BR_JT:
  case VC4::BR_JT32:
    O << "\tbru "
      << VC4InstPrinter::getRegisterName(MI->getOperand(1).getReg()) << '\n';
    if (MI->getOpcode() == VC4::BR_JT)
      printInlineJT(MI, 0, O);
    else
      printInlineJT32(MI, 0, O);
    O << '\n';
    OutStreamer->EmitRawText(O.str());
    return;
  }

  MCInst TmpInst;
  MCInstLowering.Lower(MI, TmpInst);

  EmitToStreamer(*OutStreamer, TmpInst);
}
*/

// Force static initialization.
extern "C" void LLVMInitializeVC4AsmPrinter() {
  RegisterAsmPrinter<VC4AsmPrinter> X(getTheVC4Target());
}
