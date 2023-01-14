`timescale 1ps/1ps
`include "core.v"

// simulates core module
module top_pipeline;
    reg clock;
    reg reset;

    core core (
        .clock (clock), 
        .reset (reset)
    );

    always begin
        #1 clock = ~clock;
    end

    initial begin
        $dumpfile("build/dump.vcd");
        $dumpvars(0, top_pipeline);
        clock = 1'b0;
        #36 $finish;
    end
endmodule