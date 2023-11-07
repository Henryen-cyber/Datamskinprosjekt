//////////////////////////////////
//  Definitions and parameters  //
//////////////////////////////////
`define SR_FIXED_POINT_BITS 16
`define FIXED_POINT_BITS 4
`define SR_ONE 17'b10000000000000000

//////////////////////////////////
// Data collections and structs //
//////////////////////////////////

package Types;

typedef struct packed {
    logic signed [15:0] x;
    logic signed [13:0] y;
    logic signed [15:0] z;
    logic signed [5:0] r;
    logic signed [11:0] c;
} Sphere;

typedef struct packed {
    logic [3:0] r;
    logic [3:0] g;
    logic [3:0] b;
} Color;

endpackage