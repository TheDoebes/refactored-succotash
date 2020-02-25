module UART_RX(CLK50MHz, RX, DATA);
	input CLK50MHz, RX;
	output [7:0] DATA;
	
	reg [17:0] counter;
	
	always@(posedge CLK50MHz) begin
		counter <= counter + 1;
		if (counter == 18'd153000) 
			begin
				counter <= 0;
				// whatever written here happens on every counter tick
				
				
			end
			
	end
endmodule
