`timescale 1ns / 1ps

// Decodes opcode + funct3 + funct7 and drives all control signals

module control_unit(
    input        reset,
    input  [6:0] funct7,
    input  [2:0] funct3,
    input  [6:0] opcode,
    output reg [5:0] alu_control,
    output reg       lb,
    output reg       mem_to_reg,
    output reg       bneq_control,
    output reg       beq_control,
    output reg       bgeq_control,
    output reg       blt_control,
    output reg       jump,
    output reg       sw,
    output reg       lui_control,
    output reg       reg_write       //  enables register file write
);

    always @(*) begin

        // Default all signals to 0 — prevents latches
        alu_control  = 6'b0;
        lb           = 0;
        mem_to_reg   = 0;
        beq_control  = 0;
        bneq_control = 0;
        bgeq_control = 0;
        blt_control  = 0;
        jump         = 0;
        sw           = 0;
        lui_control  = 0;
        reg_write    = 0;

        if (reset) begin
           
        end else begin

            case (opcode)

               
                // R-TYPE
                
                7'b0110011: begin
                    reg_write = 1;
                    case (funct3)
                        3'b000: alu_control = (funct7 == 7'b0100000) ? 6'b000010 : 6'b000001; // SUB : ADD
                        3'b001: alu_control = 6'b000011; // SLL
                        3'b010: alu_control = 6'b000100; // SLT
                        3'b011: alu_control = 6'b000101; // SLTU
                        3'b100: alu_control = 6'b000110; // XOR
                        3'b101: alu_control = (funct7 == 7'b0100000) ? 6'b001000 : 6'b000111; // SRA : SRL
                        3'b110: alu_control = 6'b001001; // OR
                        3'b111: alu_control = 6'b001010; // AND
                        default: alu_control = 6'b0;
                    endcase
                end

            
                // I-TYPE ALU
                
                7'b0010011: begin
                    reg_write = 1;
                    case (funct3)
                        3'b000: alu_control = 6'b001011; // ADDI
                        3'b001: alu_control = 6'b001100; // SLLI
                        3'b010: alu_control = 6'b001101; // SLTI
                        3'b011: alu_control = 6'b001110; // SLTIU
                        3'b100: alu_control = 6'b001111; // XORI
                        3'b101: alu_control = (funct7 == 7'b0100000) ? 6'b010001 : 6'b010000; // SRAI : SRLI
                        3'b110: alu_control = 6'b010010; // ORI
                        3'b111: alu_control = 6'b010011; // ANDI
                        default: alu_control = 6'b0;
                    endcase
                end

        
                // LOAD
               
                7'b0000011: begin
                    mem_to_reg = 1;
                    reg_write  = 1;
                    lb         = 1;
                    case (funct3)
                        3'b000: alu_control = 6'b010100; // LB
                        3'b001: alu_control = 6'b010101; // LH
                        3'b010: alu_control = 6'b010110; // LW
                        3'b100: alu_control = 6'b010111; // LBU
                        3'b101: alu_control = 6'b011000; // LHU
                        default: alu_control = 6'b0;
                    endcase
                end

                
                // STORE
              
                7'b0100011: begin
                    sw = 1;
                    case (funct3)
                        3'b000: alu_control = 6'b011011; // SB
                        3'b001: alu_control = 6'b011010; // SH
                        3'b010: alu_control = 6'b011001; // SW
                        default: alu_control = 6'b0;
                    endcase
                end

               
                // BRANCH
                
                7'b1100011: begin
                    case (funct3)
                        3'b000: begin alu_control = 6'b011100; beq_control  = 1; end // BEQ
                        3'b001: begin alu_control = 6'b011101; bneq_control = 1; end // BNE
                        3'b100: begin alu_control = 6'b011110; blt_control  = 1; end // BLT
                        3'b101: begin alu_control = 6'b011111; bgeq_control = 1; end // BGE
                        3'b110: begin alu_control = 6'b100000; blt_control  = 1; end // BLTU
                        3'b111: begin alu_control = 6'b100001; bgeq_control = 1; end // BGEU
                        default: alu_control = 6'b0;
                    endcase
                end

              
                // LUI
                
                7'b0110111: begin
                    alu_control = 6'b100010;
                    lui_control = 1;
                    reg_write   = 1;
                end

       
                // JAL
               
                7'b1101111: begin
                    alu_control = 6'b100011;
                    jump        = 1;
                    reg_write   = 1;
                end

                
                // JALR
               
                7'b1100111: begin
                    alu_control = 6'b100011;
                    jump        = 1;
                    reg_write   = 1;
                end

                default: alu_control = 6'b0;

            endcase
        end
    end

endmodule
