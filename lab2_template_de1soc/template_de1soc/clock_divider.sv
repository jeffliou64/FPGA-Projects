module clock_divider(input logic inclock, 
input logic [31:0] div_clock_count, 
output logic outclock);

	logic [31:0] count; //initializing a counter for the clock
	
always_ff @(posedge inclock) //only counts per clock cycle
	begin
		if (count > div_clock_count - 1 ) begin //compares count to the clock delay
			count <= 32'b0; 						  //if count has reached or is greater than the clock delay, reset clock and invert output signal
			outclock <= !outclock;
			end
		else
			count <= count + 1'b1;				  //if count has not reached our chosen value, continue counting
	end
endmodule
