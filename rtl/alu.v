`timescale 1ns / 1ps


// Supports all RV32I arithmetic, logic, shift, and branch compare operations

module alu(
    input  [31:0] src1,         // register rs1 value
    input  [31:0] src2,         // register rs2 value OR immediate
    input  [5:0]  alu_control,  // operation select
    output reg [31:0] result
);

    always @(*) begin
        case (alu_control)

        
            // R-TYPE OPERATIONS
           
            6'b000001: result = src1 + src2;                                        // ADD
            6'b000010: result = src1 - src2;                                        // SUB
            6'b000011: result = src1 << src2[4:0];                                  // SLL
            6'b000100: result = ($signed(src1) < $signed(src2)) ? 32'd1 : 32'd0;   // SLT
            6'b000101: result = ($unsigned(src1) < $unsigned(src2)) ? 32'd1 : 32'd0; // SLTU
            6'b000110: result = src1 ^ src2;                                        // XOR
            6'b000111: result = src1 >> src2[4:0];                                  // SRL
            6'b001000: result = $signed(src1) >>> src2[4:0];                        // SRA
            6'b001001: result = src1 | src2;                                        // OR
            6'b001010: result = src1 & src2;                                        // AND

          
            // I-TYPE OPERATIONS (immediate in src2)
           
            6'b001011: result = src1 + src2;                                        // ADDI
            6'b001100: result = src1 << src2[4:0];                                  // SLLI
            6'b001101: result = ($signed(src1) < $signed(src2)) ? 32'd1 : 32'd0;   // SLTI
            6'b001110: result = ($unsigned(src1) < $unsigned(src2)) ? 32'd1 : 32'd0; // SLTIU
            6'b001111: result = src1 ^ src2;                                        // XORI
            6'b010000: result = src1 >> src2[4:0];                                  // SRLI
            6'b010001: result = $signed(src1) >>> src2[4:0];                        // SRAI
            6'b010010: result = src1 | src2;                                        // ORI
            6'b010011: result = src1 & src2;                                        // ANDI

        
            // LOAD / STORE 
           
            6'b010100: result = src1 + src2;                                        // LB  address
            6'b010101: result = src1 + src2;                                        // LH  address
            6'b010110: result = src1 + src2;                                        // LW  address
            6'b010111: result = src1 + src2;                                        // LBU address
            6'b011000: result = src1 + src2;                                        // LHU address
            6'b011001: result = src1 + src2;                                        // SW  address
            6'b011010: result = src1 + src2;                                        // SH  address
            6'b011011: result = src1 + src2;                                        // SB  address

         
            // BRANCH COMPARE
            
            6'b011100: result = (src1 == src2) ? 32'd1 : 32'd0;                    // BEQ
            6'b011101: result = (src1 != src2) ? 32'd1 : 32'd0;                    // BNE
            6'b011110: result = ($signed(src1) < $signed(src2)) ? 32'd1 : 32'd0;   // BLT
            6'b011111: result = ($signed(src1) >= $signed(src2)) ? 32'd1 : 32'd0;  // BGE
            6'b100000: result = ($unsigned(src1) < $unsigned(src2)) ? 32'd1 : 32'd0; // BLTU
            6'b100001: result = ($unsigned(src1) >= $unsigned(src2)) ? 32'd1 : 32'd0; // BGEU

           
            // LUI / JAL 
           
            6'b100010: result = src2;                                               // LUI
            6'b100011: result = src1 + src2;                                        // JAL/JALR address

            default:   result = 32'b0;
        endcase
    end

endmodule
