module speed (clock, faster, slower, default_speed, adjust);


input logic clock, faster, slower, default_speed;
output logic [15:0] adjust;

    always_ff @(posedge clock) begin         //always block on the positive edge of the block
        if (default_speed)
                adjust <= 0;                 //for the default

        else if (faster)
            adjust <= adjust + 8'h1;         //for faster we add 1 hex to the adjust

        else if (slower)
            adjust <= adjust - 8'h1;         //for slower we deduct 1 hex from the adjust

        else
            adjust <= adjust;                //or else we keep the adjust as it is
    end                                      //ending always block
endmodule                                    //ending module





