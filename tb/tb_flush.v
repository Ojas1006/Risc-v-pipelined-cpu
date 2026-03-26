`timescale 1ns / 1ps

module tb_flush;

    reg clk;
    reg reset;

    initial clk = 0;
    always #5 clk = ~clk;

    RISC_V_pipeline uut (
        .clk   (clk),
        .reset (reset)
    );

    // ── Probe register file ──────────────────────────────────────
    wire [31:0] x1  = uut.registerfile.regs[1];
    wire [31:0] x2  = uut.registerfile.regs[2];
    wire [31:0] x3  = uut.registerfile.regs[3];
    wire [31:0] x4  = uut.registerfile.regs[4];
    wire [31:0] x5  = uut.registerfile.regs[5];

    // ── Probe flush, PC, and branch signals ──────────────────────
    wire        flush    = uut.flush;
    wire        pc_sel   = uut.pc_sel;
    wire [31:0] pc_out   = uut.pc_out;

    integer pass_count;
    integer fail_count;
    integer flush_count;
    integer flush_detected;

    task check;
        input [63:0]  actual;
        input [63:0]  expected;
        input [127:0] label;
        begin
            if (actual === expected) begin
                $display("  PASS: %s = %0d", label, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: %s -- got %0d, expected %0d",
                          label, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ── Monitor flush signal every cycle ─────────────────────────
    always @(posedge clk) begin
        if (!reset && flush) begin
            flush_count    = flush_count + 1;
            flush_detected = 1;
            $display("  [Cycle monitor] FLUSH detected at time=%0t | PC=%0d", $time, pc_out);
        end
    end

    // ── Monitor PC jump ──────────────────────────────────────────
    always @(posedge clk) begin
        if (!reset && pc_sel) begin
            $display("  [Cycle monitor] BRANCH TAKEN at time=%0t | PC jumping to=%0d",
                      $time, uut.pc_in);
        end
    end

    initial begin
        pass_count     = 0;
        fail_count     = 0;
        flush_count    = 0;
        flush_detected = 0;

        $display("\n=== FLUSH TEST (TEST_FLUSH.dat) ===");
        $display("PC= 0 : addi x1, x0, 5   -> x1 = 5");
        $display("PC= 4 : addi x2, x0, 5   -> x2 = 5");
        $display("PC= 8 : beq  x1, x2, +12 -> TAKEN, PC jumps to 20");
        $display("PC=12 : addi x3, x0, 99  -> FLUSHED, x3 must stay 0");
        $display("PC=16 : addi x4, x0, 99  -> FLUSHED, x4 must stay 0");
        $display("PC=20 : addi x5, x0, 55  -> branch target, x5 = 55");
        $display("====================================\n");

        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        repeat (40) @(posedge clk);
        #1;

        // ── Register checks ──────────────────────────────────────
        $display("=== REGISTER FILE CHECKS ===");
        check(x1, 32'd5,  "x1  (addi x0, 5)              ");
        check(x2, 32'd5,  "x2  (addi x0, 5)              ");
        check(x3, 32'd0,  "x3  (MUST be 0 — flushed)     ");
        check(x4, 32'd0,  "x4  (MUST be 0 — flushed)     ");
        check(x5, 32'd55, "x5  (branch target addi = 55) ");

        // ── Flush behaviour checks ────────────────────────────────
        $display("\n=== FLUSH BEHAVIOUR CHECKS ===");
        if (flush_detected)
            $display("  PASS: flush signal went high at least once");
        else begin
            $display("  FAIL: flush never went high — branch not resolving");
            fail_count = fail_count + 1;
        end

        if (flush_count == 2)
            $display("  PASS: flush lasted exactly 2 cycles (flush_count = %0d)", flush_count);
        else begin
            $display("  FAIL: flush_count = %0d, expected exactly 2", flush_count);
            fail_count = fail_count + 1;
        end

        // ── PC jump check ─────────────────────────────────────────
        $display("\n=== PC JUMP CHECK ===");
        // x5 = 55 confirms PC reached 20 — so this is implied by register check above

        // ── Summary ───────────────────────────────────────────────
        $display("\n=== SUMMARY: %0d PASSED, %0d FAILED ===",
                  pass_count, fail_count);
        if (fail_count == 0)
            $display(">>> ALL FLUSH TESTS PASSED - Branch flush working correctly!\n");
        else
            $display(">>> FAILURES DETECTED - Check waveform viewer.\n");

        #100 $finish;
    end

endmodule
