module decimal_counter (
    input wire clk,           //сюда завести частоту ниже частоты обновления ирндикатора 
    input wire reset,         
    output reg [15:0] count   
);

 
		initial begin
         count =  16'b0000_0000_0000_0000;  
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 16'b0000_0000_0000_0000;  
        end else begin
            if (count < 16'd9999) begin
                count <= count + 1;  
            end else begin
                count <= 16'b0000_0000_0000_0000;  
            end
        end
    end
endmodule
