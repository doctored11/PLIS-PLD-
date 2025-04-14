module mode_profile (
    input  [1:0]  mode,

    output reg [15:0] window_send_time,
    output reg [15:0] window_increase_time,
    output reg [15:0] window_pause_time,
    output reg [15:0] window_listen_time,
    output reg [7:0]  num_windows,

    output reg lfd_disable_before,
    output reg lfd_enable_after,
    output reg calibration_mode,
    output reg pause_action_required
);

// режимы (этапы )
localparam MODE_ENABLE    = 2'b00;
localparam MODE_CALIBRATE = 2'b01;



parameter CLK_FREQ_MHZ = 50;
parameter real DELAY_30mcrs = 30.0;
parameter real DELAY_350mcrs = 350.0;
parameter real DELAY_115mcrs = 115.0;
parameter real DELAY_5mcrs   = 5.0;

localparam integer DELAY_30  = DELAY_30mcrs  * CLK_FREQ_MHZ;
localparam integer DELAY_350 = DELAY_350mcrs * CLK_FREQ_MHZ;
localparam integer DELAY_115 = DELAY_115mcrs * CLK_FREQ_MHZ;
localparam integer DELAY_5   = DELAY_5mcrs   * CLK_FREQ_MHZ;

always @(*) begin
    case (mode)
        MODE_ENABLE: begin
            window_send_time     = DELAY_30;
            window_increase_time = DELAY_350;
            window_pause_time    = DELAY_5;
            window_listen_time   = DELAY_115;
            num_windows          = 3;

            lfd_disable_before     = 0;
            lfd_enable_after       = 0;
            calibration_mode       = 0;
            pause_action_required  = 0;
        end

        MODE_CALIBRATE: begin
            window_send_time     = DELAY_30;
            window_increase_time = DELAY_350;
            window_pause_time    = DELAY_5;
            window_listen_time   = DELAY_115;
            num_windows          = 20;

            //todo -подумать мб не нужны спец переменные
            lfd_disable_before     = 1; // 255 в начале окна
            lfd_enable_after       = 1; 
            calibration_mode       = 1;
            pause_action_required  = 1;
        end


        default: begin
            window_send_time     = 16'd0;
            window_increase_time = 16'd0;
            window_pause_time    = 16'd0;
            window_listen_time   = 16'd0;
            num_windows          = 8'd0;

            lfd_disable_before     = 0;
            lfd_enable_after       = 0;
            calibration_mode       = 0;
            pause_action_required  = 0;
        end
    endcase
end

endmodule
