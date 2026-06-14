`timescale 1ns / 1ps

// DATAPATH
// Connects: Register File, ALU, Data Memory, Immediate Gen

module data_path(
    input         clk,
    input         rst,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [5:0]  alu_control,
    input         jump,
    input         beq_control,
    input         bneq_control,
    input         bgeq_control,
    input         blt_control,
    input         mem_to_reg,
    input         lb,
    input         sw,
    input         lui_control,
    input         reg_write,
    input  [31:0] imm_val,
    input  [31:0] pc_plus4,
    output        beq,
    output        bneq,
    output        bge,
    output        blt,
    output [31:0] alu_result   // exposed for debug
);

    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] mem_rd_data;
    wire [31:0] alu_src2;
    wire [31:0] write_back_data;

    // ALU src2 mux — carefully separated by instruction type:
    // R-type    (6'b000001–6'b001010): compare/compute reg vs reg → read_data2
    // I-type    (6'b001011–6'b010011): ALU with immediate         → imm_val
    // Load/Store(6'b010100–6'b011011): address = base + offset    → imm_val
    // Branch    (6'b011100–6'b100001): compare rs1 vs rs2         → read_data2
    // LUI/JAL   (6'b100010–6'b100011): pass immediate through     → imm_val
    assign alu_src2 = ((alu_control >= 6'b000001 && alu_control <= 6'b001010) ||
                       (alu_control >= 6'b011100 && alu_control <= 6'b100001))
                       ? read_data2 : imm_val;

    // Write-back mux
    assign write_back_data = jump       ? pc_plus4   :
                             mem_to_reg ? mem_rd_data :
                                          alu_result;

    // Register File
    register_file rf (
        .clk        (clk),
        .rst        (rst),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .write_data (write_back_data),
        .reg_write  (reg_write),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );

    // ALU
    alu alu_unit (
        .src1        (read_data1),
        .src2        (alu_src2),
        .alu_control (alu_control),
        .result      (alu_result)
    );

    // Data Memory
    data_memory dmem (
        .clk     (clk),
        .rst     (rst),
        .addr    (alu_result),
        .wr_data (read_data2),
        .sw      (sw),
        .rd_data (mem_rd_data)
    );

    // Branch signals → IFU
    assign beq  = (alu_result == 32'd1 && beq_control)  ? 1'b1 : 1'b0;
    assign bneq = (alu_result == 32'd1 && bneq_control) ? 1'b1 : 1'b0;
    assign bge  = (alu_result == 32'd1 && bgeq_control) ? 1'b1 : 1'b0;
    assign blt  = (alu_result == 32'd1 && blt_control)  ? 1'b1 : 1'b0;

endmodule
