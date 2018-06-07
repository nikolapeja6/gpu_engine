
//---------------------------------------------------------------------------------
//--------------------------------- SCREENSAVER ---------------------------------
//
// Simulation with multiple objects moving across the screen.
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
// 	* Output Signals:
//				* out 	- the 12b RBG value of the current pixel (in the same 
//							  sequence as in the name of teh signal).
//				* LED 	- the LEDs on the FPGA board used for testing.
//----------------------------------------------------------------------------------

`include "../../../core/constants.vh"

module screen_saver
		#(
			parameter PALYER_CONTROLS_WIDTH = 4
		)
		(		
			input wire clk, reset,
			input wire pause,
			input wire [9:0] x, y,
			input wire [PALYER_CONTROLS_WIDTH-1: 0] PLAYER_1,
			input wire [PALYER_CONTROLS_WIDTH-1: 0] PLAYER_2,
			output [11:0] out,
			output wire [9:0] LED
		);
		
	//=========================
	// Constants.
	//=========================
	localparam WIDTH = 12;	
	localparam integer COLLISOIN_LEVELS  [0 : 9]   = '{12'h000, 12'h000, 12'h000, 12'h999, 12'h777, 12'h555, 12'h333, 12'h222, 12'h111, 12'h000};
		
	//========================
	// Signals.
	//========================
	wire print [WIDTH-1 : 0];
	integer level [WIDTH-1 : 0];
	wire [11:0] pixel [WIDTH-1 : 0];
	
	wire [9:0] px [WIDTH-1 : 0], py[WIDTH-1 : 0];

	wire [11:0] output_pixel;
	integer collision_level;
	
	//=========================
	// Instantiation.
	//=========================
	
	//MOVING
	// circle 1
	shader sh1 (.x(x), .y(y), .px(px[0]), .py(py[0]), .pixel(pixel[0]), .level(level[0]), .pause(pause));
	renderer #(.A_INIT(100), .TYPE(CIRCLE)) rd1 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[0]), .py(py[0]), .enabled(1), .print(print[0]), .pause(pause));
	physics #(.X_INIT(0), .Y_INIT(0), .VX_INIT(1), .VY_INIT(1) ) ph1 (.clk(clk), .reset(reset), .x_out(px[0]), .y_out(py[0]), .pause(pause));
	
	// triangle 1
	shader sh2 (.x(x), .y(y), .px(px[1]), .py(py[1]), .pixel(pixel[1]), .level(level[1]), .pause(pause));
	renderer #(.A_INIT(50), .TYPE(TRIANGLE)) rd2 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[1]), .py(py[1]), .enabled(1), .print(print[1]), .pause(pause));
	physics #(.X_INIT(X_DISPLAY), .Y_INIT(Y_DISPLAY), .VX_INIT(-1), .VY_INIT(-2) ) ph2 (.clk(clk), .reset(reset), .x_out(px[1]), .y_out(py[1]), .pause(pause));
	
	// square 1
	shader sh3 (.x(x), .y(y), .px(px[2]), .py(py[2]), .pixel(pixel[2]), .level(level[2]), .pause(pause));
	renderer #(.A_INIT(150), .TYPE(SQUARE)) rd3 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[2]), .py(py[2]), .enabled(1), .print(print[2]), .pause(pause));
	physics #(.X_INIT(0), .Y_INIT(0), .VX_INIT(3), .VY_INIT(1) ) ph3 (.clk(clk), .reset(reset), .x_out(px[2]), .y_out(py[2]), .pause(pause));
	

	//STATIC
	// square 2
	shader #(12'b000000001111)sh4 (.x(x), .y(y), .px(300), .py(300), .pixel(pixel[3]), .level(level[3]), .pause(pause));
	renderer #(.A_INIT(180), .V_INIT(-3), .A_MIN(0), .TYPE(SQUARE)) rd4 (.clock(clk), .reset(reset), .x(x), .y(y), .px(100), .py(200), .enabled(1), .print(print[3]), .pause(pause));
	
	// circle 2
	shader #(12'b111111110000)sh5 (.x(x), .y(y), .px(300), .py(300), .pixel(pixel[4]), .level(level[4]), .pause(pause));
	renderer #(.A_INIT(100), .V_INIT(3), .A_MIN(0), .A_MAX(300), .TYPE(CIRCLE)) rd5 (.clock(clk), .reset(reset), .x(x), .y(y), .px(400), .py(200), .enabled(1), .print(print[4]), .pause(pause));
	
	// triangle 2
	shader #(12'b111111111111 )sh6 (.x(x), .y(y), .px(300), .py(300), .pixel(pixel[5]), .level(level[5]), .pause(pause));
	renderer #(.A_INIT(150), .V_INIT(-1), .A_MIN(0), .TYPE(TRIANGLE)) rd6 (.clock(clk), .reset(reset), .x(x), .y(y), .px(400), .py(100), .enabled(1), .print(print[5]), .pause(pause));
	
	
	// BOUNCING
	// circle 3
	shader #(12'h4ff) sh7 (.x(x), .y(y), .px(px[6]), .py(py[6]), .pixel(pixel[6]), .level(level[6]), .pause(pause));
	renderer #(.A_INIT(50), .TYPE(CIRCLE)) rd7 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[6]), .py(py[6]), .enabled(1), .print(print[6]), .pause(pause));
	physics #(.X_INIT(50), .Y_INIT(50), .X_MAX(X_DISPLAY-50), .Y_MAX(Y_DISPLAY-50), .VX_INIT(2), .VY_INIT(5), .MODE(BOUNCE) ) ph7 (.clk(clk), .reset(reset), .x_out(px[6]), .y_out(py[6]), .pause(pause));
	
	// circle 4
	shader #(12'h4ff) sh8 (.x(x), .y(y), .px(px[7]), .py(py[7]), .pixel(pixel[7]), .level(level[7]), .pause(pause));
	renderer #(.A_INIT(50), .TYPE(CIRCLE)) rd8 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[7]), .py(py[7]), .enabled(1), .print(print[7]), .pause(pause));
	physics #(.X_INIT(200), .Y_INIT(200),  .X_MAX(X_DISPLAY-50), .Y_MAX(Y_DISPLAY-50), .VX_INIT(3), .VY_INIT(1), .MODE(BOUNCE) ) ph8 (.clk(clk), .reset(reset), .x_out(px[7]), .y_out(py[7]), .pause(pause));
	
	// circle 5
	shader #(12'h4ff) sh9 (.x(x), .y(y), .px(px[8]), .py(py[8]), .pixel(pixel[8]), .level(level[8]), .pause(pause));
	renderer #(.A_INIT(50), .TYPE(CIRCLE)) rd9 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[8]), .py(py[8]), .enabled(1), .print(print[8]), .pause(pause));
	physics #(.X_INIT(150), .Y_INIT(50), .X_MAX(X_DISPLAY-50), .Y_MAX(Y_DISPLAY-50), .VX_INIT(2), .VY_INIT(2), .MODE(BOUNCE) ) ph9 (.clk(clk), .reset(reset), .x_out(px[8]), .y_out(py[8]), .pause(pause));
	
	// circle 6
	shader #(12'h4ff) sh10 (.x(x), .y(y), .px(px[9]), .py(py[9]), .pixel(pixel[9]), .level(level[9]), .pause(pause));
	renderer #(.A_INIT(50), .TYPE(CIRCLE)) rd10 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[9]), .py(py[9]), .enabled(1), .print(print[9]), .pause(pause));
	physics #(.X_INIT(300), .Y_INIT(50), .X_MAX(X_DISPLAY-50), .Y_MAX(Y_DISPLAY-50), .VX_INIT(2), .VY_INIT(3), .MODE(BOUNCE) ) ph10 (.clk(clk), .reset(reset), .x_out(px[9]), .y_out(py[9]), .pause(pause));
	
	// circle 7
	shader #(12'h4ff) sh11 (.x(x), .y(y), .px(px[10]), .py(py[10]), .pixel(pixel[10]), .level(level[10]), .pause(pause));
	renderer #(.A_INIT(50), .TYPE(CIRCLE)) rd11 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[10]), .py(py[10]), .enabled(1), .print(print[10]), .pause(pause));
	physics #(.X_INIT(400), .Y_INIT(600), .X_MAX(X_DISPLAY-50), .Y_MAX(Y_DISPLAY-50), .VX_INIT(1), .VY_INIT(4), .MODE(BOUNCE) ) ph11 (.clk(clk), .reset(reset), .x_out(px[10]), .y_out(py[10]), .pause(pause));
	
	
	// FULL RESET
	shader #(12'hb4f)sh12 (.x(x), .y(y), .px(px[11]), .py(py[11]), .pixel(pixel[11]), .level(level[11]), .pause(pause));
	renderer #(.A_INIT(150), .TYPE(SQUARE)) rd12 (.clock(clk), .reset(reset), .x(x), .y(y), .px(px[11]), .py(py[11]), .enabled(1), .print(print[11]), .pause(pause));
	physics #(.X_INIT(X_DISPLAY), .Y_INIT(0), .VX_INIT(-2), .VY_INIT(2) ,.Y_MAX(Y_DISPLAY*2), .MODE(FULL_RESET)) ph12 (.clk(clk), .reset(reset), .x_out(px[11]), .y_out(py[11]), .pause(pause));
	
	
	// Pixel join
	pixel_join #(.WIDTH(WIDTH)) pj (.enable(print), .level(level), .pixel(pixel), .out(output_pixel), .collision_num(collision_level)); 
	
	//=========================
	// Program.
	//=========================
		
	//assign LED
	assign LED = collision_level;
	
	assign out = collision_level > 1 ? COLLISOIN_LEVELS[collision_level%9] : output_pixel; 
	
	
endmodule