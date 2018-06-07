
//---------------------------------------------------------------------------------
//-------------------- VGA SIGNAL GENERATOR ---------------------------------------
//
// Generates various signals that are used for the output through the VGA port.
//
//
// Most important signals:
// 	* Input signals:
//				* clk 	- clock signal (considered to have a frequency of 50 MHz).
//				* reset 	- asynchronus reset signal. 
// 	* Output Signals:
//				* x,y 								- coordinates of the current pixel that is being processed.
//				* hsync, vsync, video_on		- VGA control signals.
//----------------------------------------------------------------------------------

module VGA_signal_generator
	(
		input wire clk, reset,
		output wire hsync, vsync, video_on,
		output wire [9:0] x, y
	);
	
	//==========================
	// Constants.
	//==========================
	
	localparam X_DISPLAY 		= 800;
	localparam X_FRONT_PORCH 	= 56;
	localparam X_SYNC_PULSE		= 120;
	localparam X_BACK_PORCH		= 64;
	
	localparam Y_DISPLAY 		= 600;
	localparam Y_FRONT_PORCH 	= 37;
	localparam Y_SYNC_PULSE		= 6;
	localparam Y_BACK_PORCH		= 23;
	
	localparam X_MAX = X_DISPLAY + X_FRONT_PORCH + X_SYNC_PULSE + X_BACK_PORCH - 1;
	localparam Y_MAX = Y_DISPLAY + Y_FRONT_PORCH + Y_SYNC_PULSE + Y_BACK_PORCH - 1;
	
	localparam X_L = X_DISPLAY + X_FRONT_PORCH - 1;
	localparam X_U = X_DISPLAY + X_FRONT_PORCH + X_SYNC_PULSE - 1;
	
	localparam Y_L = Y_DISPLAY + Y_FRONT_PORCH - 1;
	localparam Y_U = Y_DISPLAY + Y_FRONT_PORCH + Y_SYNC_PULSE - 1;
	
	//=========================
	// Signals.
	//=========================
	
	integer x_reg, x_next;
	integer y_reg, y_next;
	
	wire tick;
		
	//==============================
	// Program.
	//==============================
	
	initial 
	begin
		x_reg = 0;
		x_next = 0;
		y_reg = 0;
		y_next = 0;
	end
	
	assign x = x_reg;
	assign y = y_reg;
	assign tick = clk;
	
	assign hsync = x_reg > X_L && x_reg < X_U;
	assign vsync = y_reg > Y_L && y_reg < Y_U;
	assign video_on = x_reg < X_DISPLAY && y_reg < Y_DISPLAY;
	
	// update
	always @(*)
	begin
		x_next = x_reg + 1;
		y_next = y_reg;
		
		if(x_reg == X_MAX)
		begin
			x_next = 0;
			if(y_reg == Y_MAX)
			begin
				y_next = 0;
			end
			else
			begin
				y_next = y_reg + 1;
			end
		end
	end
	
	always @(posedge tick, posedge reset)
	begin
		if(reset)
		begin
			x_reg = 0;
			y_reg = 0;
		end
		else
		begin
			x_reg = x_next;
			y_reg = y_next;
		end
	end

		
endmodule
