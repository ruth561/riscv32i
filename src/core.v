`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "fwd.v"

module core (
    input  wire     clock,
    input  wire     reset
);

    reg [31:0] pc;
    // for debug
    output [31:0]   debug_ra;
    output [31:0]   debug_sp;
    output [31:0]   debug_t0;
    output [31:0]   debug_t1;
    output [31:0]   debug_t2;
    output [31:0]   debug_a0;
    output [31:0]   debug_a1;

    reg [31:0] imem [0:15]; // instruction memory
    /** TODO: データは１バイトずつにしたほうがいい */
    reg [7:0] dmem [0:63]; // data memory

    // pipeline registers between IF and ID 
    reg [31:0]  if_id_pc;
    reg [31:0]  if_id_instr;

    // pipeline registers between ID and EX 
    reg [31:0]  id_ex_pc;
    reg [ 4:0]  id_ex_rs1_addr;
    reg [ 4:0]  id_ex_rs2_addr;
    reg [31:0]  id_ex_rs1_val;
    reg [31:0]  id_ex_rs2_val;
    reg [ 4:0]  id_ex_rd_addr;
    reg         id_ex_branch;
    reg         id_ex_mem_read;
    reg         id_ex_mem_write;
    reg [ 3:0]  id_ex_alu_op;
    reg         id_ex_alu_src;
    reg         id_ex_reg_write;
    reg [31:0]  id_ex_imm;

    // wires from decode stage
    wire [31:0] id_rs1_val;
    wire [31:0] id_rs2_val;
    wire        id_branch;
    wire        id_mem_read;
    wire        id_mem_write;
    wire [ 3:0] id_alu_op;
    wire        id_alu_src;
    wire        id_reg_write;
    wire [31:0] id_imm;

    // pipeline registers between EX and MEM
    reg [31:0]  ex_mem_branch_addr;
    reg [31:0]  ex_mem_result;
    reg [31:0]  ex_mem_write_data;
    reg         ex_mem_branch;
    reg         ex_mem_mem_read;
    reg         ex_mem_reg_write;
    reg         ex_mem_mem_write;
    reg [ 4:0]  ex_mem_rd_addr;

    // wire from execute stage
    wire [31:0] ex_rs1_val; // forwarded value
    wire [31:0] ex_rs2_val; // forwarded value
    wire [31:0] ex_result;

    // pipeline registers between MEM and WB
    reg [ 4:0]  mem_wb_rd_addr;
    reg [31:0]  mem_wb_data;

    // wire from memory stage
    wire        branch_misprediction;     // branch if true

    // wires
    wire [ 4:0] rd_addr;
    wire [31:0] rd_value;

    //-------------------------------------------------
    // STAGE 1 (IF)
    //-------------------------------------------------
    always @(posedge clock) begin
        if_id_pc    <= pc;
        if (branch_misprediction) if_id_instr <= `INST_NOP;
        else                      if_id_instr <= imem[pc >> 2];

        if (branch_misprediction) pc <= ex_mem_branch_addr;
        else                      pc <= pc + 4;
    end

    //-------------------------------------------------
    // STAGE 2 (ID)
    //-------------------------------------------------
    decode d_stage (
        .clock      (clock),
        .reset      (reset),
        .instr_raw  (if_id_instr),

        .branch     (id_branch),
        .mem_read   (id_mem_read),
        .mem_write  (id_mem_write),
        .alu_op     (id_alu_op),
        .alu_src    (id_alu_src),
        .reg_write  (id_reg_write),
        .imm        (id_imm)
    );
    
    regfile regfile (
        .clock      (clock), 
        .reset      (reset),
        .rs1_addr   (if_id_instr[19:15]), 
        .rs2_addr   (if_id_instr[24:20]),
        .rd_addr    (rd_addr),  // from WB stage
        .w_val      (rd_value), // from WB stage

        .rs1_val    (id_rs1_val),
        .rs2_val    (id_rs2_val),

        .debug_ra   (debug_ra),
        .debug_sp   (debug_sp),
        .debug_t0   (debug_t0),
        .debug_t1   (debug_t1),
        .debug_t2   (debug_t2),
        .debug_a0   (debug_a0),
        .debug_a1   (debug_a1)
    );

    always @(posedge clock) begin
        id_ex_pc        <= if_id_pc;
        id_ex_rs1_addr  <= if_id_instr[19:15];
        id_ex_rs2_addr  <= if_id_instr[24:20];
        id_ex_rs1_val   <= id_rs1_val;
        id_ex_rs2_val   <= id_rs2_val;
        id_ex_rd_addr   <= if_id_instr[11:7];
        id_ex_imm       <= id_imm;

        // for control bit
        if (branch_misprediction) begin
            id_ex_branch    <= `FALSE;
            id_ex_mem_read  <= `FALSE;
            id_ex_mem_write <= `FALSE;
            id_ex_alu_op    <= `ALU_NONE;
            id_ex_alu_src   <= `FALSE;
            id_ex_reg_write <= `FALSE;
        end else begin
            id_ex_branch    <= id_branch;
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
        .mem_rd_addr    (ex_mem_rd_addr),
        .mem_rd_val     (ex_mem_result),
        .wb_rd_addr     (mem_wb_rd_addr),
        .wb_rd_val      (mem_wb_data),

        .rs1            (ex_rs1_val),
        .rs2            (ex_rs2_val)
    );

    alu alu (
        .alu_op     (id_ex_alu_op),
        .src1       (ex_rs1_val),
        .src2       (id_ex_alu_src ? id_ex_imm : ex_rs2_val),

        .result     (ex_result)
    );

    always @(posedge clock) begin
        ex_mem_branch_addr  <= id_ex_pc + id_ex_imm;
        ex_mem_result       <= ex_result;
        ex_mem_write_data   <= ex_rs2_val;
        ex_mem_rd_addr      <= id_ex_rd_addr;

        // for control bit
        if (branch_misprediction) begin
            ex_mem_branch       <= `FALSE;
            ex_mem_mem_read     <= `FALSE;
            ex_mem_mem_write    <= `FALSE; 
            ex_mem_reg_write    <= `FALSE;
        end else begin
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
            end else begin
                mem_wb_data         <= ex_mem_result;
            end
        end else begin // write to x0, meaning not writing.
            mem_wb_rd_addr  <= 5'b0;
            mem_wb_data     <= 32'b0;
        end
    end

    assign branch_misprediction = ex_mem_branch && ex_mem_result;
        
    //-------------------------------------------------
    // STAGE 5 (WB)
    //-------------------------------------------------
    assign rd_addr  = mem_wb_rd_addr;
    assign rd_value = mem_wb_data;


    //-------------------------------------------------
    // FOR DEBUG
    //-------------------------------------------------
    reg [7:0] timer;
    always @(posedge clock) begin // debug
        // timing is shifted from PC increment
        $display("----- %d -----", timer);
        $display("pc  : %x --> %b (%x)", pc, imem[pc >> 2], imem[pc >> 2]);
        $display("ra  : %x", debug_ra);
        $display("sp  : %x", debug_sp);
        $display("t0  : %x", debug_t0);
        $display("t1  : %x", debug_t1);
        $display("t2  : %x", debug_t2);
        $display("a0  : %x", debug_a0);
        $display("a1  : %x", debug_a1);
        $display("");
        $display("[data memory dump]");
        $display("0000: %x %x %x %x %x %x %x %x", dmem[0], dmem[1], dmem[2], dmem[3], dmem[4], dmem[5], dmem[6], dmem[7]);
        $display("0008: %x %x %x %x %x %x %x %x", dmem[8], dmem[9], dmem[10], dmem[11], dmem[12], dmem[13], dmem[14], dmem[15]);
        $display("0010: %x %x %x %x %x %x %x %x", dmem[16], dmem[17], dmem[18], dmem[19], dmem[20], dmem[21], dmem[22], dmem[23]);
        $display("0018: %x %x %x %x %x %x %x %x", dmem[24], dmem[25], dmem[26], dmem[27], dmem[28], dmem[29], dmem[30], dmem[31]);
        timer = timer + 1;
    end

    // for test bench
    initial begin
        pc = 32'h0;
        timer = 0;

        // TODO データメモリ用の読み込みデータも作る
        $readmemh("build/testd.txt", dmem);
        $readmemh("build/testi.txt", imem);
    end

endmodule