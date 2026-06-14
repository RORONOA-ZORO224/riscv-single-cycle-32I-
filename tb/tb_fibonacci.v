`timescale 1ns / 1ps

module tb_fibonacci;

    reg clk, reset;
    top_riscv dut (.clk(clk), .reset(reset));

    initial clk = 0;
    always #5 clk = ~clk;

  initial begin
    $dumpfile("fibonacci_wave.vcd");
    $dumpvars(0, tb_fibonacci);
    // Force dump all register array elements
    $dumpvars(0, tb_fibonacci.dut.dpu.rf.regs[0]);
    $dumpvars(0, tb_fibonacci.dut.dpu.rf.regs[1]);
    $dumpvars(0, tb_fibonacci.dut.dpu.rf.regs[2]);
    $dumpvars(0, tb_fibonacci.dut.dpu.rf.regs[3]);
    $dumpvars(0, tb_fibonacci.dut.dpu.rf.regs[10]);
end

    // Watch PC and key registers every cycle
    initial begin
        $display("Cycle |  PC  | x1(fib) | x2(fib) | x10(ctr)");
        $display("------+------+---------+---------+---------");
    end

    always @(posedge clk) begin
        if (!reset)
        $display("%5t | %4h | %7d | %7d | %7d",
            $time,
            dut.pc,
            dut.dpu.rf.regs[1],
            dut.dpu.rf.regs[2],
            dut.dpu.rf.regs[10]);
    end

    initial begin
        reset = 1;
        repeat(2) @(posedge clk); #1;
        reset = 0;

        // Run enough cycles for 8 loop iterations
        // Each iteration = 5 instructions + branch = ~6 cycles
        // 8 iterations * 6 + setup = ~55 cycles
        repeat(60) @(posedge clk); #1;

        $display("================================================");
        $display("  FIBONACCI RESULT");
        $display("================================================");
        $display("  x1  = %0d  (expect 21 = fib[8])", dut.dpu.rf.regs[1]);
        $display("  x2  = %0d  (expect 34 = fib[9])", dut.dpu.rf.regs[2]);
        $display("  x10 = %0d  (expect 0  = counter done)", dut.dpu.rf.regs[10]);
      

        if (dut.dpu.rf.regs[1] === 32'd21 &&
            dut.dpu.rf.regs[2] === 32'd34 &&
            dut.dpu.rf.regs[10] === 32'd0)
            $display("  *** EXPECTED RESULT ARRIVED-PASS ***");
        else
            $display("  *** FAIL — check branch logic ***");

        $finish;
    end

endmodule
