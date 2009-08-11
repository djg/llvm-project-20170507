//===----------- ValueTypes.cpp - Implementation of EVT methods -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements methods in the CodeGen/ValueTypes.h header.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringExtras.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/LLVMContext.h"
#include "llvm/Type.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Support/ErrorHandling.h"
using namespace llvm;

EVT EVT::getExtendedIntegerVT(unsigned BitWidth) {
  EVT VT;
  VT.LLVMTy = IntegerType::get(BitWidth);
  assert(VT.isExtended() && "Type is not extended!");
  return VT;
}

EVT EVT::getExtendedVectorVT(EVT VT, unsigned NumElements) {
  EVT ResultVT;
  ResultVT.LLVMTy = VectorType::get(VT.getTypeForEVT(), NumElements);
  assert(ResultVT.isExtended() && "Type is not extended!");
  return ResultVT;
}

bool EVT::isExtendedFloatingPoint() const {
  assert(isExtended() && "Type is not extended!");
  return LLVMTy->isFPOrFPVector();
}

bool EVT::isExtendedInteger() const {
  assert(isExtended() && "Type is not extended!");
  return LLVMTy->isIntOrIntVector();
}

bool EVT::isExtendedVector() const {
  assert(isExtended() && "Type is not extended!");
  return isa<VectorType>(LLVMTy);
}

bool EVT::isExtended64BitVector() const {
  return isExtendedVector() && getSizeInBits() == 64;
}

bool EVT::isExtended128BitVector() const {
  return isExtendedVector() && getSizeInBits() == 128;
}

bool EVT::isExtended256BitVector() const {
  return isExtendedVector() && getSizeInBits() == 256;
}

EVT EVT::getExtendedVectorElementType() const {
  assert(isExtended() && "Type is not extended!");
  return EVT::getEVT(cast<VectorType>(LLVMTy)->getElementType());
}

unsigned EVT::getExtendedVectorNumElements() const {
  assert(isExtended() && "Type is not extended!");
  return cast<VectorType>(LLVMTy)->getNumElements();
}

unsigned EVT::getExtendedSizeInBits() const {
  assert(isExtended() && "Type is not extended!");
  if (const IntegerType *ITy = dyn_cast<IntegerType>(LLVMTy))
    return ITy->getBitWidth();
  if (const VectorType *VTy = dyn_cast<VectorType>(LLVMTy))
    return VTy->getBitWidth();
  assert(false && "Unrecognized extended type!");
  return 0; // Suppress warnings.
}

/// getEVTString - This function returns value type as a string, e.g. "i32".
std::string EVT::getEVTString() const {
  switch (V.SimpleTy) {
  default:
    if (isVector())
      return "v" + utostr(getVectorNumElements()) +
             getVectorElementType().getEVTString();
    if (isInteger())
      return "i" + utostr(getSizeInBits());
    llvm_unreachable("Invalid EVT!");
    return "?";
  case MVT::i1:      return "i1";
  case MVT::i8:      return "i8";
  case MVT::i16:     return "i16";
  case MVT::i32:     return "i32";
  case MVT::i64:     return "i64";
  case MVT::i128:    return "i128";
  case MVT::f32:     return "f32";
  case MVT::f64:     return "f64";
  case MVT::f80:     return "f80";
  case MVT::f128:    return "f128";
  case MVT::ppcf128: return "ppcf128";
  case MVT::isVoid:  return "isVoid";
  case MVT::Other:   return "ch";
  case MVT::Flag:    return "flag";
  case MVT::v2i8:    return "v2i8";
  case MVT::v4i8:    return "v4i8";
  case MVT::v8i8:    return "v8i8";
  case MVT::v16i8:   return "v16i8";
  case MVT::v32i8:   return "v32i8";
  case MVT::v2i16:   return "v2i16";
  case MVT::v4i16:   return "v4i16";
  case MVT::v8i16:   return "v8i16";
  case MVT::v16i16:  return "v16i16";
  case MVT::v2i32:   return "v2i32";
  case MVT::v4i32:   return "v4i32";
  case MVT::v8i32:   return "v8i32";
  case MVT::v1i64:   return "v1i64";
  case MVT::v2i64:   return "v2i64";
  case MVT::v4i64:   return "v4i64";
  case MVT::v2f32:   return "v2f32";
  case MVT::v4f32:   return "v4f32";
  case MVT::v8f32:   return "v8f32";
  case MVT::v2f64:   return "v2f64";
  case MVT::v4f64:   return "v4f64";
  }
}

