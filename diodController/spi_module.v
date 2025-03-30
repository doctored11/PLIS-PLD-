module spi_module(
    input clk,         
    input reset,       
    input start,       
    input [7:0] data,  
    output reg SCLK = 0,  
    output reg MOSI = 0,  
    output reg SS = 1     
);
    parameter CLKS_PER_HALF_BIT = 2;  // полупериод SCLK = 2 тика clk || (T=4)
    
    reg [7:0] clk_counter = 0;
    reg [2:0] bit_index = 0;  
    reg [7:0] tx_data;
    reg tx_active = 0;

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            
            SCLK <= 0;
            MOSI <= 0;
            SS <= 1;
            clk_counter <= 0;
            bit_index <= 0;
            tx_active <= 0;
       
        end else begin
            if (start && !tx_active) begin
                // начало передачи 
                tx_active <= 1;
                SS <= 0;         
                tx_data <= data;  
                bit_index <= 7;   
                clk_counter <= 0;
                MOSI <= data[7];  
                SCLK <= 0;       
               
            end 
            else if (tx_active) begin
                clk_counter <= clk_counter + 1;
                
                if (clk_counter == CLKS_PER_HALF_BIT - 1) begin
                    //переключение `фазы SCLK
                    SCLK <= ~SCLK;
                    clk_counter <= 0;
                    
                    if (SCLK) begin
       
                        if (bit_index > 0) begin
                            bit_index <= bit_index - 1;
                            MOSI <= tx_data[bit_index - 1];
                        end else begin
                            // все биты переданы
                            tx_active <= 0;
                            SS <= 1;    
                            MOSI <= 0;
                        end
                    end
                end
            end
        end
    end
endmodule