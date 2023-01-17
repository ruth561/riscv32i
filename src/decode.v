`include "def.v"

module decode (
    input  wire         clock,
    input  wire         reset,
    input  wire [31:0]  instr_raw,

    output wire         jal,
    output wire         branch,
    output wire         mem_read,
    output wire         mem_write,
    output wire [ 3:0]  alu_op,
    output wire         alu_src,
    output wire         reg_write,
    output wire [31:0]  imm
);
    // calcurates immideates value
    function [31:0] imm_f;
        input [31:0] instr_raw;
        case (instr_raw[6:0])
            `OPCODE_LW:     imm_f = {{20{instr_raw[31]}}, instr_raw[31:20]};
            `OPCODE_SW:     imm_f = {{20{instr_raw[31]}}, instr_raw[31:25], instr_raw[11:7]};
            `OPCODE_OP:     imm_f = 32'b0;
            `OPCODE_OP_IMM: imm_f = {{20{instr_raw[31]}}, instr_raw[31:20]};
            `OPCODE_BRANCH: imm_f = {{20{instr_raw[31]}}, instr_raw[7], instr_raw[30:25], instr_raw[11:8], {1'b0}}; // type B
            `OPCODE_JAL:    imm_f = {{12{instr_raw[31]}}, instr_raw[19:12], instr_raw[20], instr_raw[30:21], {1'b0}}; 
            default:        imm_f = 32'b0;
        endcase
    endfunction

    function [3:0] alu_op_f;
        input [31:0] instr_raw;

        if (instr_raw[6:0] == `OPCODE_LW)       
            alu_op_f      = `ALU_ADD;
        else if (instr_raw[6:0] == `OPCODE_SW)  
            alu_op_f      = `ALU_ADD;
        else if (instr_raw[6:0] == `OPCODE_OP) begin
            case ({instr_raw[31:25], instr_raw[14:12]})
                `INST_ADD_FUNCT:     alu_op_f = `ALU_ADD;
                `INST_SUB_FUNCT:     alu_op_f = `ALU_SUB;
                `INST_AND_FUNCT:     alu_op_f = `ALU_AND;
                `INST_OR_FUNCT:      alu_op_f = `ALU_OR;
                `INST_XOR_FUNCT:     alu_op_f = `ALU_XOR;
                `INST_SLL_FUNCT:     alu_op_f = `ALU_SLL;
                `INST_SRL_FUNCT:     alu_op_f = `ALU_SRL;
                `INST_SRA_FUNCT:     alu_op_f = `ALU_SRA;
                `INST_SLT_FUNCT:     alu_op_f = `ALU_SLT;
                `INST_SLTU_FUNCT:    alu_op_f = `ALU_SLTU;
                default:             alu_op_f = `ALU_NONE;
            endcase
        end else if (instr_raw[6:0] == `OPCODE_OP_IMM) begin
            case (instr_raw[14:12])
                `INST_ADDI_FUNCT:    alu_op_f = `ALU_ADD;
                `INST_ANDI_FUNCT:    alu_op_f = `ALU_AND;
                `INST_ORI_FUNCT:     alu_op_f = `ALU_OR;
                `INST_XORI_FUNCT:    alu_op_f = `ALU_XOR;
                `INST_SLLI_FUNCT:    alu_op_f = `ALU_SLL;
                `INST_SRXI_FUNCT:    alu_op_f = instr_raw[30] ? `ALU_SRA : `ALU_SRL;
                `INST_SLTI_FUNCT:    alu_op_f = `ALU_SLT;
                `INST_SLTIU_FUNCT:   alu_op_f = `ALU_SLTU;
                default:             alu_op_f = `ALU_NONE;
            endcase 
        end else if (instr_raw[6:0] == `OPCODE_BRANCH) begin
            case (instr_raw[14:12])
                `INST_BEQ_FUNCT:     alu_op_f = `ALU_SEQ;   // Set EQual 
                `INST_BNE_FUNCT:     alu_op_f = `ALU_SNE;   // Set Not Equal
                `INST_BLT_FUNCT:     alu_op_f = `ALU_SLT;   
                `INST_BGE_FUNCT:     alu_op_f = `ALU_SGE;   // Set Greater Than (signed)
                `INST_BLTU_FUNCT:    alu_op_f = `ALU_SLTU;
                `INST_BGEU_FUNCT:    alu_op_f = `ALU_SGEU;  // Set Greater Than unsigned
                default:             alu_op_f = `ALU_NONE;
            endcase 
        end else if (instr_raw[6:0] == `OPCODE_JAL) begin // calcurated in other ALU
            alu_op_f      = `ALU_NONE;
        end else
            alu_op_f      = `ALU_NONE;
    endfunction


    assign jal          = (instr_raw[6:0] == `OPCODE_JAL);
    assign branch       = (instr_raw[6:0] == `OPCODE_BRANCH);
    assign mem_read     = (instr_raw[6:0] == `OPCODE_LW);
    assign mem_write    = (instr_raw[6:0] == `OPCODE_SW);
    assign alu_op       = alu_op_f(instr_raw);
    assign alu_src      = (instr_raw[6:0] == `OPCODE_SW) ||
                          (instr_raw[6:0] == `OPCODE_LW) ||
                          (instr_raw[6:0] == `OPCODE_OP_IMM);
    assign reg_write    = (instr_raw[6:0] == `OPCODE_LW) ||
                          (instr_raw[6:0] == `OPCODE_OP) ||
                          (instr_raw[6:0] == `OPCODE_OP_IMM) ||
                          (instr_raw[6:0] == `OPCODE_JAL);
    assign imm          = imm_f(instr_raw);

endmodule
