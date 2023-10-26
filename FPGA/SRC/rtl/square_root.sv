////////////////////////////////////////////////////////////////////////////
//                      Square root algorithm from:                       //
// https://iopscience.iop.org/article/10.1088/1742-6596/1314/1/012008/pdf //
////////////////////////////////////////////////////////////////////////////

`include "last_set_bit.sv"
`include "types.sv"

module SquareRoot#(parameter N=16, parameter SR_ONE = 17'b10000000000000000)(

    input  logic clk,
    input  logic rst_,
    input  logic start,
    input  logic[11:0] A, // Input value has 4 fixed point bits

    output logic[23:0] Q // Output value has 16 fiex point bits

    );

    logic [11:0] A_norm;
    logic c_k_less_than_A_norm;
    logic [5:0] m;
    logic [3:0] k;
    logic signed[23:0] x_k;
    logic signed[23:0] x_k1;
    logic signed[39:0] c_k;
    logic signed[39:0] c_k1;
    logic signed[1:0] d_k;

    last_set find_m(.clk(clk),
                    .rst_(rst_),
                    .start(start),
                    .fixed_point_vector(A),
                    .location(m));

    enum { IDLE, START, LOOP, UPDATE, DONE } CURRENT_STATE, NEXT_STATE;
    
    always_comb begin : data_logic
        case(CURRENT_STATE)

            IDLE : begin
                k <= 0;
                x_k <= 0;
                x_k1 <= 0;
                c_k <= 0;
                c_k1 <= 0;
                d_k <= 0;
                A_norm <= 0;
                c_k_less_than_A_norm <= 0;
                Q <= 0;
                if(start) begin
                    NEXT_STATE <= START;
                end else begin
                    NEXT_STATE <= IDLE;
                end
            end

            START : begin
                k <= 0;
                x_k <= 0;
                x_k1 <= 0;
                c_k <= 0;
                c_k1 <= 0;
                d_k <= 0;
                A_norm <= A / ((2 ** (2 * m)) << 4);
                c_k_less_than_A_norm <= 0;
                NEXT_STATE <= LOOP;
                Q <= 0;
            end

            LOOP : begin
                c_k_less_than_A_norm <= c_k < A_norm;
                if(c_k_less_than_A_norm) begin
                    d_k <= 1;
                end else if(!c_k_less_than_A_norm) begin
                    d_k <= -1;
                end
                x_k1 <= x_k + (d_k * (SR_ONE >> k));
                c_k1 <= c_k + (d_k * ((x_k >> (k - 1)))) + (SR_ONE >> ( 2 * k ));
                x_k <= 0;
                c_k <= 0;
                A_norm <= A_norm;
                Q <= 0;
                NEXT_STATE <= UPDATE;
            end

            UPDATE : begin
                k <= k;
                c_k_less_than_A_norm <= c_k_less_than_A_norm;
                d_k <= d_k;
                x_k1 <= x_k1;
                c_k1 <= c_k1;
                x_k <= x_k1;
                c_k <= c_k1;
                Q <= 0;
                if(k == (N - 1)) begin
                    NEXT_STATE <= DONE;
                end else begin
                    NEXT_STATE <= LOOP;
                end
            end

            DONE : begin
                // Needs some work to properly account for fixed point bits!
                Q <= x_k * (2 ** m) >> (`SR_FIXED_POINT_BITS - `FIXED_POINT_BITS);
                k <= 0;
                x_k <= x_k;
                x_k1 <= x_k1;
                c_k <= c_k;
                c_k1 <= c_k1;
                d_k <= d_k;
                A_norm <= A_norm;
                c_k_less_than_A_norm <= c_k_less_than_A_norm;
                NEXT_STATE <= IDLE;
            end

        endcase
    end

    always_ff @(posedge clk) begin : next_state_logic
        if(rst_) begin
            CURRENT_STATE <= NEXT_STATE;
        end else if(!rst_) begin
            CURRENT_STATE <= IDLE;
        end
        if(CURRENT_STATE == UPDATE) begin
            k <= k + 1;
        end
    end
endmodule
