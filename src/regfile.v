module regfile (
    input           clock,
    input           reset,

    input  [ 4:0]   rs1_addr,
    input  [ 4:0]   rs2_addr,
    input  [ 4:0]   rd_addr,
    input  [31:0]   w_val, 

    output [31:0]   rs1_val, 
    output [31:0]   rs2_val,

    // for debug
    output [31:0]   debug_ra, 
    output [31:0]   debug_sp, 
    output [31:0]   debug_t0, 
    output [31:0]   debug_t1, 
    output [31:0]   debug_t2, 
    output [31:0]   debug_a0, 
    output [31:0]   debug_a1
);

    reg [31:0] regs [0:31];

    assign rs1_val = (rs1_addr == 5'b0) ? 32'b0 : regs[rs1_addr];
    assign rs2_val = (rs2_addr == 5'b0) ? 32'b0 : regs[rs2_addr];

    // for debug
    assign debug_ra = regs[1];
    assign debug_sp = regs[2];
    assign debug_t0 = regs[5];
    assign debug_t1 = regs[6];
    assign debug_t2 = regs[7];
    assign debug_a0 = regs[10];
    assign debug_a1 = regs[11];

    // If reset is asserted, all registers are 0-cleared.
    // If it isn't, write back is always done. 
    // If you don't want to write back, you should set 0 in rd_addr.
    always @(posedge clock) begin
        if (reset) begin
            regs[0]  <= 32'b0;
            regs[1]  <= 32'b0;
            regs[2]  <= 32'b0;
            regs[3]  <= 32'b0;
            regs[4]  <= 32'b0;
            regs[5]  <= 32'b0;
            regs[6]  <= 32'b0;
            regs[7]  <= 32'b0;
            regs[8]  <= 32'b0;
            regs[9]  <= 32'b0;
            regs[10] <= 32'b0;
            regs[11] <= 32'b0;
            regs[12] <= 32'b0;
            regs[13] <= 32'b0;
            regs[14] <= 32'b0;
            regs[15] <= 32'b0;
            regs[16] <= 32'b0;
            regs[17] <= 32'b0;
            regs[18] <= 32'b0;
            regs[19] <= 32'b0;
            regs[20] <= 32'b0;
            regs[21] <= 32'b0;
            regs[22] <= 32'b0;
            regs[23] <= 32'b0;
            regs[24] <= 32'b0;
            regs[25] <= 32'b0;
            regs[26] <= 32'b0;
            regs[27] <= 32'b0;
            regs[28] <= 32'b0;
            regs[29] <= 32'b0;
            regs[30] <= 32'b0;
            regs[31] <= 32'b0;
        end else begin
            case (rd_addr) 
                5'd00:      regs[0]     <= 32'b0;
                5'd01:      regs[1]     <= w_val;
                5'd02:      regs[2]     <= w_val;
                5'd03:      regs[3]     <= w_val;
                5'd04:      regs[4]     <= w_val;
                5'd05:      regs[5]     <= w_val;
                5'd06:      regs[6]     <= w_val;
                5'd07:      regs[7]     <= w_val;
                5'd08:      regs[8]     <= w_val;
                5'd09:      regs[9]     <= w_val;
                5'd10:      regs[10]    <= w_val;
                5'd11:      regs[11]    <= w_val;
                5'd12:      regs[12]    <= w_val;
                5'd13:      regs[13]    <= w_val;
                5'd14:      regs[14]    <= w_val;
                5'd15:      regs[15]    <= w_val;
                5'd16:      regs[16]    <= w_val;
                5'd17:      regs[17]    <= w_val;
                5'd18:      regs[18]    <= w_val;
                5'd19:      regs[19]    <= w_val;
                5'd20:      regs[20]    <= w_val;
                5'd21:      regs[21]    <= w_val;
                5'd22:      regs[22]    <= w_val;
                5'd23:      regs[23]    <= w_val;
                5'd24:      regs[24]    <= w_val;
                5'd25:      regs[25]    <= w_val;
                5'd26:      regs[26]    <= w_val;
                5'd27:      regs[27]    <= w_val;
                5'd28:      regs[28]    <= w_val;
                5'd29:      regs[29]    <= w_val;
                5'd30:      regs[30]    <= w_val;
                5'd31:      regs[31]    <= w_val;
            endcase
        end
    end

    // set instructions in imem.
    reg [31:0] i, n;
    initial begin
        // initialize for debug
        for (i = 0; i < 32; i++) begin
            n = i + (i << 8) + (i << 16) + (i << 24);
            regs[i] = n;
        end
    end

endmodule