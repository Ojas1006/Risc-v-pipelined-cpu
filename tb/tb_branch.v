`timescale 1ns/1ps

// =============================================================================
// tb_branch.v — Branch instruction testbench (BEQ/BNE taken and not-taken)
//
// Test program layout (instruction_memory loads TEST_BRANCH.dat):
//   PC= 0: addi x1,x0,10        x1=10
//   PC= 4: addi x2,x0,10        x2=10
//   PC= 8: beq  x1,x2,+8        TAKEN  → PC=16   (x5 squashed, stays 0)
//   PC=12: addi x5,x0,55        SQUASHED
//   PC=16: addi x3,x0,99        x3=99  (beq-taken proof)
//   PC=20: addi x2,x0,5         x2=5
//   PC=24: bne  x1,x2,+12       TAKEN  → PC=36   (x6@PC28 squashed)
//   PC=28: addi x6,x0,66        SQUASHED
//   PC=32: addi x6,x0,22        runs → x6=22
//   PC=36: addi x4,x0,77        x4=77  (bne-taken proof)
//   PC=40: beq  x1,x3,+100      NOT TAKEN (10≠99)
//   PC=44: addi x7,x0,33        x7=33  (beq-not-taken proof)
//   PC=48: addi x2,x0,10        x2=10
//   PC=52: bne  x1,x2,+100      NOT TAKEN (10==10)
//   PC=56: addi x8,x0,44        x8=44  (bne-not-taken proof)
//   PC=60-76: nop × 5           pipeline drain
//
// Expected final register file state:
//   x1=10, x2=10, x3=99, x4=77, x5=0, x6=22, x7=33, x8=44
// =============================================================================

module tb_branch;
    reg         clk;
    reg         reset;
    wire [31:0] pc_out_port;
    wire        regwrite_port;
    wire [31:0] debug_data_out;

    RISC_V_pipeline dut (
        .clk          (clk),
        .reset        (reset),
        .pc_out_port  (pc_out_port),
        .regwrite_port(regwrite_port),
        .debug_data_out(debug_data_out)
    );

    // -------------------------------------------------------------------------
    // Clock: 10 ns period
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    function [31:0] read_reg;
        input [4:0] rn;
        begin
            read_reg = dut.registerfile.regs[rn];
        end
    endfunction

    integer pass_count;
    integer fail_count;

    task check;
        input [31:0] actual;
        input [31:0] expected;
        input [8*40:1] test_name;
        begin
            if (actual === expected) begin
                $display("  PASS  %0s  (got %0d)", test_name, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL  %0s  expected=%0d  got=%0d",
                         test_name, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Simulation
    
    initial begin
        pass_count = 0;
        fail_count = 0;

        // Assert reset for 2 cycles
        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        // $readmemb race-condition guard
        #1;

        // 20 instructions + 5-stage pipeline depth = 25 cycles minimum.
        // 30 gives comfortable margin.
        repeat (30) @(posedge clk);
        #1;  // sample just after rising edge so WB has settled

        // =====================================================================
        $display("");
        $display("=============================================================");
        $display("  Branch Instruction Test Results");
        $display("=============================================================");

        // --- Test 1: BEQ taken (x1==x2 at PC=8, branch to PC=16) ------------
        $display("");
        $display("--- Test 1: BEQ taken ---");
        check(read_reg(3), 32'd99, "x3==99  target instruction ran    ");
        check(read_reg(5), 32'd0,  "x5==0   PC=12 was squashed        ");

        // --- Test 2: BNE taken (x1=10 != x2=5 at PC=24, branch to PC=36) ----
        $display("");
        $display("--- Test 2: BNE taken ---");
        check(read_reg(4), 32'd77, "x4==77  target instruction ran    ");
        // x6=22 (PC=32) proves PC=28 (x6=66) was squashed and PC=32 ran after flush
        check(read_reg(6), 32'd22, "x6==22  PC=28 squashed, PC=32 ran ");

        // --- Test 3: BEQ not-taken (x1=10 != x3=99 at PC=40) ----------------
        $display("");
        $display("--- Test 3: BEQ not-taken ---");
        check(read_reg(7), 32'd33, "x7==33  sequential fetch ran      ");

        // --- Test 4: BNE not-taken (x1=10 == x2=10 at PC=52) ----------------
        $display("");
        $display("--- Test 4: BNE not-taken ---");
        check(read_reg(8), 32'd44, "x8==44  sequential fetch ran      ");

        // --- Sanity: setup registers should be unchanged ---------------------
        $display("");
        $display("--- Sanity checks ---");
        check(read_reg(1), 32'd10, "x1==10  never overwritten         ");
        check(read_reg(2), 32'd10, "x2==10  restored at PC=48         ");

        // =====================================================================
        $display("");
        $display("=============================================================");
        if (fail_count == 0)
            $display("  ALL TESTS PASSED (%0d/%0d)", pass_count, pass_count);
        else
            $display("  %0d PASSED  %0d FAILED", pass_count, fail_count);
        $display("=============================================================");
        $display("");

        $display("x6 = %0d", dut.registerfile.regs[6]);
        $display("x4 = %0d", dut.registerfile.regs[4]);
        $display("x3 = %0d", dut.registerfile.regs[3]);

        $display("PC=%0d flush=%b/%b stall=%b x6=%0d",
        dut.pc_out_port,
        dut.flush_ifid,
        dut.flush_idex,
        dut.flush_exmem,
        dut.stall,
        dut.registerfile.regs[6]);

        $display("  IF/ID_inst=%h  ID/EX_rs2=%0d",
        dut.if_id.inst,
        dut.id_ex.rs2_out);

        $finish;
        #100;
        $stop;
    end
end

endmodule
