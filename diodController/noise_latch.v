module noise_latch (
    input  wire clk,
    input  wire reset,
    input  wire noise_in,
    output reg  noise_out
);

    reg toggle_flag; 
    reg sync0, sync1; 

    always @(posedge noise_in or posedge reset) begin
        if (reset)
            toggle_flag <= 1'b0;
        else
            toggle_flag <= ~toggle_flag;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sync0     <= 1'b0;
            sync1     <= 1'b0;
            noise_out <= 1'b0;
        end else begin
            sync0     <= toggle_flag;
            sync1     <= sync0;
            
            noise_out <= sync0 ^ sync1;
        end
    end

endmodule
