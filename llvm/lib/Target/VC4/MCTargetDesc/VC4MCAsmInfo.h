//===-- VC4MCAsmInfo.h - VideoCore-IV asm properties -----------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the VC4MCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_VC4_MCTARGETDESC_VC4MCASMINFO_H
#define LLVM_LIB_TARGET_VC4_MCTARGETDESC_VC4MCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class Triple;

class VC4MCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit VC4MCAsmInfo(const Triple &TT);
};

} // namespace llvm

#endif
