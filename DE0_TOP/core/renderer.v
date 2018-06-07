
//---------------------------------------------------------------------------------
//---------------------------------- RENDERER -------------------------------------
//
// Represents a rule/function that maps an object to the screen. 
//
//
// Most important signals:
// 	* Parameters:
// 			* TYPE 				- object type/shape.
//				* PERIOD 			- period for the update of the size of the object.
//				* MODE 				- mode of the renderer. States the action if the object comes
//										  to an invalid state (if  the size of the object breaches the 
//										  pre-set bounds).
//										  Possible values:
//												+ NO_ACTION (0)	- the size is snapped to the nearest
//																		  bound remains there.
//												+ RESET (1)			- the size of the object is reset to the 
//																		  initial value.
//				* A_MIN, A_MAX		- the minimum and maximum width of the object.
//				* B_MIN, B_MAX		- the minimum and maximum hight of the object.
//				* A_INIT				- the initial width of the object.
//				* B_INIT				- the initial hight of the object.
//				* V_INIT				- the initial speed of the process of resizing the object.
// 	* Input signals:
//				* clock 		- clock
//				* reset 		- asynchronus reset.
//				* x,y 		- coordinates of the pixel that should currently be printed.
//				* px, py 	- coordinates of the top left edge of the object.
//				* enabled 	- indicates if the renderer is active.
//				* a_in 		- the width of the square/triangle, or the radius of the circle, in pixels.
//				* b_in 		- the hight of the square/triangle, or the radius of the circle, in pixels.
//				* v_in 		- input speed of resize.
//				* wr_v		- control signal for accepting the v_in speed as the new speed.
//				* wr_ab		- control signal for accepting the a_in, b_in size as the new size.
//				* pause		- pause signal.
// 	* Output Signals:
//				* print 		- weather or not the current pixel should be displayed.
//				* a_out		- new width of the square/triangle, or the radius of the circle, in pixels.
//				* b_out 		- new hight of the square/triangle, or the radius of the circle, in pixels.
//----------------------------------------------------------------------------------

