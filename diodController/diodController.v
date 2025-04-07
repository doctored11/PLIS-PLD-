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
    output varu,
    output [1:0] debug_window_count,
    output [2:0] debug_state   
);

    wire [7:0] voltage;
    wire spi_start_int;
    wire varu_int;
    wire [1:0] debug_window_count_internal;
    wire [2:0] debug_state_internal; 

	 
	 //?todo - отказаться от отдельного reset (сбрасывать по старту)
	 //todo - старт к счетчику по блоку SPI при MISO =1
    counter cnt (
        .clk(clk),
        .reset(reset),
        .start(start),
        .noise_valid(noise_valid),
		  
        .voltage(voltage),
        .spi_start(spi_start_int),
        .varu(varu_int),
        .debug_window_count(debug_window_count_internal),
        .debug_state(debug_state_internal)  
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
    assign varu = varu_int;
    assign debug_window_count = debug_window_count_internal;
    assign debug_state = debug_state_internal; 
endmodule
