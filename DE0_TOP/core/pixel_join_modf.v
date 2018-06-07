//---------------------------------------------------------------------------------
//------------------------------ PIXEL JOIN MODIF---------------------------------------
//
// Module that joins the output pixel from every component and decides which one 
//	to print.
//
//
// Most important signals:
//		* Parameters:
//				* WIDTH 				- the number of input component (width of the device).
//				* BACKGROUND		- default background.
// 	* Input signals:
//				* enable 			- array of enable signals statig if that component is
//					 					  actively outputing.
//				* layer				- array of ints stating the layer (order) of the component.
//				* pixel 				- an array of pixels from the components.
// 	* Output Signals:
//				* out					- the selected pixel that will be outputed to the screen.
//				* collision_num	- num of colliding pixels.
//----------------------------------------------------------------------------------

module pixel_join_modif
		#(
			parameter WIDTH = 2,
			parameter BACKGROUND = GREEN
		)
		(
			input wire clock,
			input wire reset,
			input wire enable [WIDTH-1 : 0],
			input integer level [WIDTH-1 : 0],
			input wire [11:0] pixel [WIDTH-1 : 0],
			output wire [11:0] out,
			output integer collision_num
		);
		
		integer num_reg, num_next;
		
		
		always @(posedge clock, posedge reset)
		begin
			if(reset)
			begin
				num_reg = 0;
			end
			else
			begin
				num_reg = num_next;
			end
		end
		
		assign collision_num = num_reg;
		
		pixel_join #(WIDTH, BACKGROUND)
		px(.enable(enable), .level(level), .pixel(pixel), .out(out), .collision_num(num_next));
		
		
endmodule