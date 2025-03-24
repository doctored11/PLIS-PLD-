`timescale 1ns/1ps
module onlyCounter_tb();


    reg clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    
    reg reset;
    reg inc;
    reg dec;
    
   
    wire [7:0] val;

   
    counter uut (
        .clk(clk),
        .reset(reset),
        .inc(inc),
        .dec(dec),
        .val(val)
    );

  
    initial begin
       
        reset = 1;
        inc = 0;
        dec = 0;
        #100 reset = 0;
        
       
        $display("--- \n");
        repeat(5) begin
            inc = 1; #20;
            inc = 0; #80;
            $display("val = %0d", val);
        end

        
        $display("\n +++ \n");
        repeat(3) begin
            dec = 1; #20;
            dec = 0; #80;
            $display("val = %0d", val);
        end

     
        $display("\n Gran sluchai=)");
        
        repeat(2) begin
            dec = 1; #20; dec = 0; #80;
        end
        $display("after -decrement val=0: %0d", val);
        
        reset = 1; #20; reset = 0;
        repeat(300) begin
            inc = 1; #10; inc = 0; #10;
        end
        $display("after 300 +increments = %0d", val);

        #100 $stop;
    end

endmodule