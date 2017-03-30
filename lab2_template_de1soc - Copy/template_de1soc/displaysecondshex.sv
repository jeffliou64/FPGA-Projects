module displaysecondshex(input logic clk,							//input clock
								input logic direction,					//input direction
                        input logic readdatavalid, 			//input read data
                        input logic [22:0] address,			//input address
                        output logic [6:0] HEX5, HEX4);		//out for HEX displays
								
parameter number_0 = 7'b1000000;										//parametrizing LEDs to display a zero
parameter number_1 = 7'b1111001;										//parametrizing LEDs to display a one
parameter number_2 = 7'b0100100;										//parametrizing LEDs to display a two
parameter number_3 = 7'h0110000;										//parametrizing LEDs to display a three
parameter number_4 = 7'b0011001;										//parametrizing LEDs to display a four
parameter number_5 = 7'b1101101;										//parametrizing LEDs to display a five
parameter number_6 = 7'b0000011;										//parametrizing LEDs to display a six
parameter number_7 = 7'b1111000;										//parametrizing LEDs to display a seven
parameter number_8 = 7'b0000000;										//parametrizing LEDs to display a eight
parameter number_9 = 7'b0001000;										//parametrizing LEDs to display a nine

logic [3:0] sec;															//keeps track of the number of seconds passed
logic [13:0] hex;															//stores 2 8 bit values that will be passed to the HEX output
logic [15:0] count; 														//counting number of values that have been read

always_ff @(posedge readdatavalid) begin							//on the positive edge of readdatavalid always perform
    if (direction) begin												//if direction is true, begin
        if((count == 22000) && (address != 23'h7FFFF)) begin//if count is 22,000 and it has not reached the last address begin
            sec <= sec + 1;											//add one to sec
            count <= 0;													// resetting count to 0
            end															
        else if (address == 23'h7FFFF)								//if it reaches the last address
            sec <= 0;													//reset sec to 0
        else
            count <= count + 1;										//else increase count by 1
    end

    else begin
        if ((count == 22000) && (address != 0)) begin			//if count is 22000 and address is not 0
            sec <= sec - 1;
            count <= 0;
            end
        else if (address == 0)
            sec <= 48;
        else
            count <= count + 1;
            
    end

end

always_comb begin
    case (sec)
    0:  hex = {number_0, number_0};
    1:  hex = {number_0, number_1};
    2:  hex = {number_0, number_2};
    3:  hex = {number_0, number_3};
    4:  hex = {number_0, number_4};
    5:  hex = {number_0, number_5};
    6:  hex = {number_0, number_6};
    7:  hex = {number_0, number_7};
    8:  hex = {number_0, number_8};
    9:  hex = {number_0, number_9};
    10: hex = {number_1, number_0};
    11: hex = {number_1, number_1};
    12: hex = {number_1, number_2};
    13: hex = {number_1, number_3};
    14: hex = {number_1, number_4};
    15: hex = {number_1, number_5};
    16: hex = {number_1, number_6};
    17: hex = {number_1, number_7};
    18: hex = {number_1, number_8};
    19: hex = {number_1, number_9};
    20: hex = {number_2, number_0};
    21: hex = {number_2, number_1};
    22: hex = {number_2, number_2};
    23: hex = {number_2, number_3};
    24: hex = {number_2, number_4};
    25: hex = {number_2, number_5};
    26: hex = {number_2, number_6};
    27: hex = {number_2, number_7};
    28: hex = {number_2, number_8};
    29: hex = {number_2, number_9};
    30: hex = {number_3, number_0};
    31: hex = {number_3, number_1};
    32: hex = {number_3, number_2};
    33: hex = {number_3, number_3};
    34: hex = {number_3, number_4};
    35: hex = {number_3, number_5};
    36: hex = {number_3, number_6};
    37: hex = {number_3, number_7};
    38: hex = {number_3, number_8};
    39: hex = {number_3, number_9};
    40: hex = {number_4, number_0};
    41: hex = {number_4, number_1};
    42: hex = {number_4, number_2};
    43: hex = {number_4, number_3};
    44: hex = {number_4, number_4};
    45: hex = {number_4, number_5};
    46: hex = {number_4, number_6};
    47: hex = {number_4, number_7};
    48: hex = {number_4, number_8};
	 49: hex = {number_4, number_9};
    50: hex = {number_5, number_0};
	 51: hex = {number_5, number_1};
    52: hex = {number_5, number_2};
	 53: hex = {number_5, number_3};
    54: hex = {number_5, number_4};
	 55: hex = {number_5, number_5};
	 56: hex = {number_5, number_6};
	 57: hex = {number_5, number_7};
    58: hex = {number_5, number_8};
	 59: hex = {number_5, number_9};
    default: hex = {number_0, number_0};
endcase
end

always_ff @(posedge clk) begin
    {HEX5} = hex[13:7];													//output to HEX 5
    {HEX4} = hex[6:0];													//output to HEX 4
end
endmodule



