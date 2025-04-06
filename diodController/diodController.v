module diodController(
    input clk,           
    input reset,       
    input start,         
    input noise_valid,   

    output spi_mosi,     
    output spi_clk,      
    output spi_ss,       
    output [7:0] debug_voltage,  
    output spi_start,   
    output store_en ,
	output [1:0] debug_window_count
	 
);

   
    wire [7:0] voltage;
    wire spi_start_int;
    wire store_en_int;

    wire [1:0] debug_window_count_internal;


  
    counter cnt (
        .clk(clk),
        .reset(reset),
        .start(start),
        .noise_valid(noise_valid),
        .voltage(voltage),
        .spi_start(spi_start_int),
        .store_en(store_en_int),
		  .debug_window_count(debug_window_count_internal)

    );

    spi_module spi (
        .clk(clk),
        .reset(reset),  
        .start(spi_start_int),
        .data(voltage),
        .MOSI(spi_mosi), 
        .SCLK(spi_clk),  
        .SS(spi_ss)      
    );

    assign debug_voltage = voltage;
    assign spi_start = spi_start_int;
    assign store_en = store_en_int;
	 assign debug_window_count = debug_window_count_internal;


endmodule
