`timescale 1ns / 1ps

// REGISTER FILE  
// Write on NEGEDGE, Read (asynchronous)
// This allows: write in first half of cycle, read updated value in second half
// Eliminates RAW hazard in single-cycle design without forwarding loops
// x0 hardwired to 0

module register_file(
    input         clk,
    input         rst,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [31:0] write_data,
    input         reg_write,
    output [31:0] read_data1,
    output [31:0] read_data2
);

    reg [31:0] regs [0:31];
    integer i;

    // Write on NEGEDGE — first half of clock cycle
    always @(negedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (reg_write && rd != 5'b0) begin
            regs[rd] <= write_data;
        end
    end

    // Asynchronous read — sees negedge-written value
    assign read_data1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign read_data2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

endmodule
