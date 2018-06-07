
//---------------------------------------------------------------------------------
//------------------------------ PIXEL JOIN ---------------------------------------
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

`include "constants.vh"

module pixel_join
		#(
			parameter WIDTH = 2,
			parameter BACKGROUND = GREEN
		)
		(
			input wire enable [WIDTH-1 : 0],
			input integer level [WIDTH-1 : 0],
			input wire [11:0] pixel [WIDTH-1 : 0],
			output wire [11:0] out,
			output integer collision_num
		);
	
	//=============================
	// Signals.
	//=============================
	
	// Signal that selects the pixel with the highest level.
	integer select;
	
	
	//=============================
	// Instances.
	//=============================
	collision_counter #(.WIDTH(WIDTH)) cc(.enable(enable), .number(collision_num));
	
	
	//=============================
	// Program.
	//=============================
	
	initial 
	begin
		select = -1;	
	end
	

	assign out = select >= 0? pixel[select]: BACKGROUND;
		
	always @(*)
	begin
		// Iterator.
		integer i;
		
		// Current maximum level.
		integer max;
		
		// Local select.
		integer local_sel;
		
		max = 0;
		local_sel = -1;
		
		for(i = 0; i< WIDTH; i++)
		begin
			if(enable[i] * level[i] > max)
			begin
				local_sel = i;
				max = enable[i] * level[i];
			end
		end
		select = local_sel;
	end	
		
endmodule