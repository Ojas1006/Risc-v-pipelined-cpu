module pipeline_flush(
    input branch,
    input jump,
    input zero,
    output reg flush
);

initial begin
    flush = 1'b0;
end

always @(*) begin
    if ((branch & zero)  == 1'b1 || jump == 1'b1) begin
        flush = 1'b1;
    end 
    
    else begin
        flush = 1'b0;
    end
end
endmodule