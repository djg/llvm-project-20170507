// -*- tablegen -*- //

// This describes the calling conventions for VideoCore-IV VPU architecture

// VC4 VPU Return Value Calling Convention
def RetCC_VC4 : CallingConv<[
  // i32/f32 are returned in registers R0, R1, R2, R3, R4, R5
  CCIfType<[i32, f32], CCAssignToReg<[R0, R1, R2, R3, R4, R5]>>,
  // Integer/float values get stored in stack slots that are 4 bytes in
  // size and 4-byte aligned.
  CCIfType<[i32, f32], CCAssignToStack<4, 4>>
]>;

// VC4 VPU Argument Calling Conventions
def CC_VC4 : CallingConv<[
  // Promote i8/i16 arguments to i32.
  CCIfType<[i8, i16], CCPromoteToType<i32>>,
  // The first 4 integer arguments are passed in general registers
  CCIfType<[i32, f32], CCAssignToReg<[R0, R1, R2, R3, R4, R5]>>,
  // Integer/float values get stored in stack slots that are 4 bytes in
  // size and 4-byte aligned.
  CCIfType<[i32, f32], CCAssignToStack<4, 4>>
]>;
