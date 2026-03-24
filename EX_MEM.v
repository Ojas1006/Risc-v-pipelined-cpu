module EX_MEM(
    input clk,
    input rst,
    input flush,
    input [31:0] alu_result_in, //from alu
    input zero_in, //from alu
    input [31:0] writedata_in, //from register file
    input [4:0] rd_in, //passed all the way so register knows where to write back in later stages
    input [31:0] adder_in, //branch target address from EX adder
    input branch, mem_read, mem_write, reg_write, mem_to_reg, 
    input addermuxselect_in, //used to select between the adder output and the ALU output for the branch decision mux in the IF stage
    output reg [31:0] alu_result_out,
    output reg zero_out,
    output reg [31:0] writedata_out,
    output reg [4:0] rd_out,
    output reg [31:0] adder_out,
    output reg branch_out, mem_read_out, mem_write_out, reg_write_out, mem_to_reg_out,
    output reg addermuxselect_out //used to select between the adder output and the ALU output for the branch decision mux in the IF stage
);

always @(posedge clk) begin
    if (rst == 1'b1 || flush == 1'b1) begin
        alu_result_out <= 32'b0;
        zero_out <= 1'b0;
        writedata_out <= 32'b0;
        rd_out <= 5'b0;
        adder_out <= 32'b0;
        branch_out <= 1'b0;
        mem_read_out <= 1'b0;
        mem_write_out <= 1'b0;
        reg_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
        addermuxselect_out <= 1'b0;
    end

    else begin
        alu_result_out <= alu_result_in;
        zero_out <= zero_in;
        writedata_out <= writedata_in;
        rd_out <= rd_in;
        adder_out <= adder_in;
        branch_out <= branch;
        mem_read_out <= mem_read;
        mem_write_out <= mem_write;
        reg_write_out <= reg_write;
        mem_to_reg_out <= mem_to_reg;
        addermuxselect_out <= addermuxselect_in;
    end
end
endmodule