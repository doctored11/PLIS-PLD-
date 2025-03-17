module multiply( // на самом деле счетчик до 10ти
    input wire clk,       
    input wire reset, 
	 
    output reg [3:0] count 
);

   
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0; 
        end else begin
            if (count == 9) begin 
                count <= 0; 
            end else begin
                count <= count + 1; 
            end
        end
    end

endmodule
//не понимаю на RTL схеме обозначения - где их можно посмотреть (соответственно не понимаю именно схему)
//+спросить roadmap