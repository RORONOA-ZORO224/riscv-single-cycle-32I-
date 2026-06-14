`timescale 1ns / 1ps

// IMMEDIATE GENERATOR
// Extracts and sign-extends immediate values for all RV32I instruction types

module imm_gen(
    input  [31:0] instr,        // full 32-bit instruction
    output reg [31:0] imm_out   // sign-extended immediate value
);

    wire [6:0] opcode;
    assign opcode = instr[6:0];

    always @(*) begin
        case (opcode)

            // I-type: ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            7'b0010011,
            // I-type: LB, LH, LW, LBU, LHU
            7'b0000011,
            // I-type: JALR
            7'b1100111:
                imm_out = {{20{instr[31]}}, instr[31:20]};

            // S-type: SW, SH, SB
            7'b0100011:
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011:
                imm_out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            // U-type: LUI
            7'b0110111,
            // U-type: AUIPC
            7'b0010111:
                imm_out = {instr[31:12], 12'b0};

            // J-type: JAL
            7'b1101111:
                imm_out = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

            default:
                imm_out = 32'b0;
        endcase
    end

endmodule
