`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "fwd.v"
`include "csr_regfile.v"
`include "csr_mask.v"

module core #(
    parameter   DMEM_SIZE = 1 << 12, 
    parameter   IMEM_SIZE = 1 << 12
) (
    input  wire     clock,
    input  wire     reset
);

    reg [31:0] pc;

    // for debug
    wire [31:0]  debug_ra;
    wire [31:0]  debug_sp;
    wire [31:0]  debug_gp;
    wire [31:0]  debug_t0;
    wire [31:0]  debug_t1;
    wire [31:0]  debug_t2;
    wire [31:0]  debug_a0;
    wire [31:0]  debug_a1;

    wire [31:0]  debug_mstatus;
    wire [31:0]  debug_mtvec; 
    wire [31:0]  debug_mie; 
    wire [31:0]  debug_mip; 
    wire [31:0]  debug_mepc; 
    wire [31:0]  debug_mcause;

    reg  [31:0]  imem [0:(IMEM_SIZE >> 2) - 1]; // instruction memory
    reg  [ 7:0]  dmem [0:DMEM_SIZE - 1]; // data memory

    // ====================   IF   ====================
    // IF/ID PIPELINE REGS
    reg  [31:0]  if_id_pc;
    reg  [31:0]  if_id_instr;

    // ====================   ID   ====================
    // wires from IF/ID
    wire [ 6:0]  id_opcode;
    wire [ 4:0]  id_rs1_addr;
    wire [ 4:0]  id_rs2_addr;
    wire [ 4:0]  id_rd_addr;
    wire [11:0]  id_csr_addr;
    wire [ 2:0]  id_csr_funct;

    // wires into ID/EX
    wire [31:0]  id_rs1_val;
    wire [31:0]  id_rs2_val;
    wire [31:0]  id_csr_val;
    wire         id_jal;
    wire         id_jalr;
    wire         id_branch;
    wire         id_lui;
    wire         id_auipc;
    wire         id_csr;
    wire         id_mem_read;
    wire         id_mem_write;
    wire [ 3:0]  id_alu_op;
    wire         id_alu_src;
    wire         id_reg_write;
    wire [31:0]  id_imm;
    
    // ID/EX PIPELINE REGS
    reg  [31:0]  id_ex_pc;
    reg  [ 4:0]  id_ex_rs1_addr;
    reg  [ 4:0]  id_ex_rs2_addr;
    reg  [31:0]  id_ex_rs1_val;
    reg  [31:0]  id_ex_rs2_val;
    reg  [ 4:0]  id_ex_rd_addr;
    reg  [11:0]  id_ex_csr_addr;
    reg  [31:0]  id_ex_csr_val;
    reg  [ 2:0]  id_ex_csr_funct;
    reg          id_ex_jal;
    reg          id_ex_jalr;
    reg          id_ex_branch;
    reg          id_ex_lui;
    reg          id_ex_auipc;
    reg          id_ex_csr;
    reg          id_ex_mem_read;
    reg          id_ex_mem_write;
    reg  [ 3:0]  id_ex_alu_op;
    reg          id_ex_alu_src;
    reg          id_ex_reg_write;
    reg  [31:0]  id_ex_imm;

    // ====================   EX   ====================
    // wires into EX/MEM
    wire [31:0]  ex_rs1_val; // forwarded value
    wire [31:0]  ex_rs2_val; // forwarded value
    wire [31:0]  ex_alu_result;
    wire [31:0]  ex_csr_result;

    // EX/MEM PIPELINE REGS
    reg  [31:0]  ex_mem_pc;
    reg  [31:0]  ex_mem_branch_addr;
    reg  [31:0]  ex_mem_result;
    reg  [31:0]  ex_mem_write_data;
    reg          ex_mem_branch;
    reg          ex_mem_mem_read;
    reg          ex_mem_reg_write;
    reg          ex_mem_mem_write;
    reg  [ 4:0]  ex_mem_rd_addr;
    reg          ex_mem_jal;
    reg          ex_mem_jalr;

    // ====================   MEM  ====================
    // MEM/WB PIPELINE REGS
    reg  [ 4:0]  mem_wb_rd_addr;
    reg  [31:0]  mem_wb_data;

    // control wire
    wire         stall;
    wire         branch_misprediction;     // branch if true

    // wires
    wire [ 4:0]  rd_addr;
    wire [31:0]  rd_value;

    //-------------------------------------------------
    // STAGE 1 (IF)
    //-------------------------------------------------
    always @(posedge clock) begin
        if (branch_misprediction) begin
            if_id_pc    <= pc;
            if_id_instr <= `INST_NOP;
        end else if (stall) begin
            if_id_pc    <= if_id_pc;
            if_id_instr <= if_id_instr;
        end else if (id_jal) begin // when id stage processing jal instruction
            if_id_pc    <= 32'b0;
            if_id_instr <= `INST_NOP;
        end else begin
            if_id_pc    <= pc;
            if_id_instr <= imem[pc >> 2];
        end

        if (branch_misprediction)   pc <= ex_mem_branch_addr;
        else if (stall)             pc <= pc;
        else if (id_jal)            pc <= if_id_pc + id_imm;
        else                        pc <= pc + 4;
    end

    //-------------------------------------------------
    // STAGE 2 (ID)
    //-------------------------------------------------
    assign id_opcode    = if_id_instr[ 6: 0];
    assign id_rs1_addr  = if_id_instr[19:15];
    assign id_rs2_addr  = if_id_instr[24:20];
    assign id_rd_addr   = if_id_instr[11: 7];
    assign id_csr_addr  = if_id_instr[31:20];
    assign id_csr_funct = if_id_instr[14:12];

    decode _decode (
        .clock      (clock),
        .reset      (reset),
        .instr_raw  (if_id_instr),

        .jal        (id_jal),
        .jalr       (id_jalr),
        .branch     (id_branch),
        .lui        (id_lui),
        .auipc      (id_auipc),
        .csr        (id_csr),
        .mem_read   (id_mem_read),
        .mem_write  (id_mem_write),
        .alu_op     (id_alu_op),
        .alu_src    (id_alu_src),
        .reg_write  (id_reg_write),
        .imm        (id_imm)
    );
    
    regfile _regfile (
        .clock      (clock), 
        .reset      (reset),
        .rs1_addr   (id_rs1_addr), 
        .rs2_addr   (id_rs2_addr),
        .rd_addr    (rd_addr),  // from WB stage
        .w_val      (rd_value), // from WB stage

        .rs1_val    (id_rs1_val),
        .rs2_val    (id_rs2_val),

        .debug_ra   (debug_ra),
        .debug_sp   (debug_sp),
        .debug_gp   (debug_gp),
        .debug_t0   (debug_t0),
        .debug_t1   (debug_t1),
        .debug_t2   (debug_t2),
        .debug_a0   (debug_a0),
        .debug_a1   (debug_a1)
    );

    csr_regfile _csr_regfile (
        .clock      (clock),
        .reset      (reset),

        .csr_r_addr (id_csr_addr),
        .csr_w_addr (id_ex_csr_addr),
        .csr_w_val  (ex_csr_result),
        .w_enable   (id_ex_csr),

        .csr_r_val  (id_csr_val), 

        .debug_mstatus  (debug_mstatus), 
        .debug_mtvec    (debug_mtvec), 
        .debug_mie      (debug_mie), 
        .debug_mip      (debug_mip), 
        .debug_mepc     (debug_mepc), 
        .debug_mcause   (debug_mcause)
    );

    always @(posedge clock) begin
        id_ex_pc        <= if_id_pc;
        id_ex_rs1_addr  <= id_rs1_addr;
        id_ex_rs2_addr  <= id_rs2_addr;
        id_ex_rs1_val   <= id_rs1_val;
        id_ex_rs2_val   <= id_rs2_val;
        id_ex_rd_addr   <= id_rd_addr;
        id_ex_csr_addr  <= id_csr_addr;
        id_ex_csr_val   <= id_csr_val;
        id_ex_csr_funct <= id_csr_funct;
        id_ex_imm       <= id_imm;

        // for control bit
        if (branch_misprediction || stall) begin
            id_ex_jal       <= `FALSE;
            id_ex_jalr      <= `FALSE;
            id_ex_branch    <= `FALSE;
            id_ex_lui       <= `FALSE;
            id_ex_auipc     <= `FALSE;
            id_ex_csr       <= `FALSE;
            id_ex_mem_read  <= `FALSE;
            id_ex_mem_write <= `FALSE;
            id_ex_alu_op    <= `ALU_NONE;
            id_ex_alu_src   <= `FALSE;
            id_ex_reg_write <= `FALSE;
        end else begin
            id_ex_jal       <= id_jal;
            id_ex_jalr      <= id_jalr;
            id_ex_branch    <= id_branch;
            id_ex_lui       <= id_lui;
            id_ex_auipc     <= id_auipc;
            id_ex_csr       <= id_csr;
            id_ex_mem_read  <= id_mem_read;
            id_ex_mem_write <= id_mem_write;
            id_ex_alu_op    <= id_alu_op;
            id_ex_alu_src   <= id_alu_src;
            id_ex_reg_write <= id_reg_write;
        end
    end

    //-------------------------------------------------
    // STAGE 3 (EX)
    //-------------------------------------------------
    fwd _fwd (
        .ex_rs1_addr    (id_ex_rs1_addr),
        .ex_rs2_addr    (id_ex_rs2_addr),
        .ex_rs1_val     (id_ex_rs1_val),
        .ex_rs2_val     (id_ex_rs2_val),
        .mem_reg_write  (ex_mem_reg_write), 
        .mem_rd_addr    (ex_mem_rd_addr),
        .mem_rd_val     (ex_mem_result),
        .wb_rd_addr     (mem_wb_rd_addr),
        .wb_rd_val      (mem_wb_data),

        .rs1            (ex_rs1_val),
        .rs2            (ex_rs2_val)
    );

    alu _alu (
        .alu_op     (id_ex_alu_op),
        .src1       (id_ex_lui ? 32'b0 : (id_ex_auipc ? id_ex_pc : ex_rs1_val)),
        .src2       (id_ex_alu_src ? id_ex_imm : ex_rs2_val),

        .result     (ex_alu_result)
    );

    csr_mask _csr_mask (
        .csr_funct  (id_ex_csr_funct),
        .csr_val    (id_ex_csr_val),
        .rs1_val    (ex_rs1_val), // forwarded val
        .imm        (id_ex_imm),

        .result     (ex_csr_result)
    );

    always @(posedge clock) begin
        ex_mem_pc           <= id_ex_pc;
        ex_mem_branch_addr  <= id_ex_jalr ? ex_alu_result : id_ex_pc + id_ex_imm;
        ex_mem_result       <= id_ex_csr ? id_ex_csr_val : ex_alu_result;
        ex_mem_write_data   <= ex_rs2_val;
        ex_mem_rd_addr      <= id_ex_rd_addr;

        // for control bit
        if (branch_misprediction) begin
            ex_mem_jal          <= `FALSE;
            ex_mem_jalr         <= `FALSE;
            ex_mem_branch       <= `FALSE;
            ex_mem_mem_read     <= `FALSE;
            ex_mem_mem_write    <= `FALSE; 
            ex_mem_reg_write    <= `FALSE;
        end else begin
            ex_mem_jal          <= id_ex_jal;
            ex_mem_jalr         <= id_ex_jalr;
            ex_mem_branch       <= id_ex_branch;
            ex_mem_mem_read     <= id_ex_mem_read;
            ex_mem_mem_write    <= id_ex_mem_write; 
            ex_mem_reg_write    <= id_ex_reg_write;
        end
    end

    //-------------------------------------------------
    // STAGE 4 (MEM)
    //-------------------------------------------------
    always @(posedge clock) begin // write to memory
        if (ex_mem_mem_write) begin // WORD only
            dmem[ex_mem_result]     <= ex_mem_write_data[ 7: 0];
            dmem[ex_mem_result + 1] <= ex_mem_write_data[15: 8];
            dmem[ex_mem_result + 2] <= ex_mem_write_data[23:16];
            dmem[ex_mem_result + 3] <= ex_mem_write_data[31:24];
        end
    end

    always @(posedge clock) begin
        if (ex_mem_reg_write) begin
            mem_wb_rd_addr  <= ex_mem_rd_addr;
            if (ex_mem_mem_read) begin
                mem_wb_data[ 7: 0]  <= dmem[ex_mem_result];
                mem_wb_data[15: 8]  <= dmem[ex_mem_result + 1];
                mem_wb_data[23:16]  <= dmem[ex_mem_result + 2];
                mem_wb_data[31:24]  <= dmem[ex_mem_result + 3];
            end else if (ex_mem_jal || ex_mem_jalr) begin
                mem_wb_data         <= ex_mem_pc + 4;
            end else begin
                mem_wb_data         <= ex_mem_result;
            end
        end else begin // write to x0, meaning not writing.
            mem_wb_rd_addr  <= 5'b0;
            mem_wb_data     <= 32'b0;
        end
    end

    assign branch_misprediction = (ex_mem_branch && ex_mem_result) || ex_mem_jalr;
        
    //-------------------------------------------------
    // STAGE 5 (WB)
    //-------------------------------------------------
    assign rd_addr  = mem_wb_rd_addr;
    assign rd_value = mem_wb_data;

    //-------------------------------------------------
    // Control 
    //-------------------------------------------------
    assign stall = id_ex_mem_read && (id_rs1_addr == id_ex_rd_addr || id_rs2_addr == id_ex_rd_addr);

    //-------------------------------------------------
    // FOR DEBUG
    //-------------------------------------------------
    reg [7:0] timer;
    reg [31:0] i, j;
    always @(posedge clock) begin // debug
        // timing is shifted from PC increment
        // $display("----- %d -----", timer);
        $display("pc        : %x --> %b (%x)  | gp = %d", 
            pc, imem[pc >> 2], imem[pc >> 2], debug_gp);
        $display("ra        : %x", debug_ra);
        $display("sp        : %x", debug_sp);
        $display("gp        : %x", debug_gp);
        $display("t0        : %x", debug_t0);
        $display("t1        : %x", debug_t1);
        $display("t2        : %x", debug_t2);
        $display("a0        : %x", debug_a0);
        $display("a1        : %x", debug_a1);
        $display("mstatus   : %x", debug_mstatus);
        $display("mtvec     : %x", debug_mtvec);
        $display("mie       : %x", debug_mie);
        $display("mip       : %x", debug_mip);
        $display("mepc      : %x", debug_mepc);
        $display("mcause    : %x", debug_mcause);
        // $display("");
        // $display("[data memory dump]");
        // for (i = (DMEM_SIZE >> 3) - 4; i < DMEM_SIZE >> 3; i++) begin
        //     $display("%x: %x %x %x %x %x %x %x %x", (i << 3), 
        //         dmem[(i << 3)], dmem[(i << 3) + 1], dmem[(i << 3) + 2], dmem[(i << 3) + 3], 
        //         dmem[(i << 3) + 4], dmem[(i << 3) + 5], dmem[(i << 3) + 6], dmem[(i << 3) + 7]);
        // end
        timer = timer + 1;
    end

    // for test bench
    initial begin
        pc = 32'h0;
        timer = 0;

        // TODO データメモリ用の読み込みデータも作る
        // $readmemh("build/testd.txt", dmem);
        for (i = 0; i < DMEM_SIZE; i++) dmem[i] <= 0;
        $readmemh("build/testi.txt", imem);
    end

endmodule