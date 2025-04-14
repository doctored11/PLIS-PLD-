module counter(
    input         clk,
    input         reset,
    input         start,
    input         noise_valid,
    output reg [7:0] voltage,
    output reg    spi_start,
    output reg    varu,
    output [1:0]  debug_window_count,
    output reg [2:0] debug_state
);

parameter IDLE       = 0;
parameter INIT       = 1;
parameter TRANSMIT   = 2;
parameter INCREASE   = 3;
parameter PAUSE      = 4;
parameter CHECK_NOISE = 5;
parameter CALIBRATE  = 6;

reg [2:0] state;
reg [15:0] timer;
reg [1:0] noise_check_count;
reg [1:0] window_count;
reg       noise_heard_in_window;
reg       prev_noise_valid;
reg [15:0] global_noise_count;
reg       prev_noise_heard_in_window;

assign debug_window_count = window_count;

wire [1:0] mode = 2'b00;  // пока только один - (включение)

wire [15:0] window_send_time;
wire [15:0] window_increase_time;
wire [15:0] window_pause_time;
wire [15:0] window_listen_time;
wire [7:0]  num_windows;
wire        lfd_disable_before;
wire        lfd_enable_after;
wire        calibration_mode;
wire        pause_action_required;

mode_profile profile_inst (
    .mode(mode),
    .window_send_time(window_send_time),
    .window_increase_time(window_increase_time),
    .window_pause_time(window_pause_time),
    .window_listen_time(window_listen_time),
    .num_windows(num_windows),
    .lfd_disable_before(lfd_disable_before),
    .lfd_enable_after(lfd_enable_after),
    .calibration_mode(calibration_mode),
    .pause_action_required(pause_action_required)
);

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

        case (state)
            IDLE: begin
                if (start) begin
                    state <= INIT;
                    voltage <= 8'h00;
                end
            end

            INIT: begin
                timer <= 0;
                if (timer >= 3) begin
                    timer <= 0;
                    state <= TRANSMIT;
                end else begin
                    timer <= timer + 1;
                end
            end

            TRANSMIT: begin
                spi_start <= 1;
                if (timer >= window_send_time - 1) begin
                    spi_start <= 0;
                    timer <= 0;
                    state <= INCREASE;
                end else begin
                    timer <= timer + 1;
                end
            end

            INCREASE: begin
                if (timer >= window_increase_time - 1) begin
                    if (!prev_noise_heard_in_window) begin
                        voltage <= voltage + 1;
                    end
                    timer <= 0;
                    state <= PAUSE;
                end else begin
                    timer <= timer + 1;
                end
            end

            PAUSE: begin
                if (timer >= window_pause_time - 1) begin
                    timer <= 0;
                    state <= CHECK_NOISE;
                end else begin
                    timer <= timer + 1;
                end
            end

            CHECK_NOISE: begin
                spi_start <= 0;

                if (timer == 0) begin
                    noise_heard_in_window <= 0;
                    noise_check_count <= 0;
                end

                if (noise_valid) begin
                    noise_check_count <= noise_check_count + 1;
                    global_noise_count <= global_noise_count + 1;
                    noise_heard_in_window <= 1;
                end

                if (timer < window_listen_time - 1) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 0;

                    if (noise_heard_in_window) begin
                        window_count <= window_count + 1;
                    end else begin
                        window_count <= 0;
                    end

                    prev_noise_heard_in_window <= noise_heard_in_window;

                    if (window_count >= num_windows) begin
								//todo добавить логику калибровки (пока только переход из включения в калибровку)
                        varu <= 1;
                        state <= CALIBRATE;
                    end else begin
                        state <= TRANSMIT;
                    end
                end
            end

            CALIBRATE: begin
                varu <= 1;
            end
        endcase
    end
end

endmodule
