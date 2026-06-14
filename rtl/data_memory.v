`timescale 1ns / 1ps

// DATA MEMORY
// 256 x 32-bit word-addressable memory
// Synchronous write, asynchronous read

module data_memory(
    input         clk,
    input         rst,
    input  [31:0] addr,       // byte address (word aligned)
    input  [31:0] wr_data,    // data to write
    input         sw,         // store enable
    output [31:0] rd_data     // data read output
);

    reg [31:0] mem [0:255];   // 256 words, 32-bit wide (fixed from 8-bit)
    integer i;

    // Synchronous write
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 32'b0;
        end else if (sw) begin
            mem[addr[9:2]] <= wr_data;   // word-aligned: divide addr by 4
        end
    end

    // Asynchronous read
    assign rd_data = mem[addr[9:2]];

endmodule
