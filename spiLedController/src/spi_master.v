//реализация spi
	//т.е
	/*  
	4 линии:
		-MISO - пока пустая - вход вроде как не нужен (просто оставим)
		-MoSI - выход последовательный (по биту в тик)
		-SCLK(CLK) - линия тактирования  
		-SS - подаем 0 когда хотим передавать сигнал по MosI

	*/
	//пока работает но не очень - мб тесты(на бит не сходится)
module spi_master(
    input clk,        
    input reset,       
    input start,       
    input [7:0] data,  
    output reg SCLK = 0,
    output reg MOSI = 0,
    output reg SS = 1   
);
    parameter CLKS_PER_HALF_BIT = 25;
    
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
            bit_index <= 7;
            tx_active <= 0;
        end else begin
        
            if (start && !tx_active) begin
                tx_active <= 1;
                SS <= 0;          
                tx_data <= data;  
                bit_index <= 7;   
                clk_counter <= 0;
                MOSI <= data[7];  
            end 
            else if (tx_active) begin
                clk_counter <= clk_counter + 1;
                
                
                if (clk_counter == CLKS_PER_HALF_BIT - 1) begin
                    SCLK <= 1;
                end 
                else if (clk_counter == (CLKS_PER_HALF_BIT * 2) - 1) begin
                    SCLK <= 0;
                    clk_counter <= 0;
                    
                    
                    if (bit_index > 0) begin
                        bit_index <= bit_index - 1;
                        MOSI <= tx_data[bit_index - 1];
                    end else begin
                       
                        tx_active <= 0;
                        SS <= 1;
                    end
                end
            end
        end
    end
endmodule
