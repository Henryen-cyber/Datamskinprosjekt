////////////////////////////////////////////////////////////////////////////
//                      Square root algorithm from:                       //
// https://iopscience.iop.org/article/10.1088/1742-6596/1314/1/012008/pdf //
////////////////////////////////////////////////////////////////////////////

`include "last_set_bit.sv"
`include "Types.sv"

module SquareRoot#(parameter N=16, parameter A_INT_B=8, parameter A_FP_B=4, parameter A_NORM_FP_B=16,
parameter A_FP_DIFF_B=A_NORM_FP_B - A_FP_B, parameter PADDED_FB_BITS=16
)(

    input  logic clk,
    input  logic rst_,
    input  logic[A_INT_B + A_FP_B - 1:0] A, // Input value has 4 fixed point bits
	input  logic start,

    output logic busy,
    output logic[`DIS_SQRT_B-1:0] Q // Output value has 16 fixed point bits

    );

    logic find_m_s;
    logic m_valid;
    logic [A_NORM_FP_B:0] A_norm; // 16 Fixed point bits
    logic c_k_less_than_A_norm;
    logic [5:0] two_times_m;
    logic [4:0] k;
    logic signed[A_NORM_FP_B:0] x_k; // 16 Fixed point bits
    logic signed[A_NORM_FP_B:0] x_k1;// 16 Fixed point bits
    logic signed[A_NORM_FP_B + PADDED_FB_BITS:0] x_k_padded; // 32 Fixed point bits
    logic signed[39:0] c_k; // 32 Fixed point bits
    logic signed[39:0] c_k1;// 32 Fixed point bits

    last_set#(.WIDTH(A_INT_B + A_FP_B), .FP_B(A_FP_B)) find_m(.clk(clk),
                    .rst_(rst_),
                    .start(find_m_s),
                    .fixed_point_vector(A),
                    .location(two_times_m),
                    .location_valid(m_valid));

    enum { IDLE, START, LOOP, UPDATE, DONE } CURRENT_STATE, NEXT_STATE;

    always_comb begin : data_logic
        case(CURRENT_STATE)

            IDLE : begin

                x_k <= 0;
                x_k1 <= 0;
                c_k <= 0;
                c_k1 <= 0;
                A_norm <= 0;
                c_k_less_than_A_norm <= 0;
                Q <= 0;
                find_m_s <= 0;
                busy <= 0;
                if(start) begin
                    NEXT_STATE <= START;
                end else begin
                    NEXT_STATE <= IDLE;
                end
            end

            START : begin
                x_k <= 0;
                x_k1 <= 0;
                c_k <= 0;
                c_k1 <= 0;
                find_m_s <= 1;
                busy <= 1;
                if(m_valid && two_times_m) begin
                    A_norm <= {A, A_FP_DIFF_B'('b0)} >> (two_times_m + 1);
                    NEXT_STATE <= LOOP;
                end else begin
                    NEXT_STATE <= START;
					A_norm <= A_norm;
                end
                c_k_less_than_A_norm <= 0;
                Q <= 0;
            end

            LOOP : begin
                c_k_less_than_A_norm = c_k < {A_norm, A_NORM_FP_B'('b0)};
                x_k_padded = {x_k, A_NORM_FP_B'('b0)};
                if(c_k_less_than_A_norm) begin
                    x_k1 = x_k + (`SR_ONE >>> (k + 1));
                    c_k1 = c_k + ((x_k_padded >>> (k))) + (`SR_ONE >>> (2 * (k + 1)));
                end else if(!c_k_less_than_A_norm || c_k == A_norm) begin
                    x_k1 = x_k - (`SR_ONE >>> (k + 1));
                    c_k1 = c_k - ((x_k_padded >>> (k))) + (`SR_ONE >>> (2 * (k + 1)));
                end
                x_k <= x_k;
                c_k <= c_k;
                A_norm <= A_norm;
                Q <= 0;
                find_m_s <= 0;
                NEXT_STATE <= UPDATE;
            end

            UPDATE : begin
                find_m_s <= 0;
                c_k_less_than_A_norm <= c_k_less_than_A_norm;
                x_k1 <= x_k1;
                c_k1 <= c_k1;
                x_k <= x_k1;
                c_k <= c_k1;
                Q <= 0;
                if(k == N - 1) begin
                    NEXT_STATE <= DONE;
                end else begin
                    NEXT_STATE <= LOOP;
                end
            end

            DONE : begin
                // Needs some work to properly account for fixed point bits!
                Q <= (x_k <<< ((two_times_m >> 1) + 1)) >>> A_FP_DIFF_B;
                find_m_s <= 0;
                x_k <= x_k;
                x_k1 <= x_k1;
                c_k <= c_k;
                c_k1 <= c_k1;
                A_norm <= A_norm;
                c_k_less_than_A_norm <= c_k_less_than_A_norm;
                busy <= 0;
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
        if(CURRENT_STATE == IDLE) begin
            k <= 0;
        end
        else if(CURRENT_STATE == UPDATE) begin
            k <= k + 1;
        end
    end
endmodule