`include "constants.vh"

module renderer 
		#(
			parameter TYPE = SQUARE,
			
			// Reset when invalid state.
			parameter MODE = RESET;
			
			// Borders of valid state.
			parameter A_MIN = 0;
			parameter A_MAX = 500;
			
			parameter B_MIN = 0;
			parameter B_MAX = 500;
			
			// Initial values
			parameter A_INIT = 100,
			parameter B_INIT = 100,
			parameter V_INIT = 0,
			
			// Period in ms.
			parameter PERIOD = GLOBAL_RENDERER_PERIOD
		)
		(
			input wire clock, reset,
			input wire [9:0] x, y,
			input wire [9:0] px, py,
			input wire enabled,
			input integer a_in,
			input integer b_in,
			input integer v_in,
			input wire wr_ab,
			input wire wr_v,
			output integer a_out,
			output integer b_out,
			output wire print,
			input wire pause
		);
		
		//========================
		// Constants.
		//========================
		localparam TEXT_WIDTH = 5;
		
		//========================
		// Instances.
		//========================
		SQUARE_WAVE_GENERATOR #(PERIOD) swg (.clock(clock), .reset(reset), .rising_edge(update));
		
		BOUND_CHECKER bnd_a(.value(a_reg), .min(A_MIN), .max(A_MAX), .valid(valid_a), .snap(snap_a));
		BOUND_CHECKER bnd_b(.value(b_reg), .min(B_MIN), .max(B_MAX), .valid(valid_b), .snap(snap_b));

		
		//========================
		// Signals
		//========================
		
		// Speed of resize.
		integer v_reg, v_next;
		
		// Size of the object.
		integer a_reg, a_next;
		integer b_reg, b_next;
		
		wire valid_a;
		integer snap_a;
		
		wire valid_b;
		integer snap_b;
		
		// Print register.
		reg print_reg, print_next;
		
		wire update;
		
		//========================
		// Program
		//========================
		
		assign a_out = a_reg;
		assign b_out = b_reg;
		assign print = print_reg;
		
		initial 
		begin
			v_reg = V_INIT;
			v_next = V_INIT;
			a_reg = A_INIT;
			a_next = A_INIT;
			b_reg = B_INIT;
			b_next = B_INIT;
			print_next = 0;
			print_reg = 0;
		end
		
		always @(*)
		begin
			print_next = 0;
			
			// Check if renderer is enabled.
			if(enabled == 1)
			begin
				case (TYPE)
					// SQUARE
					SQUARE:
						begin
						
						if(x > px && x < (px+a_reg) && y > py && y < (py + a_reg))
							print_next = 1;
						else
							print_next = 0;
						end
						
					// CIRCLE			
					CIRCLE:
						begin
						
							integer center_x, center_y;
							center_x = px + a_reg/2;
							center_y = py + a_reg/2;

							if((x-center_x)*(x-center_x)*4 + (y-center_y)*(y-center_y)*4 <= a_reg*a_reg)
								print_next = 1;
							else
								print_next = 0;
						end
						
					// TRIANGLE
					TRIANGLE:
						begin
						
							integer d_x, d_y;
							
							d_x = x - px;
							d_y = y - py;
							
							// check constraints
							if(
								d_x >= ((a_reg-d_y) >> 1) && // 		/
								d_x <= ((a_reg+d_y) >> 1) && //		\
								d_y <= a_reg			  && 	  //		_
								d_x >= 0					  && 		
								d_y >= 0						     // sanity
								)
									print_next = 1;
						end
						
					// RECTANGLE
					RECTANGLE:
					begin
											
						if(x > px && x < (px+a_reg) && y > py && y < (py + b_reg))
							print_next = 1;
						else
							print_next = 0;						
					end
					
					// TEXT
					TEXT:
					begin
						print_next = check_segments(to_7_seg(b_reg), x, y, px, py, a_reg, TEXT_WIDTH);
					end
						
					// DEFAULT
					default:
						begin
						print_next = 0;
						end
				endcase		
			end
		end
	
		
		always @(posedge clock, posedge reset)
		begin
		
			if(reset)
			begin
				v_reg = V_INIT;
				a_reg = A_INIT;
				b_reg = B_INIT;
				print_reg = 0;
			end
			else
			begin
				v_reg = v_next;
				a_reg = a_next;
				b_reg = b_next;
				print_reg = print_next;
			end
		end
		
		always @(wr_v, wr_ab, update)
		begin
			v_next = v_reg;
			a_next = a_reg;
			b_next = b_reg;
			
			// Update.
			if(update && !pause)
			begin
			
				a_next = a_reg + v_reg;
				b_next = b_reg + v_reg;

				case (MODE)
				//NO ACTION
				NO_ACTION:
					begin
						if(!valid_a)
							a_next = snap_a;
							
						if(!valid_b)
							b_next = snap_b;
					end
				// RESET
				RESET:
					begin
						if(!valid_a)
							a_next = A_INIT;
						if(!valid_b)
							b_next = B_INIT;
					end
				// DEFAULT
				default:
					begin
						if(!valid_a)
							a_next = A_INIT;
						if(!valid_b)
							b_next = B_INIT;
					end			
				endcase
			end
			
			// Write size;
			if(wr_ab)
			begin
				a_next = a_in;
				b_next = b_in;
			end
			
			// Write speed.
			if(wr_v)
			begin
				v_next = v_in;
			end
		end
		
		
	function [6:0] to_7_seg(integer value);
   begin
      case (value)
			0:
				return ~7'b1000000;
			1:				
				return ~7'b1111001;
			2:	
				return ~7'b0100100;
			3:	
				return ~7'b0110000;
			4:	
				return ~7'b0011001;
			5:	
				return ~7'b0010010;
			6:
				return ~7'b0000010;
			7:
				return ~7'b1111000;
			8:
				return ~7'b0000000;
			9:
				return ~7'b0010000;
			default:
				return ~7'b1111111;
		endcase
   end
   endfunction
	
	
	function check_segments([6:0] segments, integer x, integer y, integer px, integer py, integer a, integer width);
   begin
			return 
			(segments[6] && check_1(x,y,px,py,a,width)) ||
			(segments[5] && check_2(x,y,px,py,a,width)) ||
			(segments[4] && check_3(x,y,px,py,a,width)) ||
			(segments[3] && check_4(x,y,px,py,a,width)) ||
			(segments[2] && check_5(x,y,px,py,a,width)) ||
			(segments[1] && check_6(x,y,px,py,a,width)) ||
			(segments[0] && check_7(x,y,px,py,a,width));
   end
   endfunction
	
	
	function check_1(integer x, integer y, integer px, integer py, integer a, integer width);
   begin
		if(y >= py + a/2 && y <= py + a/2 + width && x >= px + 0 && x <= px + a)
			return 1;
		else
			return 0;
   end
   endfunction
	
	function check_2(integer x, integer y, integer px, integer py, integer a, integer width);
   begin
		if(y >= py + 0 && y <= py + a/2 && x >= px + 0 && x <= px + width)
			return 1;
		else
			return 0;
   end
   endfunction
	
	function check_3(integer x, integer y, integer px, integer py, integer a, integer width);
   begin
		if(y >= py + a/2 && y <= py + a && x >= px + 0 && x <= px + width)
			return 1;
		else
			return 0;
   end
   endfunction
	
	function check_4(integer x, integer y, integer px, integer py, integer a, integer width);
   begin
		if(y >= py + a - width && y <= py + a && x >= px + 0 && x <= px + a)
			return 1;
		else
			return 0;
   end
   endfunction
	
	function check_5(integer x, integer y, integer px, integer py, integer a, integer width);
   begin
		if(y >= py + a/2 && y <= py + a && x >= px + a-width && x <= px + a)
			return 1;
		else
			return 0;
   end
   endfunction
	
	function check_6(integer x, integer y, integer px, integer py, integer a, integer width);
   begin
		if(y >= py && y <= py + a/2 && x >= px + a-width && x <= px + a)
			return 1;
		else
			return 0;
   end
   endfunction
	
	function check_7(integer x, integer y, integer px, integer py, integer a, integer width);
   begin
		if(y >= py + 0 && y <= py + width && x >= px + 0 && x <= px + a)
			return 1;
		else
			return 0;
   end
   endfunction
		
endmodule