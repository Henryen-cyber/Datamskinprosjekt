/////////////////////////////////////////////////////
// Module retrieved from user gsw73 on github link://
//     https://github.com/gsw73/find_first_set     //
/////////////////////////////////////////////////////

module last_set#(parameter WIDTH=16, parameter FP_B = 4)(

    input  logic clk,
    input  logic rst_,
    input  logic start,

    input  logic[WIDTH - 1:0] fixed_point_vector,
    output logic[5:0]       location,
    output logic            location_valid
    );

    logic[WIDTH-FP_B-1:0] int_vector;
    logic[5:0] temp_location;

    always_ff @(posedge clk) begin

        if(start) begin
            int_vector <= fixed_point_vector >> FP_B; // We want the first set bit of the integer
                                                   // representation of the vector
            if(!rst_) begin
                location <= 'd0;
            end else begin
                for(integer i = WIDTH - FP_B - 1; i >= 0; i--) begin
                    if(int_vector[i]) begin
                        location <= i;
                        location_valid <= 1;
                        break;
                        // if(temp_location[0]) begin
                        //     location <= ((temp_location + 1) >> 1);
                        //     location_valid <= 1;
                        //     break;
                        // end else begin
                        //     location <= (temp_location >> 1);
                        //     location_valid <= 1;
                        //     break;
                        // end
                    end else begin
                        location_valid <= 0;
                    end
                end
            end
        end
    end
endmodule
