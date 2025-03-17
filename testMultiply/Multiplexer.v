module Multiplexer(output Y, input X0, X1, A);


	//1)
    /*wire Not1Y, And1Y, And2Y; 
    not Not1(Not1Y, A);
    and And1(And1Y, X0, Not1Y);
    and And2(And2Y, X1, A);
    or Or1(Y, And1Y, And2Y);*/
	 
	 //2) через пользовательский примитив
		//MX Mx(Y,X0,X1,A);
		
	//3) через модуль
	CustomMux Mux(Y,X0,X1,A);
	

endmodule

primitive MX (output Y, input X0, X1, A);

		table
			// A  	X0			X1 : Y
				0		0			?	: 0;
				0		1			? : 1;
				1		?			0	:0;
				1		?			1: 1;
			
		endtable
		
endprimitive


module CustomMux(output Y, input X0, X1, A);

    wire Not1Y, And1Y, And2Y; 
    not Not1(Not1Y, A);
    and And1(And1Y, X0, Not1Y);
    and And2(And2Y, X1, A);
    or Or1(Y, And1Y, And2Y);
	 


endmodule
