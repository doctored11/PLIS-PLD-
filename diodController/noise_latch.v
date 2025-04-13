module noise_latch (
    input  wire clk,
    input  wire reset,
    input  wire noise_in,
    output wire noise_out
);

    reg clear_flag;  
    reg latched;     

    always @(negedge clk or posedge reset) begin
        if (reset)
            clear_flag <= 1'b1;      
        else if (~noise_in)
            clear_flag <= 1'b1;       
        else
            clear_flag <= 1'b0;       
    end

    always @(*) begin
        if (reset)
            latched = 1'b0;
        else if (noise_in)
            latched = 1'b1;          
        else if (clear_flag)
            latched = 1'b0;           
    end

    assign noise_out = latched;

endmodule
