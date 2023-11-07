////////////////////////////////////////////////////////////////////////////
//                      Square root algorithm from:                       //
// https://iopscience.iop.org/article/10.1088/1742-6596/1314/1/012008/pdf //
////////////////////////////////////////////////////////////////////////////

`include "last_set_bit.sv"
`include "types.sv"

module SquareRoot#(parameter N=16)(

    input  logic clk,
    input  logic rst_,
    input  logic[11:0] A, // Input value has 4 fixed point bits
	input  logic start,

    output logic[23:0] Q // Output value has 16 fiex point bits

    );

    logic find_m_s;
    logic m_valid;
    logic [23:0] A_norm; // 16 Fixed point bits
    logic c_k_less_than_A_norm;
    logic [5:0] m;
    logic [4:0] k;
    logic signed[23:0] x_k; // 16 Fixed point bits
    logic signed[23:0] x_k1;// 16 Fixed point bits
    logic signed[39:0] x_k_padded; // 32 Fixed point bits
    logic signed[39:0] c_k; // 32 Fixed point bits
    logic signed[39:0] c_k1;// 32 Fixed point bits

    last_set find_m(.clk(clk),
                    .rst_(rst_),
                    .start(find_m_s),
                    .fixed_point_vector(A),
                    .location(m),
                    .location_valid(m_valid));

    enum { IDLE, START, LOOP, UPDATE, DONE } CURRENT_STATE, NEXT_STATE;
    
    always_comb begin : data_logic
        case(CURRENT_STATE)

            IDLE : begin
                k <= 0;
                x_k <= 0;
                x_k1 <= 0;
                c_k <= 0;
                c_k1 <= 0;
                A_norm <= 0;
                c_k_less_than_A_norm <= 0;
                Q <= 0;
                find_m_s <= 0;
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
                find_m_s <= 1;
                if(m_valid && m) begin
                    A_norm <= {A >> (2 * m), 12'b0};
                    NEXT_STATE <= LOOP;
                end else begin
                    NEXT_STATE <= START;
					A_norm <= A_norm;
                end
                c_k_less_than_A_norm <= 0;
                Q <= 0;
            end

            LOOP : begin
                c_k_less_than_A_norm = c_k < {A_norm, 16'b0};
                x_k_padded = {x_k, 16'b0};
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
                k <= k;
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
                Q <= x_k <<< m;
                find_m_s <= 0;
                k <= k;
                x_k <= x_k;
                x_k1 <= x_k1;
                c_k <= c_k;
                c_k1 <= c_k1;
                A_norm <= A_norm;
                c_k_less_than_A_norm <= c_k_less_than_A_norm;
                NEXT_STATE <= IDLE;
            end

        endcase
    end

    always_ff @(posedge clk, negedge rst_) begin : next_state_logic
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
