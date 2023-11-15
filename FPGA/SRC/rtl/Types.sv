`ifndef TYPES
//////////////////////////////////
//  Definitions and parameters  //
//////////////////////////////////
`define SR_FIXED_POINT_BITS 16
`define FIXED_POINT_BITS 4
`define SR_ONE 17'b10000000000000000
`define SR_C_ONE 33'b100000000000000000000000000000000

`define FP_B 3
`define PX_X_B 10
`define PX_X_SQRD_B 18

`define PX_Y_B 9
`define PX_Y_SQRD_B 16

`define S_X_INT_B 13
`define S_X_FP_B 3

`define S_Y_INT_B 12
`define S_Y_FP_B 3

`define S_Z_INT_B 12
`define S_Z_FP_B 3

`define S_X_SQRD_B 27
`define S_Y_SQRD_B 25
`define S_Z_SQRD_B 27
`define S_R_SQRD_B 18

`define DOT_X_B 25
`define DOT_Y_B 23
`define DOT_Z_B 24

`define TWO_A_B 20
`define B_B 28
`define B_SQRD_B 51
`define TWO_C_B 30

`define A_TIMES_C_B 50
`define DIS_B 51
`define DIS_SQRT_B 27

`define DIST_B 25

`define INTERSECT_X_B 31
`define INTERSECT_Y_B 30
`define INTERSECT_Z_B 31

`define BACKGROUND_COLOR 12'h036

//////////////////////////////////
// Data collections and structs //
//////////////////////////////////

typedef struct packed {
    logic [3:0] r;
    logic [3:0] g;
    logic [3:0] b;
} Color;

typedef struct packed {
    logic signed [`S_X_INT_B + `S_X_FP_B - 1:0] x;
    logic signed [`S_Y_INT_B + `S_Y_FP_B - 1:0] y;
    logic signed [`S_Z_INT_B + `S_Z_FP_B - 1:0] z;
    logic signed [5:0] r;
    logic signed [11:0] c;
} Sphere;

//typedef struct {
//    Sphere sphere_0;
//    Sphere sphere_1;
//    Sphere sphere_2;
//    Sphere sphere_3;
//} World;

typedef struct {
    Sphere spheres[4];
} World;
// SIZES

// Viewport width: 640
// Viewport height: 480
// VIewport focal length: 640 / 2 = 320 (90 deg)
`define TYPES
`endif
