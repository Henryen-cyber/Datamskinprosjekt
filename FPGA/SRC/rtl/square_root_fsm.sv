module SquareRoot_FSM#(parameter N=16) (
    input  logic start,
    input  logic clk,
    input  logic rst_,
    input  logic[3:0] k,
    
    output logic[1:0] state
    );

    enum {IDLE, START, LOOP, DONE} CURRENT_STATE, NEXT_STATE;

    always_comb begin : data_logic
        case(CURRENT_STATE)
            IDLE : begin
                state <= 2'b00;
                if(start == 1'b1) begin
                    NEXT_STATE <= START;
                end else begin
                    NEXT_STATE <= CURRENT_STATE;
                end
            end

            START : begin
                state <= 2'b01;
                NEXT_STATE <= LOOP;
            end

            LOOP : begin
                state <= 2'b10;
                if(k == N) begin
                    NEXT_STATE <= DONE;
                end else begin
                    NEXT_STATE <= CURRENT_STATE;
                end
            end

            DONE : begin
                state <= 2'b11;
                NEXT_STATE <= IDLE;
            end
        endcase
    end
    
    always_ff @(posedge clk) begin : next_state_logic
        CURRENT_STATE <= NEXT_STATE;
    end

endmodule
