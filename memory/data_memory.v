module data_memory #(
    parameter MEM_FILE = "D:/Risc v pipelined cpu/dat_files/TEST_JAL.dat"
)(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);
 
reg [7:0] mem [0:127];
 
integer i;
initial begin
    for (i = 0; i < 128; i = i + 1)
        mem[i] = 8'b0;
    $readmemb(MEM_FILE, mem);
end
 
// Clocked write
always @(posedge clk) begin
    if (mem_write) begin
        mem[address[6:0]]     <= write_data[7:0];
        mem[address[6:0] + 1] <= write_data[15:8];
        mem[address[6:0] + 2] <= write_data[23:16];
        mem[address[6:0] + 3] <= write_data[31:24];
    end
end
 
// Combinational read with default assignment
always @(*) begin
    read_data = 32'b0;
    if (mem_read) begin
        read_data[7:0]   = mem[address[6:0]];
        read_data[15:8]  = mem[address[6:0] + 1];
        read_data[23:16] = mem[address[6:0] + 2];
        read_data[31:24] = mem[address[6:0] + 3];
    end
end
 
endmodule