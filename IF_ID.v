module IF_ID(
    input clk,
    input rst,
    input flush,
    input [31:0] instruction,
    input [31:0] pc,
    input inst_write,
    output reg [31:0] inst,
    output reg [31:0] pc_out
);

always @(posedge clk)  begin
    if (rst == 1'b1 || flush == 1'b1) begin
        inst <= 32'b0;
        pc_out <= 32'b0;
    end

    else if (inst_write == 1'b0) begin
        inst <= instruction;
        pc_out <= pc;
    end
end
endmodule