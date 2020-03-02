module UART_RX(CLK50MHz, RESET, RX, DATA);
	input CLK50MHz, RX;
	input RESET; // Active low reset signal
	output reg [7:0] DATA;


	// Internal Circuitry
	reg [17:0] counter; // Used to generate tick from 50MHz clock
	reg tick; // 153KHz Sampling Clock signal
	reg [3:0] statemachine; // StateMachine state counter

	reg [7:0] cache; // Caching samples before sending full words to DATA
	reg [2:0] cacheIndex; // Track which bit we are sampling into cache	

	reg [4:0] pointer; // used to count tick before resampling
	reg parityBit;


	// RX reader - Samples bitstream
	always @(posedge tick or negedge RESET)
	begin
		if (RESET == 0)
			begin
				;
			end
		else
			begin
				case (statemachine) // Interpret the RX line

					// Idle state
					4'd0	: // Detect start bit
					begin
						if (RX == 0)
							begin
								pointer <= pointer + 1;
								if (pointer == 5'd24)
								begin
									statemachine <= statemachine + 1;
									pointer <= 0;
								end
							end
						else
							pointer <= 0;
					end

					// Collect word data
					4'd1	:
					begin
						if (pointer == 0) // If we haven't sampled this bit yet
							begin
								cache[cacheIndex] <= RX; // Then sample it
								pointer <= pointer + 1; // and mark it as such
							end
						else // otherwise we have sampled it already
							begin
								pointer <= pointer + 1;

								if (pointer == 5'd16) // Wait for 1 sample period
								begin
									if (cacheIndex == 3'd7) // If we have sampled all bits
										begin
											cacheIndex <= 0; // Reset for next loop and
											statemachine <= 4'd2; // then go to the next state
										end
									else // Then move to the next bit
										begin
											cacheIndex <= cacheIndex + 1;
											pointer <= 0;
										end
								end
							end
					end

					// Check the Parity bit
					4'd2	:
					begin
						if (pointer == 0) // If we haven't sampled this bit yet, sample it
							begin

								// TODO fix this trash vvv
								parityBit <= cache[0]^cache[1]^cache[2]^cache[3]^cache[4]^cache[5]^cache[6]^cache[7];
								pointer <= pointer + 1; // and mark it as such

								if (parityBit == RX)
								begin
									DATA <= cache;
								end
							end
						else // otherwise we have sampled it already
							begin
								pointer <= pointer + 1;

								if (pointer == 5'd16) // Wait for 1 sample period
								begin
									pointer <= 0; // reset to zero for next state
									statemachine <= 4'd3; // go to the next state
								end
							end
					end


					// Stop bit
					default	:
					begin
						if (RX == 1)
						begin
							pointer <= 0;
							statemachine <= 4'd0;
						end
					end
				endcase
			end
	end


	// Tick generator - Creates 153KHz Sampling Clock signal
	always @(posedge CLK50MHz or negedge RESET)
	begin
		if (RESET == 0)
			begin
				tick <= 0;
				counter <= 18'd0;
			end
		else
			begin
				counter <= counter + 1;
				if (counter == 18'd153000)
				begin
					tick <= !tick;
					counter <= 18'd0;
				end
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
