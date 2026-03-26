`timescale 1ns / 1ps

module tb_RISC_V_pipeline;

    reg clk;
    reg reset;

    initial clk = 0;
    always #5 clk = ~clk;

    RISC_V_pipeline uut (
        .clk   (clk),
        .reset (reset)
    );

    // ── Load .dat file directly into instruction memory ──────────
    // Update path if your project folder name is different
    initial begin
        #1; 
        $readmemb("D:/Risc v pipelined cpu/TEST_INSTRUCTIONS2.dat", uut.im.insts);
    end

    // ── Probe register file ──────────────────────────────────────
    wire [31:0] x1  = uut.registerfile.regs[1];
    wire [31:0] x2  = uut.registerfile.regs[2];
    wire [31:0] x3  = uut.registerfile.regs[3];
    wire [31:0] x4  = uut.registerfile.regs[4];
    wire [31:0] x5  = uut.registerfile.regs[5];
    wire [31:0] x6  = uut.registerfile.regs[6];
    wire [31:0] x7  = uut.registerfile.regs[7];
    wire [31:0] x8  = uut.registerfile.regs[8];
    wire [31:0] x9  = uut.registerfile.regs[9];
    wire [31:0] x10 = uut.registerfile.regs[10];
    wire [31:0] x11 = uut.registerfile.regs[11];

    // ── Reconstruct 32-bit word from byte-wide data memory ───────
    wire [31:0] dmem_word0 = { uut.dm.mem[3],
                                uut.dm.mem[2],
                                uut.dm.mem[1],
                                uut.dm.mem[0] };

    integer pass_count;
    integer fail_count;

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

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("\n=== TEST PROGRAM 2 (TEST_INSTRUCTIONS2.dat) ===");
        $display("PC= 0 : addi x1, x0, 5      -> x1 = 5");
        $display("PC= 4 : addi x2, x0, 3      -> x2 = 3");
        $display("PC= 8 : add  x3, x1, x2     -> x3 = 8   (EX forwarding)");
        $display("PC=12 : sub  x4, x1, x2     -> x4 = 2   (EX forwarding)");
        $display("PC=16 : sw   x3, 0(x0)      -> mem[0] = 8");
        $display("PC=20 : lw   x5, 0(x0)      -> x5 = 8   (load-use stall)");
        $display("PC=24 : addi x6, x0, 12     -> x6 = 12  (0b1100)");
        $display("PC=28 : addi x7, x0, 10     -> x7 = 10  (0b1010)");
        $display("PC=32 : and  x8, x6, x7     -> x8 = 8   (1100 & 1010)");
        $display("PC=36 : or   x9, x6, x7     -> x9 = 14  (1100 | 1010)");
        $display("PC=40 : beq  x3, x5, +8     -> branch taken, PC jumps to 56");
        $display("PC=44 : addi x10, x0, 99    -> FLUSHED, x10 must stay 0");
        $display("PC=48 : addi x10, x0, 77    -> FLUSHED, x10 must stay 0");
        $display("PC=52 : addi x11, x0, 55    -> x11 = 55 (branch target)");
        $display("================================================\n");

        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        repeat (50) @(posedge clk);
        #1;

        $display("=== REGISTER FILE CHECKS ===");
        check(x1,  32'd5,  "x1  (addi x0, 5)              ");
        check(x2,  32'd3,  "x2  (addi x0, 3)              ");
        check(x3,  32'd8,  "x3  (add  x1+x2, EX fwd)      ");
        check(x4,  32'd2,  "x4  (sub  x1-x2, EX fwd)      ");
        check(x5,  32'd8,  "x5  (lw   load-use stall)      ");
        check(x6,  32'd12, "x6  (addi x0, 12)             ");
        check(x7,  32'd10, "x7  (addi x0, 10)             ");
        check(x8,  32'd8,  "x8  (and  x6&x7 = 1000 = 8)   ");
        check(x9,  32'd14, "x9  (or   x6|x7 = 1110 = 14)  ");
        check(x10, 32'd0,  "x10 (MUST be 0 - flushed)      ");
        check(x11, 32'd55, "x11 (addi branch target = 55)  ");

        $display("\n=== DATA MEMORY CHECKS ===");
        check(dmem_word0, 32'd8, "dm[0] (sw x3, 0(x0) = 8)     ");

        $display("\n=== SUMMARY: %0d PASSED, %0d FAILED ===",
                  pass_count, fail_count);
        if (fail_count == 0)
            $display(">>> ALL TESTS PASSED - Pipeline working correctly!\n");
        else
            $display(">>> FAILURES DETECTED - Check waveform viewer.\n");

        $finish;
    end

endmodule
