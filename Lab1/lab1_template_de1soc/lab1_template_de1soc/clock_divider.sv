module clock_divider(input logic inclock, reset, 
input logic [31:0] div_clock_count, 
output logic outclock);

	logic [16:0] count;
	
always_ff @(posedge inclock)
	begin
		if (count == div_clock_count) begin
			count <= 17'b0;
			outclock <= !outclock;
			end
		else
			count <= count + 1'b1;
	end
endmodule

//		if(!reset) begin
//			//count <= 32'b0;
//			outclock <= 1'b0;
//			end	