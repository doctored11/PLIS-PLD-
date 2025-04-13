`timescale 1ns/1ps

module diodController_v1_tb;

    reg clk = 0;
    reg reset = 1;
    reg start = 0;
    reg noise_valid = 0;

    wire spi_mosi;
    wire spi_clk;
    wire spi_ss;
    wire [7:0] debug_voltage;
    wire spi_start;
    wire varu;
    wire [1:0] debug_window_count;
    wire [2:0] debug_state;

    diodController uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .noise_valid(noise_valid),
        .spi_mosi(spi_mosi),
        .spi_clk(spi_clk),
        .spi_ss(spi_ss),
        .debug_voltage(debug_voltage),
        .spi_start(spi_start),
        .varu(varu),
        .debug_window_count(debug_window_count),
        .debug_state(debug_state),
		    .debug_noise_valid_filter(debug_noise_valid_filter)
    );

    //always #10 clk = ~clk;//50Мгц - константы выставлены под эту частоту Todo - потом поменять для размера окон по ТЗ
	 always #5  clk = ~clk;//ошибся -тест делал для этой чатсоты (пограничные состояния и тд)

    // функция Шума в течении времени
    task generate_noise(input integer duration_ns);
        integer i;
        integer pulses;
        begin
            pulses = duration_ns / 20;
            for (i = 0; i < pulses; i = i + 1) begin
                noise_valid = 1;
                #5;
                noise_valid = 0;
                #15;
            end
        end
    endtask

    // количество Шумов, их ширина и паузы между ними
    task generate_burst_noise(
        input integer count,
        input integer pulse_width_ns,
        input integer gap_ns
    );
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                noise_valid = 1;
                #(pulse_width_ns);
                noise_valid = 0;
                #(gap_ns);
            end
        end
    endtask

    initial begin
        $display("Start simulation");
        $dumpfile("diodController_tb.vcd");
        $dumpvars(0, diodController_v1_tb);
		  $dumpvars(1, diodController_v1_tb.uut.noise_valid_filter); 

        reset = 1;
        #20;
        reset = 0;
        #20;
        start = 1;
        #20;
        start = 0;

        noise_valid = 0;
        #10;

        #100000;
        generate_noise(10000); 
        noise_valid = 0;

        #150000;
        generate_burst_noise(5, 20, 30);
        #151500;

        generate_burst_noise(10, 20, 20);
        #1000000;
        generate_burst_noise(20, 10, 10);
        noise_valid = 0;
        #30000;
		  
        generate_burst_noise(40, 5, 10);
		  #10;
		  noise_valid = 0;
		  #3000;
        generate_burst_noise(20, 1, 1);
        noise_valid = 0;
        #30000;
        generate_burst_noise(20, 1, 10);
        noise_valid = 0;
        #90500;
        generate_burst_noise(20, 5, 50);
        noise_valid = 0;
        #1000000;

        generate_burst_noise(200, 10, 10);
        noise_valid = 0;
        #305000;
        generate_burst_noise(20, 10, 10);
        noise_valid = 0;
        #9000;
        generate_noise(50000);
        #300000;
        generate_burst_noise(20, 10, 10);
        noise_valid = 0;
        #150000;

        generate_noise(1000000);
		  noise_valid = 0;
        #305050;
		  #102
		  generate_noise(1000000);
        noise_valid = 1;
        #30000;
		  
		  //второй "круг"
		 reset = 1;
        #20;
        reset = 0;
        #20;
        start = 1;
        #20;
        start = 0;
		  
		  noise_valid = 0;
        #3000;
		  
        generate_burst_noise(40, 5, 10);
		  #10;
		  noise_valid = 0;
		  #3000;
        generate_burst_noise(20, 1, 1);
        noise_valid = 0;
        #30000;
        generate_burst_noise(20, 1, 10);
        noise_valid = 0;
        #90500;
        generate_burst_noise(20, 5, 50);
        noise_valid = 0;
        #10000;

        generate_burst_noise(200, 10, 10);
        noise_valid = 0;
        #305000;
        generate_burst_noise(20, 10, 10);
        noise_valid = 0;
        #9000;
        generate_noise(50000);
        #300000;

        $display("End simulation");
        $finish;
    end

endmodule
