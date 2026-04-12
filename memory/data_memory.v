module data_memory(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);

reg [7:0] mem[127:0];

// Synthesis-safe initialization using block RAM init
initial $readmemb("TEST_JAL.dat", mem);

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
    read_data = 32'b0;  // default — prevents latch
    if (mem_read) begin
        read_data[7:0]   = mem[address[6:0]];
        read_data[15:8]  = mem[address[6:0] + 1];
        read_data[23:16] = mem[address[6:0] + 2];
        read_data[31:24] = mem[address[6:0] + 3];
    end
end

endmodule