/// getTypeForEVT - This method returns an LLVM type corresponding to the
/// specified EVT.  For integer types, this returns an unsigned type.  Note
/// that this will abort for types that cannot be represented.
const Type *EVT::getTypeForEVT() const {
  switch (V.SimpleTy) {
  default:
    assert(isExtended() && "Type is not extended!");
    return LLVMTy;
  case MVT::isVoid:  return Type::VoidTy;
  case MVT::i1:      return Type::Int1Ty;
  case MVT::i8:      return Type::Int8Ty;
  case MVT::i16:     return Type::Int16Ty;
  case MVT::i32:     return Type::Int32Ty;
  case MVT::i64:     return Type::Int64Ty;
  case MVT::i128:    return IntegerType::get(128);
  case MVT::f32:     return Type::FloatTy;
  case MVT::f64:     return Type::DoubleTy;
  case MVT::f80:     return Type::X86_FP80Ty;
  case MVT::f128:    return Type::FP128Ty;
  case MVT::ppcf128: return Type::PPC_FP128Ty;
  case MVT::v2i8:    return VectorType::get(Type::Int8Ty, 2);
  case MVT::v4i8:    return VectorType::get(Type::Int8Ty, 4);
  case MVT::v8i8:    return VectorType::get(Type::Int8Ty, 8);
  case MVT::v16i8:   return VectorType::get(Type::Int8Ty, 16);
  case MVT::v32i8:   return VectorType::get(Type::Int8Ty, 32);
  case MVT::v2i16:   return VectorType::get(Type::Int16Ty, 2);
  case MVT::v4i16:   return VectorType::get(Type::Int16Ty, 4);
  case MVT::v8i16:   return VectorType::get(Type::Int16Ty, 8);
  case MVT::v16i16:  return VectorType::get(Type::Int16Ty, 16);
  case MVT::v2i32:   return VectorType::get(Type::Int32Ty, 2);
  case MVT::v4i32:   return VectorType::get(Type::Int32Ty, 4);
  case MVT::v8i32:   return VectorType::get(Type::Int32Ty, 8);
  case MVT::v1i64:   return VectorType::get(Type::Int64Ty, 1);
  case MVT::v2i64:   return VectorType::get(Type::Int64Ty, 2);
  case MVT::v4i64:   return VectorType::get(Type::Int64Ty, 4);
  case MVT::v2f32:   return VectorType::get(Type::FloatTy, 2);
  case MVT::v4f32:   return VectorType::get(Type::FloatTy, 4);
  case MVT::v8f32:   return VectorType::get(Type::FloatTy, 8);
  case MVT::v2f64:   return VectorType::get(Type::DoubleTy, 2);
  case MVT::v4f64:   return VectorType::get(Type::DoubleTy, 4); 
 }
}

/// getEVT - Return the value type corresponding to the specified type.  This
/// returns all pointers as MVT::iPTR.  If HandleUnknown is true, unknown types
/// are returned as Other, otherwise they are invalid.
EVT EVT::getEVT(const Type *Ty, bool HandleUnknown){
  switch (Ty->getTypeID()) {
  default:
    if (HandleUnknown) return MVT(MVT::Other);
    llvm_unreachable("Unknown type!");
    return MVT(MVT::isVoid);
  case Type::VoidTyID:
    return MVT(MVT::isVoid);
  case Type::IntegerTyID:
    return getIntegerVT(cast<IntegerType>(Ty)->getBitWidth());
  case Type::FloatTyID:     return MVT(MVT::f32);
  case Type::DoubleTyID:    return MVT(MVT::f64);
  case Type::X86_FP80TyID:  return MVT(MVT::f80);
  case Type::FP128TyID:     return MVT(MVT::f128);
  case Type::PPC_FP128TyID: return MVT(MVT::ppcf128);
  case Type::PointerTyID:   return MVT(MVT::iPTR);
  case Type::VectorTyID: {
    const VectorType *VTy = cast<VectorType>(Ty);
    return getVectorVT(getEVT(VTy->getElementType(), false),
                       VTy->getNumElements());
  }
  }
}
