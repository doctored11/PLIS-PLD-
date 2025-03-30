module counter_tb;

    reg clk;
    reg reset;
    reg start;
    reg noise_valid;
    wire [7:0] voltage;
    wire spi_start;
    wire store_en;

    counter uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .noise_valid(noise_valid),
        .voltage(voltage),
        .spi_start(spi_start),
        .store_en(store_en)
    );

    // 50 МГц
    always #10 clk = ~clk;  // Период 20 нс (50 МГц)

    initial begin
      
        clk = 0;
        reset = 1;
        start = 0;
        noise_valid = 0;

        
        $dumpfile("counter.vcd"); //для сохранения тестиков
        $dumpvars(0, counter_tb);

        #100 reset = 0;  
        #100 start = 1;  
        #100 start = 0;

        // имитация наличия/отсутствия шумов с внешнего фотодиода
        #10000000; 
		   noise_valid = 1; 
        #115000;  
        noise_valid = 0;
        #115000;
		   noise_valid = 1;
			 #15000;
		   noise_valid = 0;
        #3000000;
     
        noise_valid = 1; 
        #115000;   
        noise_valid = 0;
        #115000;
		   noise_valid = 1;
        #115000;
		   noise_valid = 0;
        #225000; 
		  noise_valid = 1;
        #15000;
		   noise_valid = 0;
        #115000;
		   noise_valid = 0;
        #115000;
		   noise_valid = 1;
        #115000;
		   noise_valid = 0;
        #115000;
		   noise_valid = 1;
        #115000;
		  
        noise_valid = 1;
        #115000;
        noise_valid = 1; 
		  
		      #115000;
		   noise_valid = 0;
			 #5000;
			  noise_valid = 1;
        #225000;
        
        
        #2500000;
		  
		   reset = 1;
			#100 reset = 0;  
        #100 start = 1;
		    #100 start = 0;
		  noise_valid = 0; 
		   #3000000; 
		   noise_valid = 1; 
        #115000;   
        noise_valid = 0;
        #115000;
		   noise_valid = 1;
			 #15000;
		   noise_valid = 0;
        #500000;
        
       
        noise_valid = 1; 
        #15000;  
        noise_valid = 0;
        #15000;
		   noise_valid = 1;
        #15000;
		   noise_valid = 0;
        #5000; 
		  noise_valid = 1;
        #10000;
		   noise_valid = 0;
        #500;
		   noise_valid = 1;
       
		  
        #10000000;
        
        $finish; 
    end

  
    initial begin
        $monitor("Time = %t ns | State = %d | Voltage = %d | Noise = %b | Count = %d", 
                 $time, uut.state, voltage, noise_valid, uut.noise_check_count);
    end

endmodule