
//--------------------------------------------------------------------
// Misc
//--------------------------------------------------------------------
`define FALSE                                   1'b0
`define TRUE                                    1'b1


//--------------------------------------------------------------------
// ALU Operations
//--------------------------------------------------------------------
`define ALU_NONE                                4'b0000
`define ALU_SLL                                 4'b0001
`define ALU_SRL                                 4'b0010
`define ALU_SRA                                 4'b0011
`define ALU_ADD                                 4'b0100
`define ALU_SUB                                 4'b0110
`define ALU_AND                                 4'b0111
`define ALU_OR                                  4'b1000
`define ALU_XOR                                 4'b1001
`define ALU_SLTU                                4'b1010
`define ALU_SLT                                 4'b1011

`define ALU_SEQ                                 4'b1100
`define ALU_SNE                                 4'b1101
`define ALU_SGT                                 4'b1110
`define ALU_SGTU                                4'b1111

//--------------------------------------------------------------------
// ALU Src
//--------------------------------------------------------------------
`define ALU_SRC_IMM                             1'b0
`define ALU_SRC_REG                             1'b1 

//--------------------------------------------------------------------
// OPCODE
//--------------------------------------------------------------------
`define OPCODE_LW                               7'b0000011 
`define OPCODE_SW                               7'b0100011
`define OPCODE_OP                               7'b0110011
`define OPCODE_OP_IMM                           7'b0010011
`define OPCODE_BRANCH                           7'b1100011

//--------------------------------------------------------------------
// INSTRUCTION FUNCTION
//--------------------------------------------------------------------
`define INST_ADD_FUNCT                          10'b0000000000
`define INST_SUB_FUNCT                          10'b0100000000
`define INST_AND_FUNCT                          10'b0000000111
`define INST_OR_FUNCT                           10'b0000000110
`define INST_XOR_FUNCT                          10'b0000000100
`define INST_SLL_FUNCT                          10'b0000000001
`define INST_SRL_FUNCT                          10'b0000000101
`define INST_SRA_FUNCT                          10'b0100000101
`define INST_SLT_FUNCT                          10'b0000000010
`define INST_SLTU_FUNCT                         10'b0000000011

`define INST_ADDI_FUNCT                         3'b000
`define INST_SLLI_FUNCT                         3'b001
`define INST_SLTI_FUNCT                         3'b010
`define INST_SLTIU_FUNCT                        3'b011
`define INST_XORI_FUNCT                         3'b100
`define INST_SRXI_FUNCT                         3'b101
`define INST_ORI_FUNCT                          3'b110
`define INST_ANDI_FUNCT                         3'b111

`define INST_BEQ_FUNCT                          3'b000
`define INST_BNE_FUNCT                          3'b001
`define INST_BLT_FUNCT                          3'b100
`define INST_BGT_FUNCT                          3'b101
`define INST_BLTU_FUNCT                         3'b110
`define INST_BGTU_FUNCT                         3'b111