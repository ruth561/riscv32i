`timescale 1ps/1ps
`include "core.v"

// simulates core module
module top_pipeline;
    reg         clock;
    reg         reset;

    wire        exit;
    wire [31:0] gp;

    core core (
        .clock      (clock), 
        .reset      (reset),
        
        .exit       (exit),
        .gp   (gp)
    );

    always begin
        #1 clock = ~clock;
    end

    always @(posedge clock) begin
        if (exit) begin
            if (gp == 32'h1) begin
                $display("==================================================");
                $display("       passed the test!  (gp = %x)         ", gp);
                $display("==================================================");
            end else begin
                $display("==================================================");
                $display("       failed the test.. (gp = %x)         ", gp);
                $display("==================================================");
            end
            $finish;
        end
    end

    initial begin
        $dumpfile("build/dump.vcd");
        $dumpvars(0, top_pipeline);
        clock = 1'b0;
        reset = 1'b0;
        #3000 $finish;
    end
endmodule