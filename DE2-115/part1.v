module part1 (CLOCK_50, CLOCK2_50, KEY, SW, I2C_SCLK, I2C_SDAT, AUD_XCK,
	AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT, GPIO);
	
	// I/O
	// DE2-115 Signals
	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	input [1:0] SW;
	// I2C Audio/Video config interface
	output I2C_SCLK;
	inout I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	// Arduino Serial, UART
	input [35:0] GPIO;

	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	reg [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];
	// Arduino serial local wires
	wire [7:0] dial;
	wire [23:0] scaleFactor;

	/////////////////////////////////
	// Logic
	/////////////////////////////////

	assign read = read_ready && write_ready;
	assign write = read_ready && write_ready;
	
	// Extend dial over the appropriate range to scale audio data
	scaleFactor = {8'd0, dial, 8'd0};

	always @(*)
	begin
		
		writedata_left <= (readdata_left * scaleFactor) / scaleFactor;
		writedata_right <= (readdata_right * scaleFactor) / scaleFactor;
		
		/* 
		case (SW) // TODO change to a mapping variable, then map dial to that var
			2'b01 :
			begin
				writedata_left <= (readdata_left * 24'd1024)/24'd1024;
				writedata_right <= (readdata_right * 24'd1024)/24'd1024; 
			end
			2'b10 :
			begin
				writedata_left <= (readdata_left * 24'd2048)/24'd2048;
				writedata_right <= (readdata_right * 24'd2048)/24'd2048; 
			end
			2'b11 :
			begin
				writedata_left <= (readdata_left * 24'd4096)/24'd4096;
				writedata_right <= (readdata_right * 24'd4096)/24'd4096; 
			end
			default :
			begin
				writedata_left <= readdata_left;
				writedata_right <= readdata_right;
			end
		endcase */
	end
	
	
	// Instantiate the module for UART recieving from the ardunio
	 UART_RX uart_1(
	 	// inputs
	 	CLOCK_50, 
	 	reset, 
	 	GPIO[0], 
	 	
	 	// outputs
	 	dial
	 );


	/////////////////////////////////////////////////////////////////////////////////
	// Audio CODEC interface. 
	//
	// The interface consists of the following wires:
	// read_ready, write_ready - CODEC ready for read/write operation 
	// readdata_left, readdata_right - left and right channel data from the CODEC
	// read - send data from the CODEC (both channels)
	// writedata_left, writedata_right - left and right channel data to the CODEC
	// write - send data to the CODEC (both channels)
	// AUD_* - should connect to top-level entity I/O of the same name.
	//         These signals go directly to the Audio CODEC
	// I2C_* - should connect to top-level entity I/O of the same name.
	//         These signals go directly to the Audio/Video Config module
	/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
	// inputs
	CLOCK2_50,
	reset,

	// outputs
	AUD_XCK
	);

	audio_and_video_config cfg(
	// Inputs
	CLOCK_50,
	reset,

	// Bidirectionals
	I2C_SDAT,
	I2C_SCLK
	);

	audio_codec codec(
	// Inputs
	CLOCK_50,
	reset,

	read,	write,
	writedata_left, writedata_right,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	// Outputs
	read_ready, write_ready,
	readdata_left, readdata_right,
	AUD_DACDAT
	);

endmodule


