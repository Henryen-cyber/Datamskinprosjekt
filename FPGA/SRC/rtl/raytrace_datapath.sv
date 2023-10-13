module RayTraceDatapath (
    
    // Clock
    input  logic clk,
    // Internal core control signals    
    input  logic start,
    input  logic pixel_done,
    input  logic next_sphere,
    // Outwards control signal 
    output logic busy

    );

    logic next_sphere;
    logic pixel_done;

    enum int unsigned { START = 0, TRACING = 1 } CURRENT_STATE NEXT_STATE;

    always_comb begin : data_logic
        case (CURRENT_STATE)
            START: begin
                busy <= 0;
                if(start) begin
                    NEXT_STATE <= TRACING;
                end else begin
                    NEXT_STATE <= START;
                end
            end

            TRACING: begin
               busy <= 1;
               if(next_sphere) begin
                   NEXT_STATE <= TRACING;
               end else if (pixel_done) begin
                   NEXT_STATE <= START;  
               end 
            end
        endcase
    end

    always @(posedge clk) begin : next_state_logic
        CURRENT_STATE <= NEXT_STATE;
    end
endmodule
