`timescale 1ns / 1ps

module spi_tb;
//тест для spi (отдельно)
    
    reg clk;
    reg reset;
    

    wire SCLK;
     wire MOSI;
    wire SS;
    

    reg [7:0] data_to_send;
    reg start_transmission;
    
    reg [7:0] received_data;
    
    spi_module uut (
        .clk(clk),
        .reset(reset),
        .start(start_transmission),
        .data(data_to_send),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .SS(SS)
    );
    
    // тактовый сигнал [придет из верхнего модуля]
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
  
    reg [2:0] bit_counter; 
    
    always @(negedge SS) begin
        $display("[Slave] start transave. time: %t", $time);
        received_data = 0;
        bit_counter = 7;
        
        while (bit_counter >= 0) begin
            @(posedge SCLK);
            received_data[bit_counter] = MOSI;
            $display("[Slave] get bit %d: %b", 7-bit_counter, MOSI);
             bit_counter = bit_counter - 1;
        end
        
        $display("[Slave] getting data: %b (0x%h)", received_data, received_data);
    end
    
    initial begin
        reset = 1;
        start_transmission = 0;
        data_to_send = 0;
        
        #100;
        reset = 0;
        #100;
        
        $display("\n=== start test Spi module ===");
        
        test_single_transfer(8'b11010100);
        test_single_transfer(8'b10101010);
          test_single_transfer(8'b00001111); 
          test_single_transfer(8'b11111111); 
        
        #100;
        $display("\n=== end of the tests ===");
        $finish;
    end
    
    task test_single_transfer;
        input [7:0] data;
        begin
            $display("\n[Test] start data transfer: %b (0x%h)", data, data);
            data_to_send = data;
            start_transmission = 1;
            #10;
            start_transmission = 0;
            
            wait(SS == 1);
            #50;
            
            if (received_data === data) begin
                $display("[Test] Success: same data");
            end else begin
                $display("[Test] ERROR: try to get %b, but get %b", 
                        data, received_data);
            end
        end
    endtask
    
    initial begin
        $display("time | SS | SCLK | MOSI");
        $display("-----------------------");
        forever begin
            @(posedge clk);
            if (!reset) begin
                $display("%t | %b | %b | %b", $time, SS, SCLK, MOSI);
            end
        end
    end
    
endmodule