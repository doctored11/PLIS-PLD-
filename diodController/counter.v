module counter(
    input         clk,           
    input         reset,         
    input         start,        
    input         noise_valid,   
    output reg [7:0] voltage,    
    output reg    spi_start,     
    output reg    store_en      
);

// время в константах в МГц и микросеках
parameter real DELAY_380mcrs = 380.0; // 380мкс (mcrs)
parameter real DELAY_115mcrs = 115.0;
parameter real DELAY_5mcrs   = 5.0;   
parameter real CLK_FREQ_MHZ = 50.0; // частота = 50Мгц


localparam integer DELAY_380_TICKS = (DELAY_380mcrs * CLK_FREQ_MHZ);
localparam integer DELAY_115_TICKS = (DELAY_115mcrs * CLK_FREQ_MHZ);
localparam integer DELAY_5_TICKS   = (DELAY_5mcrs * CLK_FREQ_MHZ);


parameter IDLE       = 0;
parameter INIT       = 1;
parameter INCREASE   = 2;
parameter PAUSE      = 3;
parameter CHECK_NOISE= 4;
parameter CONFIRM    = 5;
parameter CALIBRATE  = 6;

reg [2:0] state;
reg [15:0] timer;
reg [1:0] noise_check_count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        voltage <= 8'h00;
        timer <= 0;
        noise_check_count <= 0;
        spi_start <= 0;
        store_en <= 0;
    end else begin
        store_en <= 0; 
        spi_start <= 0;
		  
        case(state)
            IDLE: begin
                if (start) begin
                    state <= INIT;
                    voltage <= 8'h00;
                end
            end
                
           INIT: begin 
				 spi_start <= 1;
				 timer <= 0;
				 if (timer >= 3) begin  // задерживаем для сборки с spi --?
					  state <= INCREASE;
					  spi_start <= 0;
				  end else begin
					  timer <= timer + 1;
				  end
			end
                
            INCREASE: begin 
                spi_start <= 0;
                if (timer >= DELAY_380_TICKS - 1) begin
                    voltage <= voltage + 1;
                    timer <= 0;
                    state <= PAUSE;
						  
						  spi_start <= 1; // тут еще подумать todo
                 end else begin
                    timer <= timer + 1;
                end
            end
                
            PAUSE: begin 
                if (timer >= DELAY_5_TICKS - 1) begin
                    timer <= 0;
                    state <= CHECK_NOISE;
                end else begin
                    timer <= timer + 1;
                end
            end
                
            CHECK_NOISE: begin 
                if (timer >= DELAY_115_TICKS - 1) begin
                    timer <= 0;
                    if (noise_valid) begin
                        noise_check_count <= noise_check_count + 1; 
                        if (noise_check_count >= 3) begin
                            store_en <= 1;
                            state <= CALIBRATE;
									 
									 spi_start <= 1;
                        end else begin
                            state <= INCREASE; 
                        end
                    end else begin
                        noise_check_count <= 0; 
                        state <= INCREASE;
                    end
                end else begin
                    timer <= timer + 1;
                end
            end
            
            CALIBRATE: begin
                if (reset) begin
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule