// TEST_JAL_VISIBLE.dat — JAL with +24 offset so jump is obvious in waveform
// pc_out skips 0x08 through 0x18, goes straight to 0x1C
`timescale 1ns / 1ps

module tb_jal;

    reg clk;
    reg reset;

    initial clk = 0;
    always #5 clk = ~clk;

    RISC_V_pipeline uut (
        .clk(clk),
        .reset(reset)
    );

    wire [31:0] x1  = uut.registerfile.regs[1];
    wire [31:0] x2  = uut.registerfile.regs[2];
    wire [31:0] x3  = uut.registerfile.regs[3];
    wire [31:0] x4  = uut.registerfile.regs[4];
    wire [31:0] x10 = uut.registerfile.regs[10];
    wire [31:0] x11 = uut.registerfile.regs[11];
    wire [31:0] x12 = uut.registerfile.regs[12];
    wire [31:0] x13 = uut.registerfile.regs[13];
    wire [31:0] x14 = uut.registerfile.regs[14];

    wire        flush  = uut.flush;
    wire        jump   = uut.Jump;
    wire [31:0] pc_out = uut.pc_out;
    wire [31:0] pc_in  = uut.pc_in;

    integer pass_count;
    integer fail_count;
    integer flush_count;

    task check;
        input [63:0]  actual;
        input [63:0]  expected;
        input [127:0] label;
        begin
            if (actual === expected) begin
                $display("  PASS: %s = 0x%08X (%0d)", label, actual, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: %s -- got 0x%08X, expected 0x%08X",
                          label, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    always @(posedge clk) begin
        if (!reset && flush) begin
            flush_count = flush_count + 1;
            $display("  [FLUSH] time=%0t | pc_out=0x%08X | pc_in=0x%08X",
                      $time, pc_out, pc_in);
        end
        if (!reset && jump)
            $display("  [JUMP]  time=%0t | pc_out=0x%08X | jumping to pc_in=0x%08X",
                      $time, pc_out, pc_in);
    end

    initial begin
        $dumpfile("jal_test.vcd");
        $dumpvars(0, tb_jal);

        pass_count  = 0;
        fail_count  = 0;
        flush_count = 0;

        $display("\n=== JAL TEST (TEST_JAL_VISIBLE.dat) ===");
        $display("PC= 0 : ADDI x1,  x0, 5    -> x1=5");
        $display("PC= 4 : JAL  x2, +24       -> x2=8, jump to PC=28 (0x1C)");
        $display("PC= 8 : ADDI x10, x0, 99   -> FLUSHED (x10 must stay 0)");
        $display("PC=12 : ADDI x11, x0, 99   -> FLUSHED (x11 must stay 0)");
        $display("PC=16 : ADDI x12, x0, 99   -> FLUSHED (x12 must stay 0)");
        $display("PC=20 : ADDI x13, x0, 99   -> FLUSHED (x13 must stay 0)");
        $display("PC=24 : ADDI x14, x0, 99   -> FLUSHED (x14 must stay 0)");
        $display("PC=28 : ADDI x3,  x0, 77   -> x3=77  (JUMP TARGET)");
        $display("PC=32 : ADDI x4,  x0, 88   -> x4=88");
        $display("WAVEFORM: pc_out jumps from 0x08 directly to 0x1C, skipping 5 instrs");
        $display("==========================================\n");

        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        repeat(40) @(posedge clk);
        #1;

        $display("=== REGISTER FILE CHECKS ===");
        check(x1,  32'd5,  "x1  (addi)                  ");
        check(x2,  32'd8,  "x2  (JAL return addr = 4+4) ");
        check(x3,  32'd77, "x3  (jump target)           ");
        check(x4,  32'd88, "x4  (after target)          ");
        check(x10, 32'd0,  "x10 (FLUSHED, must be 0)    ");
        check(x11, 32'd0,  "x11 (FLUSHED, must be 0)    ");
        check(x12, 32'd0,  "x12 (FLUSHED, must be 0)    ");
        check(x13, 32'd0,  "x13 (FLUSHED, must be 0)    ");
        check(x14, 32'd0,  "x14 (FLUSHED, must be 0)    ");

        $display("\n=== FLUSH CHECK ===");
        if (flush_count >= 1)
            $display("  PASS: flush fired (count=%0d)", flush_count);
        else begin
            $display("  FAIL: flush never fired");
            fail_count = fail_count + 1;
        end

        $display("\n=== SUMMARY: %0d PASSED, %0d FAILED ===",
                  pass_count, fail_count);
        if (fail_count == 0)
            $display(">>> ALL JAL TESTS PASSED\n");
        else
            $display(">>> FAILURES DETECTED\n");

        $finish;
    end

endmodule
