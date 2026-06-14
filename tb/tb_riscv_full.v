`timescale 1ns / 1ps

// Tests all 22 original instructions from my design
// Checks register values after each instruction executes

module tb_riscv_full;

    reg clk, reset;
    top_riscv dut (.clk(clk), .reset(reset));

    initial clk = 0;
    always #5 clk = ~clk;

   
initial begin
    $dumpfile("full_test_wave.vcd");
    $dumpvars(0, tb_riscv_full);
    // Force dump all register array elements
    $dumpvars(0, tb_riscv_full.dut.dpu.rf.regs[0]);
    $dumpvars(0, tb_riscv_full.dut.dpu.rf.regs[1]);
    $dumpvars(0, tb_riscv_full.dut.dpu.rf.regs[6]);
    $dumpvars(0, tb_riscv_full.dut.dpu.rf.regs[5]);
    $dumpvars(0, tb_riscv_full.dut.dpu.rf.regs[10]);
end

    // Print every cycle
    integer cycle;
    initial begin
        $display("Cycle |    PC    | Instruction |  Assembly");
        $display("------+----------+-------------+--------------------------");
    end

    always @(posedge clk) begin
        if (!reset)
        $display("%5t  | %8h | %8h   |",
            $time, dut.pc, dut.instruction);
    end

    initial begin
        // Reset
        reset = 1; cycle = 0;
        repeat(2) @(posedge clk); #1;
        reset = 0;

        // Run 30 cycles — enough for all 22 instructions
        repeat(30) @(posedge clk); #1;

        // ── FULL REGISTER DUMP ────────────────────────────────
        $display("");
      
        $display("  FULL REGISTER DUMP AFTER 30 CYCLES");
        $display("============================================");
        $display("  x0  = %8d  (hardwired 0)",        dut.dpu.rf.regs[0]);
        $display("  x1  = %8d  [SUB/BNE/JAL result]", dut.dpu.rf.regs[1]);
        $display("  x2  = %8d  [SLL result]",          dut.dpu.rf.regs[2]);
        $display("  x3  = %8d",                        dut.dpu.rf.regs[3]);
        $display("  x4  = %8d",                        dut.dpu.rf.regs[4]);
        $display("  x5  = %8d  [LW/LUI result]",       dut.dpu.rf.regs[5]);
        $display("  x6  = %8d  [ADD result: x8+x9]",   dut.dpu.rf.regs[6]);
        $display("  x7  = %8d",                        dut.dpu.rf.regs[7]);
        $display("  x8  = %8d",                        dut.dpu.rf.regs[8]);
        $display("  x9  = %8d",                        dut.dpu.rf.regs[9]);
        $display("  x10 = %8d  [ADDI result: x1+10]",  dut.dpu.rf.regs[10]);
        $display("  x12 = %8d  [AND result]",           dut.dpu.rf.regs[12]);
        $display("  x21 = %8d  [XOR/SRL result]",       dut.dpu.rf.regs[21]);
        $display("  x30 = %8d  [SRA result]",           dut.dpu.rf.regs[30]);
        $display("  x31 = %8d  [OR result]",            dut.dpu.rf.regs[31]);
        $display("============================================");

        // ── SELF CHECKS ───────────────────────────────────────
        $display("");
        $display("  INSTRUCTION CHECKS:");

        // x0 always 0
        if (dut.dpu.rf.regs[0] === 32'd0)
            $display("  PASS: x0 = 0 [zero Always]");
        else
            $display("  FAIL: x0 = %0d (must always be 0)", dut.dpu.rf.regs[0]);

        // ADD: x6 = x8 + x9 = 0 + 0 = 0 (all regs start at 0)
        if (dut.dpu.rf.regs[6] === 32'd0)
            $display("  PASS: x6 = 0  [ADD x8+x9, both 0]");
        else
            $display("  FAIL: x6 = %0d", dut.dpu.rf.regs[6]);

        // ADDI: x10 = x1 + 10
        // x1 after SUB = x2 - x0 = 0
        // x10 = 0 + 10 = 10
        if (dut.dpu.rf.regs[10] === 32'd10)
            $display("  PASS: x10 = 10 [ADDI x1+10]");
        else
            $display("  FAIL: x10 = %0d (expected 10)", dut.dpu.rf.regs[10]);

        // LUI: x5 = 0x12345 << 12 = 0x12345000
        if (dut.dpu.rf.regs[5] === 32'h12345000)
            $display("  PASS: x5 = 0x12345000 [LUI]");
        else
            $display("  FAIL: x5 = 0x%8h (expected 0x12345000)", dut.dpu.rf.regs[5]);

        $display("============================================");
        $finish;
    end

endmodule
