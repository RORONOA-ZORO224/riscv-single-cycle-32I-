`timescale 1ns / 1ps

module top_riscv(
    input clk,
    input reset
);

    wire [31:0] pc, pc_plus4, instruction, imm_val;
    wire [5:0]  alu_control;
    wire        mem_to_reg, beq_control, bneq_control;
    wire        bgeq_control, blt_control, jump, sw, lb, lui_control, reg_write;
    wire        beq, bneq, bge, blt;

    instruction_fetch_unit ifu (
        .clk        (clk),   .reset      (reset),
        .imm_branch (imm_val),.imm_jump   (imm_val),
        .beq        (beq),   .bneq       (bneq),
        .bge        (bge),   .blt        (blt),
        .jump       (jump),  .pc         (pc),
        .pc_plus4   (pc_plus4)
    );

    instruction_memory imem (
        .pc          (pc),
        .instruction (instruction)
    );

    control_unit cu (
        .reset       (reset),
        .funct7      (instruction[31:25]),
        .funct3      (instruction[14:12]),
        .opcode      (instruction[6:0]),
        .alu_control (alu_control),
        .lb          (lb),         .mem_to_reg  (mem_to_reg),
        .bneq_control(bneq_control),.beq_control (beq_control),
        .bgeq_control(bgeq_control),.blt_control (blt_control),
        .jump        (jump),       .sw          (sw),
        .lui_control (lui_control),.reg_write   (reg_write)
    );

    imm_gen ig (
        .instr   (instruction),
        .imm_out (imm_val)
    );

    data_path dpu (
        .clk          (clk),          .rst          (reset),
        .rs1          (instruction[19:15]),
        .rs2          (instruction[24:20]),
        .rd           (instruction[11:7]),
        .alu_control  (alu_control),  .jump         (jump),
        .beq_control  (beq_control),  .bneq_control (bneq_control),
        .bgeq_control (bgeq_control), .blt_control  (blt_control),
        .mem_to_reg   (mem_to_reg),   .lb           (lb),
        .sw           (sw),           .lui_control  (lui_control),
        .reg_write    (reg_write),    .imm_val      (imm_val),
        .pc_plus4     (pc_plus4),
        .beq          (beq),          .bneq         (bneq),
        .bge          (bge),          .blt          (blt),
        .alu_result   ()
    );

endmodule
