module fwd (
    // from ID/EX pipeline registers
    input  wire [ 4:0]  ex_rs1_addr,
    input  wire [ 4:0]  ex_rs2_addr,
    input  wire [31:0]  ex_rs1_val,
    input  wire [31:0]  ex_rs2_val,

    // from EX/MEM pipeline registers
    input               mem_reg_write,
    input  wire [ 4:0]  mem_rd_addr,
    input  wire [31:0]  mem_rd_val,

    // from EX/MEM pipeline registers
    input  wire [ 4:0]  wb_rd_addr,
    input  wire [31:0]  wb_rd_val,

    // output
    output wire [31:0]  rs1,
    output wire [31:0]  rs2
);

    function [31:0] forward;
        input [ 4:0]  ex_rs_addr;
        input [31:0]  ex_rs_val;
        input         mem_reg_write;
        input [ 4:0]  mem_rd_addr;
        input [31:0]  mem_rd_val;
        input [ 4:0]  wb_rd_addr;
        input [31:0]  wb_rd_val;

        // not load instruction
        if (mem_reg_write && mem_rd_addr == ex_rs_addr) 
            forward = mem_rd_val;
        else if (wb_rd_addr == ex_rs_addr)  
            forward = wb_rd_val;
        else
            forward = ex_rs_val;

    endfunction

    assign rs1 = forward (
        ex_rs1_addr,
        ex_rs1_val,
        mem_reg_write, 
        mem_rd_addr,
        mem_rd_val,
        wb_rd_addr,
        wb_rd_val
    );

    assign rs2 = forward (
        ex_rs2_addr,
        ex_rs2_val,
        mem_reg_write, 
        mem_rd_addr,
        mem_rd_val,
        wb_rd_addr,
        wb_rd_val
    );

endmodule