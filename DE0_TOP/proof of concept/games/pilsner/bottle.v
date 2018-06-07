
//---------------------------------------------------------------------------------
//---------------------------------- PILSNER BOTTLE --------------------------------------
//
// Pilsner game (unfortunately, without girls).
//
//
// Most important signals:
// 	* Parameters:
//				* ELEMENT_COLOR 	- player controls width.
//				* SIZE 				- player controls width.
//				* X_POS 				- player controls width.
//				* DELAY 				- player controls width.
// 	* Input signals:
//				* clk 	- clock signal (considered to have a frequency of 50 MHz).
//				* reset 	- asynchronus reset signal. 
//				* pause	- pause signal.
//				* x,y 	- coordinates of the pixel that should currently be printed.
//				* collision - collision signal.
// 	* Output Signals:
//				* out 		- the 12b RBG value of the current pixel (in the same 
//							  		sequence as in the name of teh signal).
//				* print		- weather or not the current pixel should be displayed.
//				* pixel 		- RGB value of the pixel.
//				* px, py		- coordinates of the top left edge of the object
//----------------------------------------------------------------------------------
`include "../../../core/constants.vh"
module bottle
		#(
			parameter ELEMENT_COLOR,
			parameter SIZE,
			parameter X_POS,
			parameter DELAY = 1000
		)
		(
			input wire clk,
			input wire reset,
			output wire print,
			output integer level,
			output wire [11:0] pixel,
			output wire [9:0] px,
			output wire [9:0] py,
			input integer x,
			input integer y,
			input wire pause,
			input wire collision,
		);
		
	//========================
	// Signals.
	//========================
		
	reg enable_reg, enable_new;
	reg py_reg, py_next;
	wire tick;
	
	reg r_reg, r_next;
	
	wire r;
	
	wire rest;
	
	integer cnt;
	
	//=========================
	// Instantiation.
	//=========================
	
	//timer #(.DELAY(DELAY)) t(.clk(clk),.reset(reset || collision || tick), .value(enable));
	SQUARE_WAVE_GENERATOR #(DELAY)	 swg(.clock(clk),.reset(rest),.rising_edge(tick));
	
	shader #(ELEMENT_COLOR) sh0 (.x(x), .y(y), .px(px), .py(py), .pixel(pixel), .level(level), .pause(pause));
	renderer #(.A_INIT(SIZE), .TYPE(CIRCLE)) rd0 (.clock(clk), .reset(rest), .x(x), .y(y), .px(px), .py(py), .enabled(enable_reg), .print(print), .pause(pause));
	physics #(.X_INIT(X_POS), .Y_INIT(1), .Y_MIN(0), .Y_MAX(Y_DISPLAY-SIZE), .VX_INIT(0), .VY_INIT(3), .MODE(FULL_RESET)) 
	ph0	(.clk(clk), .reset(rest), .x_out(px), .y_out(py), .pause(pause), .x_in(X_POS), .y_in(0), .wr_xy(!enable_reg), .r(r_next));
	
	
	//=========================
	// Program.
	//=========================
	
	initial begin
		cnt = 1;
		py_reg = 0;
		py_next = 0;
		r_reg = 0;
		r_next = 0;
	end
		
	
	always @(posedge clk, posedge rest)
	begin
		if(rest)
		begin
			enable_reg = 0;
			py_reg = 0;
			r_reg = 0;
		end
		else
		begin
			enable_reg = enable_new;
			py_reg = py_next;
			r_reg = r_next;
		end
	end

	assign rest = reset || (collision && print);
	assign enable_new = r_reg ? 0 :enable_reg || tick;
	
	assign py_next = py;
	//assign tick = new_py == 0 && old_py != 0;
	
	always @(enable_reg)
	if(!enable_reg)
	cnt = cnt + 1;
	
		
endmodule