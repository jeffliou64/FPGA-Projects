module fill_led(input logic [7:0] inputled,
					 output logic [7:0] outled);
	
	logic [3:0] number;
	
	always
	begin
		case(inputled)
			8'b1XXXXXXX : number = 8;
			8'b01XXXXXX : number = 7;
			8'b001XXXXX : number = 6;
			8'b0001XXXX : number = 5;
			8'b00001XXX : number = 4;
			8'b000001XX : number = 3;
			8'b0000001X : number = 2;
			8'b00000001 : number = 1;
			default: number = 0;
		endcase
	end
	always
	begin
		case(number)
			8 : outled = 8'b11111111;
			7 : outled = 8'b11111110;
			6 : outled = 8'b11111100;
			5 : outled = 8'b11111000;
			4 : outled = 8'b11110000;
			3 : outled = 8'b11100000;
			2 : outled = 8'b11000000;
			1 : outled = 8'b10000000;
			default: outled = 8'b00000000;
		endcase
	end
endmodule