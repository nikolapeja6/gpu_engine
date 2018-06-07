
//---------------------------------------------------------------------------------
//-------------------------------- COLLISION COUNTER ------------------------------
//
// Counts the number of collisions by counting the number of enabled signals 
// with the value of 1.
//
//
// Most important signals:
//		* Parameters:
//				* WIDTH 	- the number of input component (width of the device).
// 	* Input signals:
//				* enable 			- array of enable signals statig if that component is
//					 					  actively outputing.
// 	* Output Signals:
//				* collision_num	- num of colliding pixels.
//----------------------------------------------------------------------------------

module collision_counter
		#(
			parameter WIDTH = 2
		)
		(
			input wire enable [WIDTH-1 : 0],
			output integer number
		);

	//=============================
	// Signals.
	//=============================
	
	// Counter.
	integer counter;
	
	//=============================
	// Program.
	//=============================
	
	initial 
	begin
		counter = 0;	
	end
	

	assign number = counter;
	
	
	always @(*)
	begin
		// Iterator.
		integer i;
		
		// Local counter.
		integer local_cnt;
		
		local_cnt = 0;
		
		for(i = 0; i< WIDTH; i++)
		begin
			if(enable[i])
			begin
				local_cnt = local_cnt + 1;
			end
		end
		
		counter = local_cnt;
	end	
		
		

endmodule