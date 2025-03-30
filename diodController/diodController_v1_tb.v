module diodController_v1_tb;

	//временный тестовый файл - проверяет связку каунтера и spi (и все)
    reg clk;
    reg reset;
    reg start;
    reg noise_valid;
    wire spi_mosi;
    wire spi_clk;
    wire spi_ss;

    // Выводы сигналов для мониторинга
    wire [7:0] voltage;
    wire spi_start;
    wire store_en;

   diodController uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .noise_valid(noise_valid),
    .spi_mosi(spi_mosi),
    .spi_clk(spi_clk),
    .spi_ss(spi_ss),
    .debug_voltage(voltage),
    .spi_start(spi_start),  
    .store_en(store_en)
);


    always #10 clk = ~clk;

    reg [7:0] received_data;
    reg [3:0] bit_counter;

    initial begin
        
        clk = 0;
        reset = 1;
        start = 0;
        noise_valid = 0;
        
        $dumpfile("diodController.vcd");
        $dumpvars(0, diodController_v1_tb);
        
        #100 reset = 0;
        
        #100 start = 1;
        #100 start = 0;
        #2000000;

        #10000 noise_valid = 1;  
        #2000 noise_valid = 0;
		   #2000 noise_valid = 1;
			 #2000 noise_valid = 0;
		   #2000 noise_valid = 1;
			 #2000 noise_valid = 0;
		   #2000 noise_valid = 1;
		 #2000 noise_valid = 0;
		 #500000;
		    #10000 noise_valid = 1; 
        #2000 noise_valid = 0;
		   #2000 noise_valid = 1;
			#10000  noise_valid = 0;
			 noise_valid = 0;
			  #200000
		   #2000 noise_valid = 1;
			 #2000 noise_valid = 0;
		    noise_valid = 1;
			   #500000
		noise_valid = 0;
		 #50000000;
		  noise_valid = 1;
		 #50000000
		   
       
       
        
        
        
        
       
        $display("Testing complete.");
        $finish;
    end

   
    initial begin
        $monitor("Time = %t | SPI_SS = %b | SPI_CLK = %b | SPI_MOSI = %b | Noise = %b | Voltage = %h | SPI Start = %b | Store En = %b", 
                 $time, spi_ss, spi_clk, spi_mosi, noise_valid, voltage, spi_start, store_en);
    end
	 // todo проверить - тут мб ошибка (через 1 отобрадает выход MOSI - не критично)

    always @(negedge spi_ss) begin
        $display("Received data start. Time: %t", $time);
        received_data = 8'b0; 
        bit_counter = 7;        

     
        while (bit_counter >= 0) begin
            @(posedge spi_clk); 
            received_data[bit_counter] = spi_mosi; 
            $display("Received bit %d: %b", 7-bit_counter, spi_mosi);  
            bit_counter = bit_counter - 1; 
        end

        $display("Received data: %b (0x%h)", received_data, received_data);
    end

endmodule
