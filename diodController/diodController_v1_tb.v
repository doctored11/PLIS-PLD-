`timescale 1ns / 1ps

module diodController_v1_tb;
    reg clk = 0;
    reg reset = 0;
    reg start = 0;
    reg noise_valid = 0;
    wire [7:0] voltage;
    wire spi_start;
    wire store_en;
    wire [1:0] debug_window_count;

    // Instantiate DUT
    counter dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .noise_valid(noise_valid),
        .voltage(voltage),
        .spi_start(spi_start),
        .store_en(store_en),
        .debug_window_count(debug_window_count)
    );

    // Clock generation: 50MHz
    always #10 clk = ~clk;

    // Task to print status
    task print_status;
        $display("Time = %10t | Voltage = %02h | Window Count = %0d | StoreEn = %0d | SPI Start = %0d",
                 $time, voltage, debug_window_count, store_en, spi_start);
    endtask

    // Helper to wait for a packet cycle and inject noise
    task packet_with_noise(input integer noise_time_offset);
        integer i;
        begin
            for (i = 0; i < 19000 + 250 + noise_time_offset; i = i + 1)
                @(posedge clk);

            noise_valid = 1;
            @(posedge clk);
            noise_valid = 0;

            for (i = noise_time_offset + 1; i < 5750; i = i + 1)
                @(posedge clk);
        end
    endtask

    // Helper to run a packet with no noise
    task packet_no_noise;
        begin
            repeat (19000 + 250 + 5750) @(posedge clk);
        end
    endtask

    initial begin
        $display("Starting 5-packet noise timing test...");
        reset = 1;
        #100;
        reset = 0;

        start = 1;
        #20;
        start = 0;

        // Packet 1: noise near end of window
        $display("# Packet 1: noise at END of window");
        packet_with_noise(5700);

        // Packet 2: noise at start of window
        $display("# Packet 2: noise at START of window");
        packet_with_noise(10);

        // Packet 3: no noise
        $display("# Packet 3: NO noise");
        packet_no_noise();

        // Packet 4: noise at START
        $display("# Packet 4: noise at START of window");
        packet_with_noise(20);

        // Packet 5: noise at END
        $display("# Packet 5: noise at END of window");
        packet_with_noise(5600);

        $display("Ending 5-packet test.");
        $finish;
    end

    always @(posedge clk) begin
        print_status();
    end
endmodule
