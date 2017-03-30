module mux8_1(input logic [2:0] select, input logic [31:0] mux1, mux2, mux3, mux4, mux5, mux6, mux7, mux8,
	output logic [31:0] output_freq, output logic [7:0] char1, char2, char3);
	always
		begin
			case(select) //part A switches
			 3'b000: begin
							output_freq=mux1;
							char1=8'h44;
							char2=8'h6F;
							char3=8'h20;
						end
			 3'b001: begin
							output_freq=mux2;
							char1=8'h52;
							char2=8'h65;
							char3=8'h20;
						end
			 3'b010: begin
							output_freq=mux3;
							char1=8'h4D;
							char2=8'h69;
							char3=8'h20;
						end
			 3'b011: begin
							output_freq=mux4;
							char1=8'h46;
							char2=8'h61;
							char3=8'h20;
						end
			 3'b100: begin
							output_freq=mux5;
							char1=8'h53;
							char2=8'h6F;
							char3=8'h20;
						end
			 3'b101: begin
							output_freq=mux6;
							char1=8'h4C;
							char2=8'h61;
							char3=8'h20;
						end
			 3'b110: begin
							output_freq=mux7;
							char1=8'h54;
							char2=8'h69;
							char3=8'h20;
						end
			 3'b111:  begin
							output_freq=mux8;
							char1=8'h44;
							char2=8'h6F;
							char3=8'h32;
						end
		endcase
		end
endmodule