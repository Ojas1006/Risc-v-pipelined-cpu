module pipeline_flush(
    input branch,
    output reg flush
);

initial begin
    flush = 1'b0;
end

always @(*) begin
    if (branch == 1'b1) begin
        flush = 1'b1;
    end 
    
    else begin
        flush = 1'b0;
    end
end
endmodule