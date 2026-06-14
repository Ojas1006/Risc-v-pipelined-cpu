module instruction_memory #(
    parameter MEM_FILE = "D:/Risc v pipelined cpu/dat_files/TEST_BRANCH.dat"
)(
    input  [31:0] readAddr,
    output [31:0] inst
);
 
    reg [7:0] insts [0:127];
 
    assign inst = (readAddr >= 128) ? 32'b0 : {insts[readAddr], insts[readAddr + 1], insts[readAddr + 2], insts[readAddr + 3]};
 
    integer i;
    initial begin
        for (i = 0; i < 128; i = i + 1)
            insts[i] = 8'b0;
        $readmemb(MEM_FILE, insts);
    end
 
endmodule
