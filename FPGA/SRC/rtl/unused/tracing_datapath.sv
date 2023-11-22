module TracingFSM (
    
    input  logic      clk,
    input  logic      valid,
    input  logic      finished,
    output logic      next_sphere,
    output logic[1:0] index
    
    );

    logic[1:0] index_cnt;

    enum int unsigned { IDLE = 0, CALCULATING = 1 } CURRENT_STATE NEXT_STATE;

    always_comb begin : data_logic
        case(CURRENT_STATE)
            IDLE: begin
               next_sphere <= 1;
               index <= index_cnt;
               if (valid) begin
                   NEXT_STATE <= CALCULATING;
               end else begin
                   NEXT_STATE <= IDLE;
               end
            end

            CALCULATING: begin
                if(finished) begin
                    NEXT_STATE <= IDLE;
                end else begin
                    NEXT_STATE <= CALCULATING;
                end
            end
        endcase
    end

    always @(posedge clk) begin : next_state_logic
        CURRENT_STATE <= NEXT_STATE;
    end
endmodule
