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

    logic found;
    logic setup_finished;

    always_ff @(posedge clk) begin
        if(start) begin
            if (!setup_finished) begin
                int_vector <= fixed_point_vector >> FP_B;   // We want the first set bit of the integer
                                                            // representation of the vector
                setup_finished <= 1;
            end
            else if (found) begin    
                location_valid <= 1;           
            end
            else begin
                if(!rst_) begin
                    location <= 'd0;
                end else if (~found) begin
                    for(integer i = WIDTH - FP_B - 1; i >= 0; i--) begin
                        if(int_vector[i]) begin
                            location <= i + 1;
                            found <= 1;
                            break;
                        end
                    end
                end 
            end
        end else begin 
           location_valid <= 0;
           found <= 0;
           setup_finished <= 0;
        end

    end
endmodule
