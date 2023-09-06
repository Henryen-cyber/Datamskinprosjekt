// adder.sv
// Module Description: superefficient ultraoptimized adder

module adder (
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] sum
);

    always_comb begin
        sum = a + b;
    end

endmodule : adder

module subtractor (
    input wire a,
    input wire b,
    output reg c
);

    always_comb begin
        c = a || b;
    end

endmodule : subtractor
