//---------------------------------------------------------------------------------
//--------------------------------- CONSTANTS -------------------------------------
//
// Contains the global constants, which are referenced from other modules
//---------------------------------------------------------------------------------

`ifndef _constants_h
`define _constants_h
	
	// Update modes.
	localparam NO_ACTION 	= 0;
	localparam RESET 			= 1;
	localparam FULL_RESET	= 2;
	localparam BOUNCE 		= 3;
	
	// Basic colors.
	localparam RED = 		12'b111100000000;
	localparam GREEN = 	12'b000011110000;
	localparam BLUE = 	12'b000000001111;
	localparam BLACK = 	12'b000000000000;
	localparam WHITE = 	12'b111111111111;
	
	// Basic object types.
	localparam SQUARE 	= 	1;
	localparam CIRCLE 	=	2;
	localparam TRIANGLE 	= 	3;
	localparam RECTANGLE = 	4;
	localparam TEXT		=  5;
	
	// Screen constants
	localparam X_DISPLAY = 800;
	localparam Y_DISPLAY = 600;
	
	// Update.
	localparam GLOBAL_RENDERER_PERIOD 	= 100;
	localparam GLOBAL_PHYSICS_PERIOD 	= 10;
	
	// Player controls.
	localparam UP 		= 0;
	localparam DOWN 	= 1;
	localparam LEFT 	= 2;
	localparam RIGHT	= 3;
	
	// Key Codes
	localparam TERMINATE    = 8'hF0;
	localparam DUMMY			= 8'd0;
	
	localparam ARROW_UP 		= 8'h75;	
	localparam ARROW_DOWN 	= 8'h72;
	localparam ARROW_LEFT 	= 8'h6B;
	localparam ARROW_RIGHT 	= 8'h74;
	
	localparam W 				= 8'h1D;
	localparam S 				= 8'h1B;
	localparam A 				= 8'h1C;
	localparam D 				= 8'h23;
	
	localparam SPACE			= 8'h29;
	localparam ESC				= 8'h76;
	
		
`endif