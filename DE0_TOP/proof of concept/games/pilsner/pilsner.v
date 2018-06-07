
//---------------------------------------------------------------------------------
//---------------------------------- PILSNER --------------------------------------
//
// Pilsner game (unfortunately, without girls).
//
//
// Most important signals:
// 	* Parameters:
//				* PALYER_CONTROLS_WIDTH 	- player controls width.
// 	* Input signals:
//				* clk 	- clock signal (considered to have a frequency of 50 MHz).
//				* reset 	- asynchronus reset signal. 
//				* pause	- pause signal.
//				* x,y 	- coordinates of the pixel that should currently be printed.
//				* PLAYER_1	- player1 control signals.
//				* PLAYER_2	- player2 control signals.
//				* BUTTON		- the BUTTONs.
// 	* Output Signals:
//				* out 	- the 12b RBG value of the current pixel (in the same 
//							  sequence as in the name of teh signal).
//				* LED 	- the LEDs on the FPGA board used for testing.
//				* HEX		- the HEXs on the FPGA board used for testing.
//----------------------------------------------------------------------------------

`include "../../../core/constants.vh"
module pilsner
  		#(
			parameter PALYER_CONTROLS_WIDTH = 4
		)
		(		
			input wire clk, reset,
			input wire pause,
			input wire [9:0] x, y,
			input	[1:0]	BUTTON,
			input wire [PALYER_CONTROLS_WIDTH-1: 0] PLAYER_1,
			input wire [PALYER_CONTROLS_WIDTH-1: 0] PLAYER_2,
			output [11:0] out,
			output wire [9:0] LED,
			output wire [7:0] HEX0,
			output wire [7:0] HEX1,
			output wire [7:0] HEX2,
			output wire [7:0] HEX3
		);
		
	//=========================
	// Constants.
	//=========================
	localparam CONSTANT_ELEMENTS = 3;
	localparam NUMBER_OF_BOTTLES = 20;
	localparam WIDTH = CONSTANT_ELEMENTS + NUMBER_OF_BOTTLES;	
	
	localparam X_DISP = 133;
	localparam ACTIVE_SCREEN = X_DISPLAY - 2*TEXT_SPAING - 5;
	localparam TIME_DISP = 4_400;
	localparam TIME_MODULE = 20_000;
	
	localparam BACKGROUND_COLOR = 12'h011;
	localparam ELEMENT_COLOR = 12'he22;
	
	localparam PLAYER_LENGTH = 50;
	localparam PLAYER_WIDTH = 50;
	localparam PLAYER_GAP = 15;
	localparam PLAYER_1_X = X_DISPLAY/2;
	localparam PLAYER_1_Y = Y_DISPLAY - PLAYER_LENGTH;
	localparam PLAYER_SPEED_FACTOR = 4;
	
	localparam EPSILON = 0;
		
	localparam TEXT_SIZE = 30;
	localparam TEXT_SPAING = 45;
		
	//========================
	// Signals.
	//========================
	wire print [WIDTH-1 : 0];
	integer level [WIDTH-1 : 0];
	wire [11:0] pixel [WIDTH-1 : 0];
	
	wire [9:0] px [WIDTH-1 : 0];
	wire [9:0] py [WIDTH-1 : 0];

	wire [11:0] output_pixel;
	integer collision_level;
	
	wire change_player_speed;
	integer player_speed;
	integer player_dir;
	
	integer player_score_reg, player_score_next ;

	//=========================
	// Instantiation.
	//=========================
	
	// PL1
	shader #(ELEMENT_COLOR) sh1 (.x(x), .y(y), .px(px[0]), .py(py[0]), .pixel(pixel[0]), .level(level[0]), .pause(pause));
	renderer #(.A_INIT(PLAYER_WIDTH), .B_INIT(PLAYER_LENGTH), .TYPE(RECTANGLE))  rd1
	(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[0]), .py(py[0]), .enabled(1), .print(print[0]), .pause(pause));
	physics #(.X_INIT(PLAYER_1_X), .Y_INIT(PLAYER_1_Y), .X_MAX(X_DISPLAY), .X_MIN(0), .Y_MIN(PLAYER_1_Y), .Y_MAX(PLAYER_1_Y), .VX_INIT(0), .VY_INIT(0), .MODE(NO_ACTION) ) 
	ph1 (.clk(clk), .reset(reset), .x_out(px[0]), .y_out(py[0]), .pause(pause), .wr_v(change_player_speed), .vx_in(player_speed), .vy_in(0));

	
	
	// SCORE 1
	shader #(ELEMENT_COLOR) sh11 (.x(x), .y(y), .px(px[1]), .py(py[1]), .pixel(pixel[1]), .level(level[1]), .pause(pause));
	renderer 
		#(.A_INIT(TEXT_SIZE), .B_INIT(5), .TYPE(TEXT)) 
		rd11
		(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[1]), .py(py[1]), .enabled(1), .print(print[1]), .pause(pause), .a_in(TEXT_SIZE), .b_in(player_score_reg/10), .wr_ab(1));
	
	assign px[1] = X_DISPLAY-TEXT_SPAING*2-5;
	assign py[1] = 10;
	
	shader #(ELEMENT_COLOR) sh12 (.x(x), .y(y), .px(px[2]), .py(py[2]), .pixel(pixel[2]), .level(level[2]), .pause(pause));
	renderer 
		#(.A_INIT(TEXT_SIZE), .B_INIT(5), .TYPE(TEXT)) 
		rd12
		(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[2]), .py(py[2]), .enabled(1), .print(print[2]), .pause(pause), .a_in(TEXT_SIZE), .b_in(player_score_reg%10), .wr_ab(1));
	
	assign px[2] = X_DISPLAY-TEXT_SPAING-5;
	assign py[2] = 10;	

	
genvar i;
generate	
	for (i=CONSTANT_ELEMENTS; i<WIDTH; i=i+1) 
	begin : aaa
		bottle #(ELEMENT_COLOR, 10, (i*X_DISP)%ACTIVE_SCREEN, (i*TIME_DISP) % TIME_MODULE) b 		(
			.clk(clk),
			.reset(reset),
			.print(print[i]),
			.level(level[i]),
			.pixel(pixel[i]),
			.px(px[i]),
			.py(py[i]),
			.x(x),
			.y(y),
			.pause(pause),
			.collision(collision_level > 1)
			//.led(LED)
		);
		
	end
endgenerate
	
	// Pixel join
	pixel_join_modif #(.WIDTH(WIDTH),.BACKGROUND(BACKGROUND_COLOR)) pj (.clock(clk), .reset(reset), .enable(print), .level(level), .pixel(pixel), .out(output_pixel), .collision_num(collision_level)); 
	
	//=========================
	// Program.
	//=========================
	
	
	initial 
	begin
		player_score_reg = 0;
	end
		
	//assign LED
	//assign LED = {PLAYER_2,PLAYER_1};
	
	assign out = output_pixel; 
	
	
	// Pong logic.
	
	assign change_player_speed = 1;//PLAYER_1[UP] || PLAYER_1[DOWN]; 

	assign player_speed = (PLAYER_2[RIGHT] - PLAYER_2[LEFT]) *  PLAYER_SPEED_FACTOR;
	
	reg inc_reg, inc_next;
	
	always @(posedge clk, posedge reset)
	begin
		if(reset)
		begin	
		player_score_reg = 0;
		inc_reg = 0;
		end
		else
		begin		
		player_score_reg = player_score_next;
		inc_reg = inc_next;
		end		
	end
	
	

	assign inc_next = collision_level > 1;
	
	always @(inc_reg)
	begin
		player_score_next = player_score_reg;
		if(inc_reg)
			player_score_next = player_score_reg + 1;
	end

	always @(*)
	begin
	
		HEX0[0] = 1;
		HEX1[0] = 1;
		HEX2[0] = 1;
		HEX3[0] = 1;
		
		HEX0[7:1] = to_7_seg(player_score_reg%10);
		HEX1[7:1] = to_7_seg(player_score_reg/10);
		HEX2 = 7'b1111111;
		HEX3 = 7'b1111111;
	
	end
	
	function [6:0] to_7_seg(integer value);
   begin
      case (value)
			0:
				return 7'b1000000;
			1:				
				return 7'b1111001;
			2:	
				return 7'b0100100;
			3:	
				return 7'b0110000;
			4:	
				return 7'b0011001;
			5:	
				return 7'b0010010;
			6:
				return 7'b0000010;
			7:
				return 7'b1111000;
			8:
				return 7'b0000000;
			9:
				return 7'b0010000;
			default:
				return 7'b1111111;
		endcase
   end
   endfunction

		
		
endmodule