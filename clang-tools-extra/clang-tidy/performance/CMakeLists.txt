set(LLVM_LINK_COMPONENTS support)

add_clang_library(clangTidyPerformanceModule
  FasterStringFindCheck.cpp
  ForRangeCopyCheck.cpp
  ImplicitCastInLoopCheck.cpp
  InefficientStringConcatenationCheck.cpp
  PerformanceTidyModule.cpp
  TypePromotionInMathFnCheck.cpp
  UnnecessaryCopyInitialization.cpp
  UnnecessaryValueParamCheck.cpp

  LINK_LIBS
  clangAST
  clangASTMatchers
  clangBasic
  clangLex
  clangTidy
  clangTidyUtils
  )
