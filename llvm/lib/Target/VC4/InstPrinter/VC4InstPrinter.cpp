#include "VC4InstPrinter.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include <cassert>

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

#define PRINT_ALIAS_INSTR
#include "VC4GenAsmWriter.inc"

static bool
isImm5(unsigned Imm) {
  return isInt<5>(Imm);
}

void
VC4InstPrinter::printRegName(raw_ostream &OS, unsigned RegNo) const {
  OS << StringRef(getRegisterName(RegNo)).lower();
}

void
VC4InstPrinter::printInst(const MCInst *MI, raw_ostream &O, StringRef Annot,
                          const MCSubtargetInfo &STI) {
  // Try to print any aliases first.
  if (!printAliasInstr(MI, O))
    printInstruction(MI, O);
  printAnnotation(O, Annot);
}

void
VC4InstPrinter::printOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isReg()) {
    printRegName(O, Op.getReg());
    return;
  }

  if (Op.isImm()) {
    O << Op.getImm();
    return;
  }

  assert(Op.isExpr() && "unknown operand kind in printOperand");
  Op.getExpr()->print(O, &MAI, true);
}

void
VC4InstPrinter::printSPOffset5x4ImmOperand(const MCInst *MI,
                                  unsigned OpNum,
                                  raw_ostream &O)
{
  unsigned Imm = MI->getOperand(OpNum).getImm();
  assert(isImm5(Imm) && "illegal SP offset!");
  O << markup("<imm:") << (4 * Imm) << markup(">");
}
