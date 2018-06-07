
//---------------------------------------------------------------------------------
//-------------------------------------- MAIN -------------------------------------
//
// Main module - the module that the user specific code is placed.
//
//
// Most important signals:
// 	* Input signals:
//				* clk 		- clock signal (considered to have a frequency of 50 MHz).
//				* reset 		- asynchronus reset signal. 
//				* pause		- pause display signal.
//				* x			- x cordinate of a pixel.
//				* y			- y cordinate of a pixel.
//				* BUTTON		- the BUTTONs.
//				* SW			- the SWs.
//				* PLAYER_1	- player1 control signals.
//				* PLAYER_2	- player2 control signals.
// 	* Output Signals:
//				* out 	- the 12b RBG value of the current pixel (in the same 
//							  sequence as in the name of teh signal).
//				* LED 	- the LEDs on the FPGA board used for testing.
//				* HEX		- the HEXs on the FPGA board used for testing.
//----------------------------------------------------------------------------------

module main
		#(
			parameter PALYER_CONTROLS_WIDTH = 4
		)
		(		
			input wire clk, reset,
			input wire pause,
			input wire [9:0] x, y,
			input	[2:0]	BUTTON,
			input	[9:0]	SW,
			input wire [PALYER_CONTROLS_WIDTH-1: 0] PLAYER_1,
			input wire [PALYER_CONTROLS_WIDTH-1: 0] PLAYER_2,
			output [11:0] out,
			output wire [9:0] LED,
			output wire [7:0] HEX0,
			output wire [7:0] HEX1,
			output wire [7:0] HEX2,
			output wire [7:0] HEX3
		);
		
	//============================
	// Constants.
	//============================
	
	localparam WIDTH = 3;
		
	//============================
	// Signals.
	//============================
	
	 wire [11:0] out_array [WIDTH-1 : 0];
	 wire [9:0] LED_array [WIDTH-1 : 0];
	 wire [8:0] HEX0_array [WIDTH-1 : 0];
	 wire [8:0] HEX1_array [WIDTH-1 : 0];
	 wire [8:0] HEX2_array [WIDTH-1 : 0];
	 wire [8:0] HEX3_array [WIDTH-1 : 0];
	 
	//============================
	// Instances.
	//============================
	
	screen_saver ss (.clk(clk), .reset(reset), .x(x), .y(y), .out(out_array[0]), .LED(LED_array[0]), .pause(pause));
	pong p (.clk(clk), .reset(reset), .x(x), .y(y), .out(out_array[1]), .LED(LED_array[1]), .pause(pause), .BUTTON(BUTTON[1:0]), .PLAYER_1(PLAYER_1), .PLAYER_2(PLAYER_2),
				.HEX0(HEX0_array[1]), .HEX1(HEX1_array[1]), .HEX2(HEX2_array[1]), .HEX3(HEX3_array[1]));
				
	pilsner pils (.clk(clk), .reset(reset), .x(x), .y(y), .out(out_array[2]), .LED(LED_array[2]), .pause(pause), .BUTTON(BUTTON[1:0]), .PLAYER_1(PLAYER_1), .PLAYER_2(PLAYER_2),
				.HEX0(HEX0_array[2]), .HEX1(HEX1_array[2]), .HEX2(HEX2_array[2]), .HEX3(HEX3_array[2]));
	
	
	//============================
	// Program.
	//============================

	assign out = out_array[SW];
	assign LED = LED_array[SW];
	assign HEX0 = HEX0_array[SW];
	assign HEX1 = HEX1_array[SW];
	assign HEX2 = HEX2_array[SW];
	assign HEX3 = HEX3_array[SW];
		
endmodule