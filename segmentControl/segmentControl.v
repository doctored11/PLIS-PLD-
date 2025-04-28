

module segmentControl (
    input  wire        clk,      //!сразу завести сюда пониженную частоту       
    input  wire [15:0] bcd_input,      // 4 цифры(0000-1001) в двоичном формате Binary coded Decimal
    output reg  [7:0]  segment_outputs, // линии именно сегментов (0-горит)
    output reg  [3:0]  anode_select     // будет бегающая единица для зажигания конкретного индекса (0001-1000)
);

   
   
	// бегающая единица (число от 1 до 4х)для выбора ячейки
    reg [1:0] scan_counter;  
    always @(posedge clk) begin
        
            scan_counter <= scan_counter + 2'd1;
    end

    //парсинг нужного числа со входа (формат 0000_0000_000_000) -[ключ]
	 //?- подумать над направлением вырезанных векторов ([ 3: 0] - вроде правильнее (проверить))
    reg [3:0] current_bcd;
    always @(*) begin
        case (scan_counter)
            2'd0: current_bcd = bcd_input[ 3: 0];
            2'd1: current_bcd = bcd_input[ 7: 4];
            2'd2: current_bcd = bcd_input[11: 8];
            2'd3: current_bcd = bcd_input[15:12];
            default: current_bcd = 4'b1111;
        endcase
    end

     //карта соответствий для поджигания нужных чисел 
	  //?- возможно изменить порядок единиц - проверить на практике
    reg [7:0] segment_pattern;
	 
    always @(*) begin
        case (current_bcd)
            4'd0: segment_pattern = 8'b1100_0000; // 0
            4'd1: segment_pattern = 8'b1111_1001; 
            4'd2: segment_pattern = 8'b1010_0100; 
            4'd3: segment_pattern = 8'b1011_0000; 
            4'd4: segment_pattern = 8'b1001_1001; // 4
            4'd5: segment_pattern = 8'b1001_0010; 
            4'd6: segment_pattern = 8'b1000_0010; 
            4'd7: segment_pattern = 8'b1111_1000; // 7
            4'd8: segment_pattern = 8'b1000_0000; 
            4'd9: segment_pattern = 8'b1001_0000; // 9
            default: segment_pattern = 8'b0000_0110; // E - как error
				endcase
    end

   //отрисовка
    always @(posedge clk) begin
        
            segment_outputs <= segment_pattern;
					//? проверить на практике когда оно обновляется - мб сделать через маски если не работает
            anode_select <= 4'b0000;
            anode_select[scan_counter] <= 1'b1;
        
    end

endmodule
