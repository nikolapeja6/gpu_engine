
//---------------------------------------------------------------------------------
//----------------------------------- PHYSICS -------------------------------------
//
// Controlls the piysics part of the object.
//
//
// Most important signals:
//		* Parameters:
//				* PARIOD 		- the period for updating, in ms.
//				* MODE			- the mode that defines the default action that is taken
//									  when the object comes to an invalid state 
//									  (when the position of the object ).
//									  Possible values:
//											+ NO_ACTION (0)- the position of the object is
//																  snapped to the nearest bound and
//																  remains there.
//											+ RESET (1)			- the value of the axis that has 
//																  caused the invalid state is reset.
//											+ FULL_RESET (2)- the values of both the axes is reset.
//				* X_INIT,
//				  X_MIN, X_MAX - the initial, minimum and maximum value on the x axis.
//				* Y_INIT,
//				  Y_MIN, Y_MAX - the initial, minimum and maximum value on the y axis.
//				* VX_INIT,
//				  VY_INIT		- the initial values for the speed on both the axes.
// 	* Input signals:
//				* clk 			- clock.
//				* reset 			- asynchonus reset.
//				* x_in, y_in 	- coordinates of the pixel that should currently be printed.
//				* px, py 		- coordinates of the top left edge of the object.
//				* enabled 		- indicates if the renderer is active.
//				* a 				- the side of the square/triangle, 
//									  or the radius of the circle, in pixels.
//				* collision 	- collision signal(not used for now).
//				* pause 			- pause signal.
// 	* Output Signals:
//				* x_out, y_out		 - the current position on the x and y axes.
//				* vx_out, vy_out	 - the current speed on the x and y axes.
//				* r					 - signals is a reset was made.
//----------------------------------------------------------------------------------

`include "constants.vh"

module physics 
		#(
			// period for the update in ms
			parameter PERIOD = GLOBAL_PHYSICS_PERIOD,
			
			// Mode.
			parameter MODE = RESET,
			
			// Initial, upper and lower bound of the position on the x axis.
			parameter X_INIT = 0,
			parameter X_MIN = 0,
			parameter X_MAX = X_DISPLAY,
			
			// Initial, upper and lower bound of the position on the y axis.
			parameter Y_INIT = 0,
			parameter Y_MIN = 0,
			parameter Y_MAX = Y_DISPLAY,
			
			// The initial values of speed on the x and y axes.
			parameter VX_INIT = 1,
			parameter VY_INIT = 1
		)
		(
			input wire clk, reset,
			input wire [9:0] x_in, y_in,
			output wire [9:0] x_out, y_out,
			input integer vx_in, vy_in,
			output integer vx_out, vy_out,
			input wire wr_xy,
			input wire wr_v,
			input wire collision,
			input wire pause,
			output wire r
		);
		
	//=======================
	// Local signals.
	//=======================
	integer x_reg, x_next;
	integer y_reg, y_next;
	
	wire valid_x;
	wire valid_y;
	
	integer snap_x;
	integer snap_y;
	
	integer vx_reg, vx_next;
	integer vy_reg, vy_next;
	
	wire update;
	
	reg r_reg, r_next;
	
	
	//====================== 
	// Instantiation.
	//======================
	SQUARE_WAVE_GENERATOR #(PERIOD) swg(.clock(clk), .reset(reset), .rising_edge(update));
	
	BOUND_CHECKER bchk_x (.value(x_reg), .max(X_MAX), .min(X_MIN), .valid(valid_x), .snap(snap_x));
	BOUND_CHECKER bchk_y (.value(y_reg), .max(Y_MAX), .min(Y_MIN), .valid(valid_y), .snap(snap_y));
	
	//======================
	// Program.
	//======================
	
	initial 
	begin
		vx_reg = VX_INIT;
		vx_next = VX_INIT;
		vy_reg = VY_INIT;
		vy_next = VY_INIT;
		x_reg = X_INIT;
		x_next = X_INIT;
		y_reg = Y_INIT;
		y_next = Y_INIT;
		r_reg = 0;
		r_next = 0;
	end
	
	assign x_out = x_reg;
	assign y_out = y_reg;
	assign vx_out = vx_reg;
	assign vy_out = vy_reg;
	
	assign r = r_reg;
	
	always @(posedge clk, posedge reset)
	begin
	
	if(reset)
		begin
			x_reg = X_INIT;
			y_reg = Y_INIT;
			vx_reg = VX_INIT;
			vy_reg = VY_INIT;
			r_reg = 0;
		end
	else
		begin
			x_reg = x_next;
			y_reg = y_next;
			vx_reg = vx_next;
			vy_reg = vy_next;
			r_reg = r_next;
		end
	end

	// update position based on speed
	always @(update, wr_xy, wr_v)
	begin
		x_next = x_reg;
		y_next = y_reg;
		vx_next = vx_reg;
		vy_next = vy_reg;
		r_next = 0;
					
		if(update && !pause)
		begin

			// update pos <= pos + v*t
			x_next = x_reg + vx_reg;
			y_next = y_reg + vy_reg;
			
			case (MODE)
			
			// NO ACTION
			NO_ACTION:
				begin
					if(valid_x == 0)
						x_next = snap_x;
					if(valid_y == 0)
						y_next = snap_y;
				end
			// RESET
			RESET:
				begin
					if(valid_x == 0)begin
						x_next = X_INIT;
						r_next = 1;
					end
					if(valid_y == 0) begin
						y_next = Y_INIT;
						r_next = 1;
					end
				end
			// FULL RESET
			FULL_RESET:
				begin
					if(valid_x == 0 || valid_y == 0)
					begin
						x_next = X_INIT;
						y_next = Y_INIT;
						r_next = 1;
					end
				end
			// BOUNCE
			BOUNCE:
				begin
					if(valid_x == 0)
					begin
						x_next = snap_x;
						vx_next = -vx_reg;
						r_next = 1;
					end
					
					if(valid_y == 0)
					begin
						y_next = snap_y;
						vy_next = -vy_reg;
						r_next = 1;
					end
					
				end
				
			// DEFAULT
			default:
				begin
					if(valid_x == 0)
						x_next = X_INIT;
					if(valid_y == 0)
						y_next = Y_INIT;
				end
			endcase
		end
		
		// write position 
		if(wr_xy)
		begin
			x_next = x_in;
			y_next = y_in;
		end	
		
		// write speed
		if(wr_v)
		begin
			vx_next = vx_in;
			vy_next = vy_in;
		end
		
	end

endmodule