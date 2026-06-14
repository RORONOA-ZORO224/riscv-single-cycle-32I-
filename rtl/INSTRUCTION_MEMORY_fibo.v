`timescale 1ns / 1ps

// INSTRUCTION MEMORY — Fibonacci Program (no NOPs needed)
// x1 = 21 (fib[8]), x2 = 34 (fib[9]) after execution

module instruction_memory(
    input  [31:0] pc,
    output [31:0] instruction
);

    reg [31:0] mem [0:255];

    initial begin
        mem[0]  = 32'h00000093; // ADDI x1,  x0, 0    → x1=0
        mem[1]  = 32'h00100113; // ADDI x2,  x0, 1    → x2=1
        mem[2]  = 32'h00800513; // ADDI x10, x0, 8    → counter=8
        // loop at PC=0x0C
        mem[3]  = 32'h002081B3; // ADD  x3, x1, x2    → x3=x1+x2
        mem[4]  = 32'h00010093; // ADDI x1, x2, 0     → x1=x2
        mem[5]  = 32'h00018113; // ADDI x2, x3, 0     → x2=x3
        mem[6]  = 32'hFFF50513; // ADDI x10,x10,-1    → counter--
        // BNE x10, x0, -16 (back to mem[3] = PC=0x0C)
        // BNE at PC=0x1C, target=0x0C, offset=-16
        mem[7]  = 32'hFE0518E3; // BNE x10, x0, -16
        mem[8]  = 32'h00000013; // NOP
        mem[9]  = 32'h00000013; // NOP

        begin : fill
            integer i;
            for (i = 10; i < 256; i = i + 1)
                mem[i] = 32'h00000013;
        end
    end

    assign instruction = mem[pc[9:2]];

endmodule
