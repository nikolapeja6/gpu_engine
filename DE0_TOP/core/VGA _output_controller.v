
//---------------------------------------------------------------------------------
//-------------------- VGA OUTPUT CONTROLLER  ---------------------------------------
//
// Contorlls the output to the VGA port.
//
//
// Most important signals:
// 	* Input signals:
//				* clk 						- clock signal (considered to have a frequency of 50 MHz).
//				* reset 						- asynchronus reset signal. 
//				* PS2_KBDAT, PS2_KBCLK 	- ps2(keyboard, mouse) signals. 
// 	* Output Signals:
//				* RGB 				- the 12b RBG value of the current pixel (in the same 
//											sequence as in the name of teh signal).
//				* LED 				- the LEDs on the FPGA board used for testing.
//				* HEX					- the HEXs onf the FPGA board used for testing.
//				* hsync, vsync		- VGA sync signals.
//----------------------------------------------------------------------------------

`include "constants.vh"

module VGA_output_controller
	(
		input wire clk, reset,
		input	[2:0]	BUTTON,
		input	[9:0]	SW,
		output wire hsync, vsync,
		output wire [11:0] RGB,
		output wire [9:0] LED,
		inout		 	PS2_KBDAT,
		inout			PS2_KBCLK,
		output wire [7:0] HEX0,
		output wire [7:0] HEX1,
		output wire [7:0] HEX2,
		output wire [7:0] HEX3
	);
	
	//===============================
	// Constants.
	//===============================
	localparam PALYER_CONTROLS_WIDTH = 4;
	
	//===============================
	// Signals.
	//===============================
	wire [9:0] x, y;
					
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;
	
	wire[11:0] pixel;
	
	reg pause_reg, pause_next;
	reg reset_reg, reset_next;
	
	// Player 1
	wire [PALYER_CONTROLS_WIDTH-1 : 0] PLAYER_1;
	
	// Player 2
	wire [PALYER_CONTROLS_WIDTH-1 : 0] PLAYER_2;
	
	wire [7:0] keyboard_code;
						
	wire esc;
	wire space;
	
	wire rst;
	//=====================
	// Instantiation.
	//=====================
	VGA_signal_generator vga_sync_unit (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
				.video_on(video_on), .x(x), .y(y));
		
	Keyboard k(	.CLK (clk), .PS2_CLK (PS2_KBCLK), .PS2_DATA (PS2_KBDAT),.code(keyboard_code));	
	
			
	Key #(W) 			key_w		(.clock(clk), .value(PLAYER_1[UP]),	 	.current_code(keyboard_code));
	Key #(S) 			key_s		(.clock(clk), .value(PLAYER_1[DOWN]),	.current_code(keyboard_code));
	Key #(A) 			key_a		(.clock(clk), .value(PLAYER_1[LEFT]), 	.current_code(keyboard_code));
	Key #(D) 			key_d		(.clock(clk), .value(PLAYER_1[RIGHT]), .current_code(keyboard_code));
	
	Key #(ARROW_UP) 	key_up	(.clock(clk), .value(PLAYER_2[UP]), 		.current_code(keyboard_code));
	Key #(ARROW_DOWN) key_down	(.clock(clk), .value(PLAYER_2[DOWN]), 		.current_code(keyboard_code));
	Key #(ARROW_LEFT)	key_left	(.clock(clk), .value(PLAYER_2[LEFT]), 		.current_code(keyboard_code));
	Key #(ARROW_RIGHT)key_right(.clock(clk), .value(PLAYER_2[RIGHT]), 	.current_code(keyboard_code));
	
	Key #(ESC)			key_esc	(.clock(clk), .value(esc), 	.current_code(keyboard_code));
	Key #(SPACE)		key_space(.clock(clk), .value(space), 	.current_code(keyboard_code));
				
	//=======================
	// User defined module.
	//=======================
	main #(.PALYER_CONTROLS_WIDTH(PALYER_CONTROLS_WIDTH))m 	(.clk(clk), .reset(rst), .x(x), .y(y), .out(pixel), /*.LED(LED),*/ .pause(pause_reg), .SW(SW), .BUTTON(BUTTON),
				.PLAYER_1(PLAYER_1), .PLAYER_2(PLAYER_2), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3));

	//=====================
	// Program.
	//=====================
	
	assign LED = pause_reg;//{PLAYER_1, PLAYER_2};
	
	initial 
	begin
		pause_reg = 0;
		pause_next = 0;
		reset_reg = 0;
		reset_next = 0;
	end
	
	// output
   assign RGB = (video_on) ? (pixel): BLACK;
	
	assign rst = reset_reg != reset_next;
	
	always @(posedge clk, posedge reset)
	begin
		if(reset)
		begin
			pause_reg = 1;
			reset_reg = 0;
		end
		else
		begin
			pause_reg = pause_next;
			reset_reg = reset_next;
		end
	end
	
	always @(posedge space)
	begin
			pause_next = ~pause_reg;
	end
	
	always @(posedge esc)
	begin
		reset_next = ~reset_reg;
	end
		
	
endmodule