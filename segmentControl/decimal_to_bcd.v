module decimal_to_bcd (
    input wire [15:0] decimal,     
    output reg [3:0] bcd_0,        
    output reg [3:0] bcd_1,        
    output reg [3:0] bcd_2,        
    output reg [3:0] bcd_3         
);

    always @(*) begin       
        bcd_3 = decimal / 1000;  
        bcd_2 = (decimal % 1000) / 100;  
        bcd_1 = (decimal % 100) / 10;    
        bcd_0 = decimal % 10;            
    end
endmodule
