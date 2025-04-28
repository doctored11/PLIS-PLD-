//глобальный модуль! -он пока для искусственной генерации чисел - основной код segmentControl

module display_controller (
    input wire clk,          
    input wire reset,        
    output wire [7:0] segment_outputs, // линии на одном индикаторе
    output wire [3:0] anode_select     // выбор ячейки
);

    wire [15:0] count;    // для счетчика 
    wire [3:0] bcd_0, bcd_1, bcd_2, bcd_3;  // BCD цифры (хранение в нужном формате )
	 
	 wire clk_segment;
	 
	 clock_divider clk_segment_divider  (
			 .clk_in(clk),
			 .divide_by(100),
			 .clk_out(clk_segment)
		);
		
	wire clk_digit;
	 clock_divider clk_digit_divider (
			 .clk_in(clk_segment),
			 .divide_by(100000),
			 .clk_out(clk_digit)
		);

    // растущий счетчик 
    decimal_counter counter_inst (
        .clk(clk_digit),
        .reset(reset),
        .count(count)
    );

    // преобразование десят числа в BCD
    decimal_to_bcd bcd_inst (
        .decimal(count),
        .bcd_0(bcd_0),
        .bcd_1(bcd_1),
        .bcd_2(bcd_2),
        .bcd_3(bcd_3)
    );

    // сам контроллер индикации
    segmentControl segmentControl_inst (
        .clk(clk_segment),
        .bcd_input({bcd_3, bcd_2, bcd_1, bcd_0}),  
        .segment_outputs(segment_outputs),
        .anode_select(anode_select)
    );

endmodule
