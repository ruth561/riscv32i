module riscv32i (clock, reset);
    input clock, reset;

    // opcode number
    parameter LW    = 7'b0000011; // lw rd, offset(rs1)
    parameter SW    = 7'b0100011; // sw rs2, offset(rs1)
    parameter OP    = 7'b0110011; // for example, add, sub, etc..
    parameter OP_IMM    = 7'b0010011; // for example, addi, subi, etc..
    parameter BRANCH    = 7'b1100011;

    // R-type funct field ({funct7, funct3})
    parameter FUNCT_ADD = 10'b0000000000;
    parameter FUNCT_SUB = 10'b0100000000;
    parameter FUNCT_AND = 10'b0000000111;
    parameter FUNCT_OR  = 10'b0000000110;
    parameter FUNCT_XOR = 10'b0000000100;
    parameter FUNCT_SLL = 10'b0000000001;
    parameter FUNCT_SRL = 10'b0000000101;
    parameter FUNCT_SRA = 10'b0100000101;
    parameter FUNCT_SLT = 10'b0000000010;
    parameter FUNCT_SLTU= 10'b0000000011;

    // I-type funct field
    parameter FUNCT_ADDI = 3'b000;
    parameter FUNCT_ANDI = 3'b111;
    parameter FUNCT_ORI  = 3'b110;
    parameter FUNCT_XORI = 3'b100;
    parameter FUNCT_SLLI = 3'b001;
    parameter FUNCT_SRI  = 3'b101;
    parameter FUNCT_SLTI = 3'b010;
    parameter FUNCT_SLTIU= 3'b011;

    reg [31:0] pc;
    reg [31:0] regs [0:31]; // registers file
    reg [31:0] imem [0:15]; // instruction memory
    /** TODO: データは１バイトずつにしたほうがいい */
    reg [31:0] dmem [0:15]; // data memory

    // pipeline registers between IF and ID 
    reg [31:0]  if_id_ir;

    // pipeline registers between ID and EX 
    reg [31:0]  id_ex_ir;
    reg [31:0]  id_ex_rs1; // rs1 value
    reg [31:0]  id_ex_rs2; // rs2 value
    reg [31:0]  id_ex_imm; // immediate 

    // pipeline registers between EX and MEM
    reg [31:0]  ex_mem_ir;
    reg [31:0]  ex_mem_rs2; // used in store instruction
    reg [31:0]  ex_mem_value; // result of ALU

    // pipeline registers between MEM and WB
    reg [31:0]  mem_wb_ir;
    reg [31:0]  mem_wb_data;

    // IF
    reg [31:0]  timer   = 0; // not implement pipeline
    always @(posedge clock) begin
        if_id_ir    <= imem[pc >> 2];
        timer       <= timer + 1;
        if (timer[1:0] == 2'b11) begin
            pc <= pc + 4;
        end
    end

    // ID
    always @(posedge clock) begin
        id_ex_ir <= if_id_ir;
        id_ex_rs1   <= (if_id_ir[19:15] == 5'b0) ? 32'b0 : regs[if_id_ir[19:15]];
        id_ex_rs2   <= (if_id_ir[24:20] == 5'b0) ? 32'b0 : regs[if_id_ir[24:20]];

        // immediate sign extension 
        case (if_id_ir[6:0])
            LW: id_ex_imm   <= {{20{if_id_ir[31]}}, if_id_ir[31:20]}; // type I
            SW: id_ex_imm   <= {{20{if_id_ir[31]}}, if_id_ir[31:25], if_id_ir[11:7]}; // type S
            OP_IMM: id_ex_imm   <= {{20{if_id_ir[31]}}, if_id_ir[31:20]}; // type I
            default: id_ex_imm <= 32'b0;
        endcase
    end

    // EX
    always @(posedge clock) begin
        ex_mem_ir   <= id_ex_ir;
        ex_mem_rs2  <= id_ex_rs2;
        if (ex_mem_ir[6:0] == LW)
            ex_mem_value    <= id_ex_rs1 + id_ex_imm; // address of dmem
        else if (ex_mem_ir[6:0] == SW)
            ex_mem_value    <= id_ex_rs1 + id_ex_imm;
        else if (ex_mem_ir[6:0] == OP)
            case ({ex_mem_ir[31:25], ex_mem_ir[14:12]})
                FUNCT_ADD: ex_mem_value <= id_ex_rs1 + id_ex_rs2;
                FUNCT_SUB: ex_mem_value <= id_ex_rs1 - id_ex_rs2;
                FUNCT_AND: ex_mem_value <= id_ex_rs1 & id_ex_rs2;
                FUNCT_OR : ex_mem_value <= id_ex_rs1 | id_ex_rs2;
                FUNCT_XOR: ex_mem_value <= id_ex_rs1 ^ id_ex_rs2;
                FUNCT_SLL: ex_mem_value <= id_ex_rs1 << id_ex_rs2[4:0];
                FUNCT_SRL: ex_mem_value <= id_ex_rs1 >> id_ex_rs2[4:0]; // unsigned shift
                FUNCT_SRA: ex_mem_value <= $signed(id_ex_rs1) >>> id_ex_rs2[4:0]; // signed shift
                FUNCT_SLT: ex_mem_value <= $signed(id_ex_rs1) < $signed(id_ex_rs2);
                FUNCT_SLTU:ex_mem_value <= id_ex_rs1 < id_ex_rs2;
            endcase
        else if (ex_mem_ir[6:0] == OP_IMM)
            case (ex_mem_ir[14:12])
                FUNCT_ADDI: ex_mem_value <= id_ex_rs1 + id_ex_imm;
                FUNCT_ANDI: ex_mem_value <= id_ex_rs1 & id_ex_imm;
                FUNCT_ORI : ex_mem_value <= id_ex_rs1 | id_ex_imm;
                FUNCT_XORI: ex_mem_value <= id_ex_rs1 ^ id_ex_imm;
                FUNCT_SLLI: ex_mem_value <= id_ex_rs1 << id_ex_imm[4:0];
                FUNCT_SRI: begin
                    if (id_ex_imm[10] == 1'b0)  // shift right logical
                        ex_mem_value <= id_ex_rs1 >> id_ex_imm[4:0];
                    else                        // shift right arithmetic
                        ex_mem_value <= $signed(id_ex_rs1) >>> id_ex_imm[4:0];
                end
                FUNCT_SLTI: ex_mem_value <= $signed(id_ex_rs1) < $signed(id_ex_imm);
                FUNCT_SLTIU:ex_mem_value <= id_ex_rs1 < {{20{1'b0}}, id_ex_imm[11:0]};
            endcase
    end

    // MEM
    always @(posedge clock) begin
        mem_wb_ir   <= ex_mem_ir;
        case (ex_mem_ir[6:0])
            LW: mem_wb_data <= dmem[ex_mem_value >> 2]; // data from data memory
            SW: dmem[ex_mem_value >> 2]  <= ex_mem_rs2; // write rs2 in dmem.
            OP: mem_wb_data <= ex_mem_value;
            OP_IMM: mem_wb_data <= ex_mem_value;
        endcase
    end

    // WB
    always @(posedge clock) begin
        case (mem_wb_ir[6:0])
            LW: regs[mem_wb_ir[11:7]]   <= mem_wb_data;
            OP: regs[mem_wb_ir[11:7]]   <= mem_wb_data;
            OP_IMM: regs[mem_wb_ir[11:7]]   <= mem_wb_data;
        endcase
    end

    always @(posedge clock) begin // debug
        if (timer[1:0] == 2'b10) begin
            // timing is shifted from PC increment
            $display("-----");
            $display("pc  : %x --> %b (%x)", pc, imem[pc >> 2], imem[pc >> 2]);
            $display("ra  : %x", regs[1]);
            $display("sp  : %x", regs[2]);
            $display("t0  : %x", regs[5]);
            $display("t1  : %x", regs[6]);
            $display("t2  : %x", regs[7]);
            $display("t3  : %x", regs[28]);
            $display("t4  : %x", regs[29]);
            $display("t5  : %x", regs[30]);
            $display("t6  : %x", regs[31]);
            $display("");
            $display("[data memory dump]");
            $display("0000: %x %x %x %x", dmem[0], dmem[1], dmem[2], dmem[3]);
            $display("0010: %x %x %x %x", dmem[4], dmem[5], dmem[6], dmem[7]);
            $display("0020: %x %x %x %x", dmem[8], dmem[9], dmem[10], dmem[11]);
            $display("0030: %x %x %x %x", dmem[12], dmem[13], dmem[14], dmem[15]);
        end
    end

    // set instructions in imem.
    reg [32:0] i;
    initial begin
        pc = 32'h0;
        // initialize for debug
        regs[0]      <= 32'h00000000;
        regs[1]      <= 32'h11111111;
        regs[2]      <= 32'h22222222;
        regs[3]      <= 32'h33333333;
        regs[4]      <= 32'h44444444;
        regs[5]      <= 32'h55555555;
        regs[6]      <= 32'h66666666;
        regs[7]      <= 32'h77777777;
        regs[8]      <= 32'h88888888;
        regs[9]      <= 32'h99999999;
        regs[10]     <= 32'haaaaaaaa;
        regs[11]     <= 32'hbbbbbbbb;
        regs[12]     <= 32'hcccccccc;
        regs[13]     <= 32'hdddddddd;
        regs[14]     <= 32'heeeeeeee;
        regs[15]     <= 32'hffffffff;

        // TODO データメモリ用の読み込みデータも作る
        $readmemh("build/testd.txt", dmem);
        $readmemh("build/testi.txt", imem);
    end
endmodule