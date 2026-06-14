`timescale 1ns / 1ps

// INSTRUCTION FETCH UNIT
// Manages the Program Counter
// Handles: normal increment, branch, jump

module instruction_fetch_unit(
    input         clk,
    input         reset,
    input  [31:0] imm_branch,    // branch offset (from imm_gen)
    input  [31:0] imm_jump,      // jump offset (from imm_gen)
    input         beq,           // branch taken signal
    input         bneq,
    input         bge,
    input         blt,
    input         jump,
    output reg [31:0] pc,        // current program counter
    output reg [31:0] pc_plus4   // return address for JAL
);

    always @(posedge clk) begin
        if (reset) begin
            pc       <= 32'b0;
            pc_plus4 <= 32'b0;
        end else begin
            pc_plus4 <= pc + 4;   // always save return address

            if (jump)
                pc <= pc + imm_jump;                              // JAL: PC-relative
            else if (beq || bneq || bge || blt)
                pc <= pc + imm_branch;                            // branch: PC-relative
            else
                pc <= pc + 4;                                     // normal increment
        end
    end

endmodule
