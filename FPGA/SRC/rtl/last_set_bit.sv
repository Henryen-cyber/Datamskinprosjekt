/////////////////////////////////////////////////////
// Module retrieved from user gsw73 on github link://
//     https://github.com/gsw73/find_first_set     //
/////////////////////////////////////////////////////

module last_set#(parameter WIDTH=12)(

    input  logic clk,
    input  logic rst_,
    input  logic start,

    input  logic[WIDTH-1:0] fixed_point_vector,
    output logic[5:0]       location
    );

    logic[WIDTH-5:0] int_vector;

    always_ff @(posedge clk) begin

        if(start) begin
            int_vector <= fixed_point_vector >> 4; // We want the first set bit of the integer
                                                   // representation of the vector
            if(!rst_) begin
                location <= 'd0;
            end else begin
                for(integer i = WIDTH - 1; i >= 0; i--) begin
                    if(int_vector[i]) begin
                        if(i[0]) begin
                            location <= ((i >> 1) + 1) << 4; // Bit-shift to include fixed point bits
                            break;
                        end else begin
                            location <= (i >> 1) << 4;
                            break;
                        end
                    end
                end
            end
        end
    end

endmodule
