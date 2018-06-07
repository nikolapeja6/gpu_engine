
//---------------------------------------------------------------------------------
//---------------------------------- SHADER ---------------------------------------
//
// Generates a pixel with a specific RGB value in order to fill a desired object.
//
//
// Most important signals:
// 	* Parameters:
//				* BASE_COLOR 	- the base color of the object.
//				* LEVEL 			- the ordering level of the shader.
// 	* Input signals:
//				* x,y 			- coordinates of the pixel that should currently be printed.
//				* px, py 		- coordinates of the top left edge of the object.
//				* pause			- pause signal.
// 	* Output Signals:
//				* pixel 			- RGB value of the pixel.
//				* level			- the ordering level of the shader.
//----------------------------------------------------------------------------------

`include "constants.vh"

module shader
		#(
			parameter BASE_COLOR = RED,
			parameter LEVEL = 1
		)
		(
			input wire [9:0] x, y,
			input wire [9:0] px, py,
			output wire [11:0] pixel,
			output integer level, 
			input wire pause
		);
	
	// The output pixel.
	assign pixel = BASE_COLOR;

	// Level of the object.
	assign level = LEVEL;
		
endmodule