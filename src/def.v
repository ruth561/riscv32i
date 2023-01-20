
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
`define ALU_SGE                                 4'b1110
`define ALU_SGEU                                4'b1111

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
`define OPCODE_JAL                              7'b1101111
`define OPCODE_JALR                             7'b1100111
`define OPCODE_LUI                              7'b0110111
`define OPCODE_AUIPC                            7'b0010111
`define OPCODE_SYSTEM                           7'b1110011

//--------------------------------------------------------------------
// INSTRUCTION FUNCTION
//--------------------------------------------------------------------
`define INST_NOP                                32'h00000013

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
`define INST_BGE_FUNCT                          3'b101
`define INST_BLTU_FUNCT                         3'b110
`define INST_BGEU_FUNCT                         3'b111

`define INST_CSRRW_FUNCT                        3'b001
`define INST_CSRRWI_FUNCT                       3'b101
`define INST_CSRRS_FUNCT                        3'b010
`define INST_CSRRSI_FUNCT                       3'b110
`define INST_CSRRC_FUNCT                        3'b011
`define INST_CSRRCI_FUNCT                       3'b111

//--------------------------------------------------------------------
// CSR Registers
//--------------------------------------------------------------------
// for machine level
`define CSR_MSTATUS_ADDR                        12'h300
`define CSR_MISA_ADDR                           12'h301
`define CSR_MEDELEG_ADDR                        12'h302
`define CSR_MIDELEG_ADDR                        12'h303
`define CSR_MIE_ADDR                            12'h304
`define CSR_MTVEC_ADDR                          12'h305
`define CSR_MCOUNTEREN_ADDR                     12'h306
`define CSR_MSTATUSH_ADDR                       12'h310

`define CSR_MVENDORID_ADDR                      12'hf14
`define CSR_MARCHID_ADDR                        12'hf14
`define CSR_MIMPID_ADDR                         12'hf14
`define CSR_MHARTID_ADDR                        12'hf14
`define CSR_MCONFIGPTR_ADDR                     12'hf14