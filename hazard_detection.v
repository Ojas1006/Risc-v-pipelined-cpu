module hazard_detection(
    input [31:0] instruction, //instruction from IF_ID stage
    input mem_read_ex, //checks if instruction in EX stage is lw
    input [4:0] rd, //destination register of instruction in EX stage
    output reg stall
);

always @(*) begin
    // if the instruction in EX stage is lw and the destination register of that lw is the same as either source register of the instruction in ID stage, then we have a hazard and need to stall
    if (mem_read_ex == 1'b1 && (rd == instruction[19:15] || rd == instruction[24:20]))begin
        stall = 1'b1;
    end
    else begin
        stall = 1'b0;
    end
end
endmodule