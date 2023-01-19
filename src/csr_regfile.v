`include "def.v"

module csr_regfile (
    input           clock,
    input           reset,

    input  wire [11:0]  csr_r_addr,
    input  wire [11:0]  csr_w_addr,
    input  wire [31:0]  csr_w_val,
    input  wire         w_enable,

    output wire [31:0]  csr_r_val,

    output wire [31:0]  debug_mstatus, 
    output wire [31:0]  debug_misa 
);
    reg [31:0] csrs [0:4095];

    assign csr_r_val = w_enable && csr_w_addr == csr_r_addr ? csr_w_val : csrs[csr_r_addr];
    
    // for debug
    assign debug_mstatus = csrs[`CSR_MSTATUS_ADDR];
    assign debug_misa    = csrs[`CSR_MISA_ADDR];

    always @(posedge clock) begin
        if (w_enable) csrs[csr_w_addr]  <= csr_w_val;
    end

    // set instructions in imem.
    reg [31:0] i;
    initial begin
        // initialize for debug
        for (i = 0; i < 4095; i++) csrs[i] <= i;
        csrs[`CSR_MSTATUS_ADDR] <= 32'hdeadbeef;
        csrs[`CSR_MISA_ADDR]    <= 32'hcafebabe;
    end

endmodule
