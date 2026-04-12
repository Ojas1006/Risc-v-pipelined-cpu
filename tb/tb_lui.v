`timescale 1ns / 1ps

module tb_lui;

    reg clk;
    reg reset;

    initial clk = 0;
    always #5 clk = ~clk;

    RISC_V_pipeline uut (
        .clk(clk),
        .reset(reset)
    );

    wire [31:0] x1 = uut.registerfile.regs[1];
    wire [31:0] x2 = uut.registerfile.regs[2];
    wire [31:0] x3 = uut.registerfile.regs[3];

    integer pass_count;
    integer fail_count;

    task check;
        input [63:0]  actual;
        input [63:0]  expected;
        input [127:0] label;
        begin
            if (actual === expected) begin
                $display("  PASS: %s = 0x%08X", label, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: %s -- got 0x%08X, expected 0x%08X",
                          label, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("lui_test.vcd");
        $dumpvars(0, tb_lui);

        pass_count = 0;
        fail_count = 0;

        $display("\n=== LUI TEST (TEST_LUI.dat) ===");
        $display("PC= 0 : LUI x1, 0xABCDE  -> x1 = 0xABCDE000");
        $display("PC= 4 : LUI x2, 1        -> x2 = 0x00001000");
        $display("PC= 8 : ADD x3, x1, x2   -> x3 = 0xABCDF000");
        $display("================================\n");

        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        repeat(20) @(posedge clk);
        #1;

        $display("=== REGISTER FILE CHECKS ===");
        check(x1, 32'hABCDE000, "x1 (LUI 0xABCDE)          ");
        check(x2, 32'h00001000, "x2 (LUI 1)                ");
        check(x3, 32'hABCDF000, "x3 (ADD x1+x2, MEM-EX fwd)");

        $display("\n=== SUMMARY: %0d PASSED, %0d FAILED ===",
                  pass_count, fail_count);
        if (fail_count == 0)
            $display(">>> ALL LUI TESTS PASSED\n");
        else
            $display(">>> FAILURES DETECTED\n");

        $finish;
        #100;
        $stop;
    end

endmodule