`include "decode.v"
`include "regfile.v"
`include "alu.v"

module core (
    input  wire     clock,
    input  wire     reset
);

    reg [31:0] pc;
    wire [31:0] regs [0:31];

    reg [31:0] imem [0:15]; // instruction memory
    /** TODO: データは１バイトずつにしたほうがいい */
    reg [7:0] dmem [0:63]; // data memory

    // pipeline registers between IF and ID 
    reg [31:0]  if_id_instr;

    // pipeline registers between ID and EX 
    reg [31:0]  id_ex_rs1;
    reg [31:0]  id_ex_rs2;
    reg [ 4:0]  id_ex_rd;
    reg         id_ex_branch;
    reg         id_ex_mem_read;
    reg         id_ex_mem_write;
    reg [ 3:0]  id_ex_alu_op;
    reg         id_ex_alu_src;
    reg         id_ex_reg_write;
    reg [31:0]  id_ex_imm;

    wire [31:0] id_rs1;
    wire [31:0] id_rs2;
    wire        id_branch;
    wire        id_mem_read;
    wire        id_mem_write;
    wire [ 3:0] id_alu_op;
    wire        id_alu_src;
    wire        id_reg_write;
    wire [31:0] id_imm;

    // pipeline registers between EX and MEM
    reg         ex_mem_zero; 
    reg [31:0]  ex_mem_result;
    reg         ex_mem_branch;
    reg         ex_mem_mem_read;
    reg         ex_mem_reg_write;
    reg         ex_mem_mem_write;

    wire        ex_zero;
    wire [31:0] ex_result;

    // pipeline registers between MEM and WB
    reg [31:0]  mem_wb_ir;
    reg [31:0]  mem_wb_data;

    //-------------------------------------------------
    // STAGE 1 (IF)
    //-------------------------------------------------
    always @(posedge clock) begin
        pc          <= pc + 4;
        if_id_instr <= imem[pc >> 2];
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
    
    reg [ 4:0] zero5  = 0;
    reg [31:0] zero32 = 0;
    regfile regfile (
        .clock      (clock), 
        .reset      (reset),
        .rs1_addr   (if_id_instr[19:15]), 
        .rs2_addr   (if_id_instr[24:20]),
        .rd_addr    (zero5),
        .w_val      (zero32),

        .rs1_val    (id_rs1),
        .rs2_val    (id_rs2)
    );

    always @(posedge clock) begin
        id_ex_rs1       <= id_rs1;
        id_ex_rs2       <= id_rs2;
        id_ex_branch    <= id_branch;
        id_ex_mem_read  <= id_mem_read;
        id_ex_mem_write <= id_mem_write;
        id_ex_alu_op    <= id_alu_op;
        id_ex_alu_src   <= id_alu_src;
        id_ex_reg_write <= id_reg_write;
        id_ex_imm       <= id_imm;
    end

    //-------------------------------------------------
    // STAGE 3 (EX)
    //-------------------------------------------------
    alu alu (
        .alu_op     (id_ex_alu_op),
        .src1       (id_ex_rs1),
        .src2       (id_ex_alu_src ? id_ex_imm : id_ex_rs2),

        .zero       (ex_zero),
        .result     (ex_result)
    );

    always @(posedge clock) begin
        ex_mem_zero         <= ex_zero;
        ex_mem_result       <= ex_result;
        ex_mem_branch       <= id_ex_branch;
        ex_mem_mem_read     <= id_ex_mem_read;
        ex_mem_mem_write    <= id_ex_mem_write; 
        ex_mem_reg_write    <= id_ex_reg_write; 
    end

    //-------------------------------------------------
    // STAGE 4 (MEM)
    //-------------------------------------------------
    /* 
    ここは改変するつもり
    always @(posedge clock) begin
        mem_wb_ir   <= ex_mem_ir;
        case (ex_mem_ir[6:0])
            LW: mem_wb_data <= dmem[ex_mem_value >> 2]; // data from data memory
            SW: dmem[ex_mem_value >> 2]  <= ex_mem_rs2; // write rs2 in dmem.
            OP: mem_wb_data <= ex_mem_value;
            OP_IMM: mem_wb_data <= ex_mem_value;
        endcase
    end */
        
    //-------------------------------------------------
    // STAGE 5 (WB)
    //-------------------------------------------------

    always @(posedge clock) begin // debug
        // timing is shifted from PC increment
        $display("-----");
        $display("[data memory dump]");
        $display("0000: %x %x %x %x %x %x %x %x", 
            dmem[0], dmem[1], dmem[2], dmem[3], dmem[4], dmem[5], dmem[6], dmem[7]);
        $display("0008: %x %x %x %x %x %x %x %x", 
            dmem[8], dmem[9], dmem[10], dmem[11], dmem[12], dmem[13], dmem[14], dmem[15]);
    end

    // for test bench
    initial begin
        pc = 32'h0;

        // TODO データメモリ用の読み込みデータも作る
        $readmemh("build/testd.txt", dmem);
        $readmemh("build/testi.txt", imem);
    end

endmodule