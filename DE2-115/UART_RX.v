module UART_RX(CLK50MHz, RX, DATA);
	input CLK50MHz, RX;
	output reg [7:0] DATA;


	// Internal Circuitry
	reg [17:0] counter;
	reg tick;
	reg [1:0] statemachine;
	reg [7:0] cache;
	reg [3:0] pointer;


	// RX reader
	always @(posedge tick) begin
		cache[pointer] <= RX;
		if (cache[pointer - 1] == 1 && RX == 0)
	end


	// Tick generator
	always @(posedge CLK50MHz) begin
		if (counter == 18'b0)
		begin
			tick <= 0;
		end


		counter <= counter + 1;
		if (counter == 18'd153000)
		begin
			counter <= 0;
			tick <= 1;
		end

	end

	/*PseudoCode
	 * Step 1:
		Counter that outputs a 153KHz clock from 50MHz
			this gives a 9600 baud reciever
			sampled 16 times AKA 16 clocks per it period
		Step 2:
			always block (procedural) based off that counter
		3:
			if hi-low transistion then
			-we know its the start bit
			-this means wait 1.5 bit periods to sample center of 1st bit
				wait for 1.5 * 16 = 24 counter ticks
				for (num bits)
					sample nth bit - need register array to deserialize these
					wait 16 ticks
				repeat
		- optional: check the parity bit
		we should expect to see the end bit here
			send the register array to the audio block
		
		go back and wait for another hi-low transistion
		 
	 */
endmodule
