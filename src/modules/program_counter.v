module program_counter ( 
    input [31:0] pc_in,
    input clk,
    input reset,
    input stall,
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'b0;
        end
        else if (!stall) begin
            pc_out <= pc_in;
        end
    end
    
endmodule