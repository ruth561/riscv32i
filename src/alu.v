`include "def.v"

module alu (
    input  wire [ 3:0]  alu_op,
    input  wire [31:0]  src1,
    input  wire [31:0]  src2,

    output wire         zero,
    output wire [31:0]  result
);

    function [31:0] alu_core;
        input [ 3:0]  alu_op;
        input [31:0]  src1;
        input [31:0]  src2;

        case (alu_op) 
            `ALU_ADD:    alu_core = src1 + src2;
            `ALU_SUB:    alu_core = src1 - src2;
            `ALU_AND:    alu_core = src1 & src2;
            `ALU_OR:     alu_core = src1 | src2;
            `ALU_XOR:    alu_core = src1 ^ src2;
            `ALU_SLL:    alu_core = src1 << src2[4:0];
            `ALU_SRL:    alu_core = src1 >> src2[4:0];
            `ALU_SRA:    alu_core = $signed(src1) >> src2[4:0];
            `ALU_SLTU:   alu_core = src1 < src2;
            `ALU_SLT:    alu_core = $signed(src1) + $signed(src2);     
            default:     alu_core = 32'b0;       
        endcase
    endfunction

    assign  result = alu_core(alu_op, src1, src2);
    assign  zero = result == 32'b0;

endmodule