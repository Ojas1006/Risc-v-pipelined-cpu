module MEM_WB(
    input clk,
    input rst,
    input [31:0] alu_result_in, //from alu
    input [31:0] mem_data_in, //from data memory
    input [4:0] rd_in, //passed all the way so register knows where to write back in later stages
    input reg_write_in, mem_to_reg_in,
    output reg [31:0] alu_result_out,
    output reg [31:0] mem_data_out,
    output reg [4:0] rd_out,
    output reg reg_write_out, mem_to_reg_out
);

always @(posedge clk) begin
    if (rst == 1'b1) begin
        alu_result_out <= 32'b0;
        mem_data_out <= 32'b0;
        rd_out <= 5'b0;
        reg_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
    end

    else begin
        alu_result_out <= alu_result_in;
        mem_data_out <= mem_data_in;
        rd_out <= rd_in;
        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;
    end
end
endmodule