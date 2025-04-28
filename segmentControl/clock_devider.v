module clock_divider
 (
    input  wire clk_in,
    input  wire [31:0] divide_by,    
    output reg  clk_out    
);

    reg [31:0] counter = 0; 

    always @(posedge clk_in) begin
        if (counter == (divide_by - 1)) begin //в Nраз делим
            counter <= 0;
            clk_out <= ~clk_out; 
        end else begin
            counter <= counter + 1;
        end
    end

endmodule
