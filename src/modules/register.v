module register(
    input clk,
    input rst,
    input regwrite,
    input [4:0] readreg1,
    input[4:0] readreg2,
    input[4:0] writereg,
    input[31:0] writedata,
    output [31:0] readdata1,
    output [31:0] readdata2
);

reg [31:0] regs[0:31];   //creates 32 registers of 32 bits each
assign readdata1 = (readreg1 == 5'b0) ? 32'b0 :
                   (regwrite && writereg == readreg1) ? writedata : 
                   regs[readreg1];

assign readdata2 = (readreg2 == 5'b0) ? 32'b0 :
                   (regwrite && writereg == readreg2) ? writedata :  
                   regs[readreg2];
always @(posedge clk) begin
    if(rst) begin
        regs[0] <= 0; regs[1] <= 0; regs[2] <= 0; regs[3] <= 0; 
        regs[4] <= 0; regs[5] <= 0; regs[6] <= 0; regs[7] <= 0; 
        regs[8] <= 0; regs[9] <= 0; regs[10] <= 0; regs[11] <= 0; 
        regs[12] <= 0; regs[13] <= 0; regs[14] <= 0; regs[15] <= 0; 
        regs[16] <= 0; regs[17] <= 0; regs[18] <= 0; regs[19] <= 0; 
        regs[20] <= 0; regs[21] <= 0; regs[22] <= 0; regs[23] <= 0; 
        regs[24] <= 0; regs[25] <= 0; regs[26] <= 0; regs[27] <= 0; 
        regs[28] <= 0; regs[29] <= 0; regs[30] <= 0; regs[31] <= 0;
    end

    else if(regwrite) begin
        regs[writereg] <= (writereg == 0) ? 0: writedata;
    end
end
endmodule