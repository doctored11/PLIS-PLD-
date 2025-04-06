module counter_tb;

    reg clk;
    reg reset;
    reg start;
    reg noise_valid;

    wire [7:0] voltage;
    wire spi_start;
    wire store_en;
    wire [1:0] debug_window_count;
    wire [2:0] debug_state;

    counter uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .noise_valid(noise_valid),
        .voltage(voltage),
        .spi_start(spi_start),
        .store_en(store_en),
        .debug_window_count(debug_window_count),
        .debug_state(debug_state)
    );

    always #10 clk = ~clk;

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

    // колличесвто Шумов их ширина и паузы между ними
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
        clk = 0;
		 reset = 1;
			#20;
			reset = 0;
			#20;
			start = 1;
			#20;
			start = 0;

        noise_valid = 0;
			#10 
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

       

        
        #100000;
        generate_noise(10000); 
		  noise_valid = 0;

        #150000;

        generate_burst_noise(5, 20, 30);
		  #150000;

        generate_burst_noise(10, 20, 20);
		   #1000000;
        generate_burst_noise(20, 10, 10);
		   noise_valid = 0;
			#30000
			 generate_burst_noise(20, 1, 1);
		   noise_valid = 0;
			#30000
			 generate_burst_noise(20, 1, 10);
		   noise_valid = 0;
			#90000
			 generate_burst_noise(20, 5, 50);
		   noise_valid = 0;
		  #1000000;
		
			 generate_burst_noise(200, 10, 10);
		   noise_valid = 0;
			#300000
			 generate_burst_noise(20, 10, 10);
		   noise_valid = 0;
			#9000
			 generate_noise(50000);
			 #300000
			 generate_burst_noise(20, 10, 10);
		   noise_valid = 0;
        #150000;

 
        generate_noise(100000);
		   #3000
			noise_valid =1;
        #300000000;

        
        $finish;
    end

endmodule
