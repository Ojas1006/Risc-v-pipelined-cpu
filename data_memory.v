module data_memory(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);

reg[7:0] mem[127:0]; //128 bytes of memory
integer i;
initial begin
    for (i=0; i<128; i = i + 1)
        mem[i] = 8'b0;
    
end
always @(posedge clk) begin
        if (mem_write) begin
            mem[address] <= write_data[7:0];
            mem[address + 1] <= write_data[15:8];
            mem[address + 2] <= write_data[23:16];
            mem[address + 3] <= write_data[31:24];
        end
    end

always @(*) begin
    if (mem_read) begin
        read_data[7:0] = mem[address];
        read_data[15:8] = mem[address + 1];
        read_data[23:16] = mem[address + 2];
        read_data[31:24] = mem[address + 3];
    end
    else
        read_data = 32'b0;
end
endmodule
