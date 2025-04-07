module counter(
    input         clk,           
    input         reset,         
    input         start,    // переход от idle к init -- мб сделать внутренней переменной    
    input         noise_valid,   
    output reg [7:0] voltage,    
    output reg    spi_start,     
    output reg    varu,
    output [1:0] debug_window_count,
    output reg [2:0] debug_state
);


parameter real DELAY_380mcrs = 380.0; 
parameter real DELAY_115mcrs = 115.0;
parameter real DELAY_5mcrs   = 5.0;   
parameter real CLK_FREQ_MHZ = 50.0; 

localparam integer DELAY_380_TICKS = (DELAY_380mcrs * CLK_FREQ_MHZ);
localparam integer DELAY_115_TICKS = (DELAY_115mcrs * CLK_FREQ_MHZ);
localparam integer DELAY_5_TICKS   = (DELAY_5mcrs * CLK_FREQ_MHZ);

parameter IDLE       = 0;
parameter INIT       = 1;
parameter INCREASE   = 2;//010
parameter PAUSE      = 3;
parameter CHECK_NOISE = 4; //100
parameter CONFIRM    = 5;
parameter CALIBRATE  = 6;

reg [2:0] state;
reg [15:0] timer;
reg [1:0] noise_check_count;
reg [1:0] window_count;            
reg       noise_heard_in_window; 
reg prev_noise_valid;
reg [15:0] global_noise_count;
reg prev_noise_heard_in_window;  

assign debug_window_count = window_count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        voltage <= 8'h00;
        timer <= 0;
        noise_check_count <= 0;
        spi_start <= 0;
    
        noise_heard_in_window <= 0;
        window_count <= 0;
        prev_noise_valid <= 0;
        prev_noise_heard_in_window <= 0;  
        debug_state <= IDLE;
		  varu <= 1;
    end else begin
        varu <= 0; 
        spi_start <= 0;
        debug_state <= state;
        
        case(state)
            IDLE: begin
                if (start) begin
                    state <= INIT;
                    voltage <= 8'h00;
                end
            end
                
           INIT: begin 
                timer <= 0;
                if (timer >= 3) begin  // задерживаем для сборки с spi --?
                    timer <= 0;
                    state <= INCREASE;
                    spi_start <= 0;
                end else begin
                    timer <= timer + 1;
                end
            end
                
            INCREASE: begin 
                spi_start <= 0;
                if (timer >= DELAY_380_TICKS - 1) begin
                    if (!prev_noise_heard_in_window) begin
                        voltage <= voltage + 1;
                    end
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
                spi_start <= 0;
                
                if (timer == 0)
                    noise_heard_in_window <= 0;  
						  noise_check_count <= 0; 

                if (noise_valid) begin
                    noise_check_count <= noise_check_count + 1; //шумы за 1 окно [не используется пока]
                    global_noise_count <= global_noise_count + 1;
                    noise_heard_in_window <= 1; // <-- флаг!
                end 

                if (timer < DELAY_115_TICKS - 1) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 0;
                    spi_start <= 1;

                    if (noise_heard_in_window) begin
                        window_count <= window_count + 1;
                    end else begin
                        window_count <= 0;
                    end

                    prev_noise_heard_in_window <= noise_heard_in_window;  

                    if (window_count >= 3) begin
                        varu <= 1;
                        state <= CALIBRATE;
                    end else begin
                        state <= INCREASE;
                    end
                end
            end

            CALIBRATE: begin
                varu <= 1;
                if (reset) begin
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule
