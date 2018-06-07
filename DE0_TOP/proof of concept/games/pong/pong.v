
//---------------------------------------------------------------------------------
//----------------------------------- PONG ----------------------------------------
//
// Pong Game.
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
module pong
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
	localparam WIDTH = 7;	
	localparam BACKGROUND_COLOR = 12'h011;
	localparam ELEMENT_COLOR = 12'h2fa;
	localparam BALL_SIZE = 10;
	localparam BALL_MAX_X = PLAYER_2_X - BALL_SIZE - 1;
	localparam BALL_MIN_X = PLAYER_1_X + PLAYER_WIDTH + 1;
	
	localparam PLAYER_LENGTH = 75;
	localparam PLAYER_WIDTH = 10;
	localparam PLAYER_GAP = 15;
	localparam PLAYER_1_X = PLAYER_GAP;
	localparam PLAYER_1_Y = 0;
	localparam PLAYER_2_X = X_DISPLAY - PLAYER_WIDTH - PLAYER_GAP;
	localparam PLAYER_2_Y = 0;
	localparam PLAYER_SPEED_FACTOR = 2;
	
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
	
	integer ball_speed_x;
	integer ball_speed_y;
	integer ball_x_in;
	integer ball_x_in_snap;
	integer ball_x_in_reset;
	wire ball_bounce;
	wire out_of_bounds;
	
	wire change_player_1_speed;
	integer player_1_speed;
	integer player_1_dir;
	
	wire change_player_2_speed;
	integer player_2_speed;
	integer player_2_dir;
	
	integer player_1_score_reg, player_1_score_next ;
	integer player_2_score_reg, player_2_score_next;
	
	//=========================
	// Instantiation.
	//=========================
	
	// BALL
	shader #(ELEMENT_COLOR) sh0 (.x(x), .y(y), .px(px[0]), .py(py[0]), .pixel(pixel[0]), .level(level[0]), .pause(pause));
	renderer #(.A_INIT(BALL_SIZE), .TYPE(CIRCLE)) rd0 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[0]), .py(py[0]), .enabled(1), .print(print[0]), .pause(pause));
	physics #(.X_INIT(X_DISPLAY/2), .Y_INIT(10), .X_MAX(X_DISPLAY-BALL_SIZE), .Y_MAX(Y_DISPLAY-BALL_SIZE), .VX_INIT(2), .VY_INIT(3), .MODE(BOUNCE) ) 
	ph0	(.clk(clk), .reset(reset), .x_out(px[0]), .y_out(py[0]), .pause(pause), .vx_in(-ball_speed_x), .vy_in(ball_speed_y), .vx_out(ball_speed_x), .vy_out(ball_speed_y),
			.wr_v(ball_bounce || out_of_bounds), .x_in(ball_x_in), .y_in(py[0]), .wr_xy(ball_bounce || out_of_bounds));
	
	// PL1
	shader #(ELEMENT_COLOR) sh1 (.x(x), .y(y), .px(px[1]), .py(py[1]), .pixel(pixel[1]), .level(level[1]), .pause(pause));
	renderer #(.A_INIT(PLAYER_WIDTH), .B_INIT(PLAYER_LENGTH), .TYPE(RECTANGLE))  rd1
	(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[1]), .py(py[1]), .enabled(1), .print(print[1]), .pause(pause));
	physics #(.X_INIT(PLAYER_1_X), .Y_INIT(PLAYER_1_Y), .X_MAX(PLAYER_1_X), .X_MIN(PLAYER_1_X), .Y_MAX(Y_DISPLAY-PLAYER_LENGTH), .VX_INIT(0), .VY_INIT(0), .MODE(NO_ACTION) ) 
	ph1 (.clk(clk), .reset(reset), .x_out(px[1]), .y_out(py[1]), .pause(pause), .wr_v(change_player_1_speed), .vx_in(0), .vy_in(player_1_speed));
	
	// PL2
	shader #(ELEMENT_COLOR) sh2 (.x(x), .y(y), .px(px[2]), .py(py[2]), .pixel(pixel[2]), .level(level[2]), .pause(pause));
	renderer 
		#(.A_INIT(PLAYER_WIDTH), .B_INIT(PLAYER_LENGTH), .TYPE(RECTANGLE)) 
		rd2
		(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[2]), .py(py[2]), .enabled(1), .print(print[2]), .pause(pause));
	physics #(.X_INIT(PLAYER_2_X), .Y_INIT(PLAYER_2_Y), .X_MAX(PLAYER_2_X), .X_MIN(PLAYER_2_X), .Y_MAX(Y_DISPLAY-PLAYER_LENGTH), .VX_INIT(0), .VY_INIT(0), .MODE(NO_ACTION) )
	ph2 (.clk(clk), .reset(reset), .x_out(px[2]), .y_out(py[2]), .pause(pause), .wr_v(change_player_2_speed), .vx_in(0), .vy_in(player_2_speed));
	
	
	// SCORE 1
	shader #(ELEMENT_COLOR) sh11 (.x(x), .y(y), .px(px[3]), .py(py[3]), .pixel(pixel[3]), .level(level[3]), .pause(pause));
	renderer 
		#(.A_INIT(TEXT_SIZE), .B_INIT(5), .TYPE(TEXT)) 
		rd11
		(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[3]), .py(py[3]), .enabled(1), .print(print[3]), .pause(pause), .a_in(TEXT_SIZE), .b_in(player_1_score_reg/10), .wr_ab(1));
	
	assign px[3] = X_DISPLAY/2-TEXT_SPAING*2-10;
	assign py[3] = 10;
	
	shader #(ELEMENT_COLOR) sh12 (.x(x), .y(y), .px(px[4]), .py(py[4]), .pixel(pixel[4]), .level(level[4]), .pause(pause));
	renderer 
		#(.A_INIT(TEXT_SIZE), .B_INIT(5), .TYPE(TEXT)) 
		rd12
		(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[4]), .py(py[4]), .enabled(1), .print(print[4]), .pause(pause), .a_in(TEXT_SIZE), .b_in(player_1_score_reg%10), .wr_ab(1));
	
	assign px[4] = X_DISPLAY/2-TEXT_SPAING-10;
	assign py[4] = 10;
	
	
	// SCORE 2
	shader #(ELEMENT_COLOR) sh13 (.x(x), .y(y), .px(px[5]), .py(py[5]), .pixel(pixel[5]), .level(level[5]), .pause(pause));
	renderer 
		#(.A_INIT(TEXT_SIZE), .B_INIT(5), .TYPE(TEXT)) 
		rd13
		(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[5]), .py(py[5]), .enabled(1), .print(print[5]), .pause(pause), .a_in(TEXT_SIZE), .b_in(player_2_score_reg/10), .wr_ab(1));
	
	assign px[5] = X_DISPLAY/2+TEXT_SPAING+10;
	assign py[5] = 10;
	
	shader #(ELEMENT_COLOR) sh14 (.x(x), .y(y), .px(px[6]), .py(py[6]), .pixel(pixel[6]), .level(level[6]), .pause(pause));
	renderer 
		#(.A_INIT(TEXT_SIZE), .B_INIT(5), .TYPE(TEXT)) 
		rd14
		(.clock(clk), .reset(reset), .x(x), .y(y), .px(px[6]), .py(py[6]), .enabled(1), .print(print[6]), .pause(pause), .a_in(TEXT_SIZE), .b_in(player_2_score_reg%10), .wr_ab(1));
	
	assign px[6] = X_DISPLAY/2+TEXT_SPAING*2+10;
	assign py[6] = 10;
	
	
	
	// Ball bounds when colliding with player.
	BOUND_CHECKER bchk_x (.value(px[0]), .max(BALL_MAX_X), .min(BALL_MIN_X), .snap(ball_x_in_snap));
	
	// Pixel join
	pixel_join #(.WIDTH(WIDTH),.BACKGROUND(BACKGROUND_COLOR)) pj (.enable(print), .level(level), .pixel(pixel), .out(output_pixel), .collision_num(collision_level)); 
	
	//=========================
	// Program.
	//=========================
	
	
	initial 
	begin
		ball_bounce = 0;
		out_of_bounds = 0;
		player_1_score_reg = 0;
		player_2_score_reg = 0;
	end
		
	//assign LED
	assign LED = {PLAYER_2,PLAYER_1};
	
	assign out = output_pixel; 
	
	
	// Pong logic.
	
	assign change_player_1_speed = 1;//PLAYER_1[UP] || PLAYER_1[DOWN]; 
	assign change_player_2_speed = 1;//PLAYER_2[UP] || PLAYER_2[DOWN]; 

	assign player_1_speed = (PLAYER_1[DOWN] - PLAYER_1[UP]) *  PLAYER_SPEED_FACTOR;
	assign player_2_speed = (PLAYER_2[DOWN] - PLAYER_2[UP]) *  PLAYER_SPEED_FACTOR;
	
	assign ball_x_in_reset = X_DISPLAY / 2;

	assign ball_x_in =  out_of_bounds ? ball_x_in_reset : ball_x_in_snap;
	
	
	always @(posedge clk, posedge reset)
	begin
		if(reset)
		begin			
			player_1_score_reg = 0;
			player_2_score_reg = 0;
		end
		else
		begin		
			player_1_score_reg = player_1_score_next;
			player_2_score_reg = player_2_score_next;
		end		
	end
	
	always @(posedge clk)
	begin
		ball_bounce = 0;
		out_of_bounds = 0;

		if(collision_level > 1 && (px[0] <= PLAYER_GAP+PLAYER_WIDTH || px[0] >= X_DISPLAY - PLAYER_GAP-PLAYER_WIDTH-BALL_SIZE))
		begin
			// Collision with player.
			ball_bounce = 1;
		end
		
		if(px[0] <= 0 + EPSILON || px[0]  >= X_DISPLAY - BALL_SIZE - EPSILON)
		begin
			// Out of bounds.
			out_of_bounds = 1;
		end
	end
	
	always @(out_of_bounds)
	begin
			player_1_score_next = player_1_score_reg;
			player_2_score_next = player_2_score_reg;

			if(out_of_bounds)
			begin
				if(px[0] <= 0 + EPSILON)
					player_2_score_next = player_2_score_reg + 1;
				if(px[0] >= X_DISPLAY - BALL_SIZE - EPSILON)
					player_1_score_next = player_1_score_reg + 1;
			end
	end
	
	always @(*)
	begin
	
		HEX0[0] = 1;
		HEX1[0] = 1;
		HEX2[0] = 0;
		HEX3[0] = 1;
		
		HEX0[7:1] = to_7_seg(player_2_score_reg%10);
		HEX1[7:1] = to_7_seg(player_2_score_reg/10);
		HEX2[7:1] = to_7_seg(player_1_score_reg%10);
		HEX3[7:1] = to_7_seg(player_1_score_reg/10);
	
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