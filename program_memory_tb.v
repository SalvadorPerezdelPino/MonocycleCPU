`timescale 1ns/1ps

module program_memory_tb;
    reg clk;
    reg [9:0] addr;
    wire [31:0] inst;

    program_memory pm (
        .clk(clk),
        .addr(addr),
        .inst(inst)
    );

    always #5 clk = ~clk; // 10 ns

    initial begin
        clk  = 0;
        addr = 0;

        #10 addr = 1;
        #10 addr = 2;
        #10 addr = 3;
        #10 $stop; // Simultation end
    end

endmodule
