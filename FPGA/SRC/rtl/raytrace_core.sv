`include "types.sv"

module RayTracerCore (

    input logic clk,
    input World
);

    Ray ray;
    logic[16:0] xa_r, ya_r;
    logic[6:0]  za_r;
    logic[8:0]  radius;
    logic[34:0] xb_r, yb_r, zb_r;
    logic[30:0] xc_r, yc_r, zc_r;
    logic[]
    // And more to come!! Everything is multiplied so vectors keep getting
    // larger and larger smh... 
