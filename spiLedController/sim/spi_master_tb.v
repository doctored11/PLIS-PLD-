`timescale 1ns/1ps
module spi_master_tb();
    reg clk = 0;
    reg reset = 1;
    reg start = 0;
    reg [7:0] data = 0;
    wire SCLK, MOSI, SS;
    spi_master uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data(data),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .SS(SS)
    );
    always #10 clk = ~clk;
    reg [7:0] received_data;
    integer bit_count = 0;
    reg [7:0] expected_data [0:5];
    initial begin
        expected_data[0] = 8'hFA;
        expected_data[1] = 8'h03;
        expected_data[2] = 8'h08;
        expected_data[3] = 8'hAA;
        expected_data[4] = 8'h55;
        expected_data[5] = 8'hFF;
    end
    initial begin
        $dumpfile("spi_master.vcd");
        $dumpvars(0, spi_master_tb);
        $display("\nЗ test start ");
        reset = 1;
        #100 reset = 0;
        #100;
        run_test(8'hFA, expected_data[0]);
        run_test(8'h03, expected_data[1]);
        run_test(8'h08, expected_data[2]);
        run_test(8'hAA, expected_data[3]);
        run_test(8'h55, expected_data[4]);
        run_test(8'hFF, expected_data[5]);
        $display("\n end test");
        #100 $finish;
    end
    task run_test;
        input [7:0] tx_data;
        input [7:0] expected;
        begin
            $display("\n sendа: 0x%h (%b)", tx_data, tx_data);
            data = tx_data;
            start = 1;
            #20 start = 0;
            wait(SS == 1);
            if (received_data !== expected) begin
                $display("error: Expect 0x%h (%b), get 0x%h (%b)", expected, expected, received_data, received_data);
            end else begin
                $display("Ok: Sovpalo");
            end
            #100;
        end
    endtask
    always @(posedge SCLK) begin
        if (!SS) begin
            received_data[7-bit_count] = MOSI;
            bit_count = bit_count + 1;
            if (bit_count == 8) begin
                $display("Получено: 0x%h (%b)", received_data, received_data);
                bit_count = 0;
            end
        end else begin
            bit_count = 0;
        end
    end
endmodule
