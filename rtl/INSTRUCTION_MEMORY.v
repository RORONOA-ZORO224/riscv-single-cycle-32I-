`timescale 1ns / 1ps

// INSTRUCTION MEMORY
// Original Gawtam design — all instructions preserved
// Fixed: byte-addressable 8-bit → 32-bit word addressable
// Fixed: initial block instead of always@reset
// Fixed: branch offsets from 0 to 4 so all instructions execute
// Fixed: port names match top_riscv.v

module instruction_memory(
    input  [31:0] pc,
    output [31:0] instruction
);

    reg [31:0] mem [0:31];

    initial begin
        // ── R-TYPE INSTRUCTIONS ──────────────────────────────
        mem[0]  = 32'h00940333; // ADD  x6,  x8,  x9
        mem[1]  = 32'h800100b3; // SUB  x1,  x2,  x0
        mem[2]  = 32'h00209133; // SLL  x2,  x1,  x2
        mem[3]  = 32'h00c54ab3; // XOR  x21, x10, x12
        mem[4]  = 32'h00c55ab3; // SRL  x21, x10, x12
        mem[5]  = 32'h01bd5f33; // SRA  x30, x27, x27
        mem[6]  = 32'h00d67fb3; // OR   x31, x12, x13
        mem[7]  = 32'h00f768b3; // AND  x12, x15, x15

        // ── I-TYPE ALU INSTRUCTIONS ──────────────────────────
        mem[8]  = 32'h00a08513; // ADDI x10, x1,  10
        mem[9]  = 32'h00419313; // SLLI x6,  x3,  4
        mem[10] = 32'h03f2c726; // XORI (original encoding preserved)
        mem[11] = 32'h00a12093; // SLTI x1,  x2,  10
        mem[12] = 32'h00315093; // SRLI x1,  x2,  3
        mem[13] = 32'h00f16093; // ORI  x1,  x2,  15
        mem[14] = 32'h00f17093; // ANDI x1,  x2,  15

        // ── LOAD / STORE ─────────────────────────────────────
        mem[15] = 32'h00430283; // LW   x5,  4(x6)
        mem[16] = 32'h00732823; // SW   x7,  16(x6)

        // ── BRANCH INSTRUCTIONS ──────────────────────────────
        // Fixed: offset=4 (not 0) so execution continues past branch
        mem[17] = 32'h00410263; // BEQ  x2, x4, 4   → skip 1 (branch taken if x2==x4)
        mem[18] = 32'h00209263; // BNE  x1, x2, 4   → skip 1 (branch taken if x1!=x2)
        mem[19] = 32'h0041D263; // BGE  x3, x4, 4   → skip 1 (branch taken if x3>=x4)

        // ── UPPER IMMEDIATE ──────────────────────────────────
        mem[20] = 32'h123452b7; // LUI  x5, 0x12345  → x5 = 0x12345000

        // ── JUMP ─────────────────────────────────────────────
        mem[21] = 32'h000080ef; // JAL  x1, 8        → jump to PC+8, x1=PC+4

        // ── NOPs ─────────────────────────────────────────────
        begin : fill
            integer i;
            for (i = 22; i < 32; i = i + 1)
                mem[i] = 32'h00000013; // NOP (ADDI x0, x0, 0)
        end
    end

    // Word-aligned read
    assign instruction = mem[pc[6:2]];

endmodule
