set(LLVM_TARGET_DEFINITIONS VC4.td)

tablegen(LLVM VC4GenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM VC4GenCallingConv.inc -gen-callingconv)
tablegen(LLVM VC4GenDAGIsel.inc -gen-dag-isel)
tablegen(LLVM VC4GenInstrInfo.inc -gen-instr-info)
tablegen(LLVM VC4GenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM VC4GenRegisterInfo.inc -gen-register-info)
tablegen(LLVM VC4GenSubtargetInfo.inc -gen-subtarget)
add_public_tablegen_target(VC4CommonTableGen)

add_llvm_target(VC4CodeGen
  VC4AsmPrinter.cpp
  VC4FrameLowering.cpp
  VC4ISelDAGToDAG.cpp
  VC4ISelLowering.cpp
  VC4InstrInfo.cpp
  VC4MachineFunctionInfo.cpp
  VC4MCInstLower.cpp
  VC4RegisterInfo.cpp
  VC4SelectionDAGInfo.cpp
  VC4Subtarget.cpp
  VC4TargetMachine.cpp
  VC4TargetObjectFile.cpp
  )

add_subdirectory(Disassembler)
add_subdirectory(InstPrinter)
add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
