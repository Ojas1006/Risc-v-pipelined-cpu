`timescale 1ns / 1ps

module tb_stall;

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
    wire [31:0] x10 = uut.registerfile.regs[10];

    // ── Probe stall and PC directly ──────────────────────────────
    wire        stall = uut.stall;
    wire [31:0] pc    = uut.pc_out;

    // ── Reconstruct mem[0] from byte-wide data memory ────────────
    wire [31:0] dmem_word0 = { uut.dm.mem[3],
                                uut.dm.mem[2],
                                uut.dm.mem[1],
                                uut.dm.mem[0] };

    integer pass_count;
    integer fail_count;

    // ── Stall cycle counter ──────────────────────────────────────
    integer stall_count;
    integer stall_detected;

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

    // ── Monitor stall signal every cycle ─────────────────────────
    always @(posedge clk) begin
        if (!reset && stall) begin
            stall_count    = stall_count + 1;
            stall_detected = 1;
            $display("  [Cycle monitor] STALL detected at time=%0t | PC=%0d", $time, pc);
        end
    end

    initial begin
        $dumpfile("stall_test.vcd");
        $dumpvars(0, tb_stall);

        pass_count     = 0;
        fail_count     = 0;
        stall_count    = 0;
        stall_detected = 0;

        $display("\n=== STALL TEST (TEST_STALL.dat) ===");
        $display("PC= 0 : addi x10, x0, 42  -> x10 = 42");
        $display("PC= 4 : sw   x10, 0(x0)  -> mem[0] = 42");
        $display("PC= 8 : lw   x1,  0(x0)  -> x1  = 42");
        $display("PC=12 : add  x2,  x1, x1 -> x2  = 84  (STALL expected here)");
        $display("PC=16 : addi x3,  x0, 1  -> x3  = 1   (executes after stall)");
        $display("====================================\n");

        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        repeat (40) @(posedge clk);
        #1;

        // ── Register checks ──────────────────────────────────────
        $display("=== REGISTER FILE CHECKS ===");
        check(x10, 32'd42, "x10 (addi x0, 42)              ");
        check(x1,  32'd42, "x1  (lw from mem[0])           ");
        check(x2,  32'd84, "x2  (add x1+x1, after stall)   ");
        check(x3,  32'd1,  "x3  (addi x0, 1 post-stall)    ");

        // ── Memory check ─────────────────────────────────────────
        $display("\n=== DATA MEMORY CHECKS ===");
        check(dmem_word0, 32'd42, "dm[0] (sw x10 = 42)           ");

        // ── Stall behaviour check ─────────────────────────────────
        $display("\n=== STALL BEHAVIOUR CHECKS ===");
        if (stall_detected)
            $display("  PASS: stall signal went high at least once");
        else
            $display("  FAIL: stall signal never went high — hazard unit not triggering");

        if (stall_count == 1)
            $display("  PASS: stall lasted exactly 1 cycle (stall_count = %0d)", stall_count);
        else
            $display("  FAIL: stall_count = %0d, expected exactly 1", stall_count);

        // ── Summary ───────────────────────────────────────────────
        $display("\n=== SUMMARY: %0d PASSED, %0d FAILED ===",
                  pass_count, fail_count + (stall_detected ? 0 : 1) + (stall_count==1 ? 0 : 1));
        if (fail_count == 0 && stall_detected && stall_count == 1)
            $display(">>> ALL STALL TESTS PASSED - Hazard detection working correctly!\n");
        else
            $display(">>> FAILURES DETECTED - Check waveform viewer.\n");

        $finish;
    end

endmodule