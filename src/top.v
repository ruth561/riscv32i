`timescale 1ps/1ps
`include "riscv32i.v"

// simulates core module
module TestBench;
    reg clock;
    reg reset;

    riscv32i core (
        .clock (clock), 
        .reset (reset)
    );

    always begin
        #1 clock = ~clock;
    end

    initial begin
        $dumpfile("build/dump.vcd");
        $dumpvars(0, TestBench);
        clock = 1'b0;
        #70 $finish;
    end
endmodule