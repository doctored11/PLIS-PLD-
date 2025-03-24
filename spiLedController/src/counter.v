module counter(
    input clk,
    input reset,
    input inc,
    input dec,
    output reg [7:0] val
	 
);

//todo
/* 
-Вопрос: 
		- устраивает ли зависимость от clk - меня смущает что зажатие "кнопки " постоянно прибавляет значение,
	из за привязки к позитивному фронту clk даже быстрое нажатие на кнопку может трактоваться как зажати на +2/+3 а не на +1 (наверное)
		*- смотрел, там можно вроде реализовать счетчик около асинхронно -= но почему то все источники  нерекомендуют 
	
*/
    always @(posedge clk or posedge reset) begin  
        if (reset) begin
            val <= 8'd0;
        end else begin
            if (inc && !dec && val < 255) begin
                val <= val + 1;
            end else if (dec && !inc && val > 0) begin
                val <= val - 1;
            end
        end
    end
endmodule