`include "types.sv"
module RayTraceCore(

    input logic clk,

    input World_s world,
    input Pixel_s pixel,

    output logic less_than_zero

    );


    logic signed[50:0] temp_r;
    logic signed[50:0] a_r;
    logic signed[50:0] c_r;
    logic signed[50:0] b_r;
    logic signed[50:0] dis_r;

    always @(posedge clk) begin
        c_r <= (world.sphere.origin.x ** 2 + world.sphere.origin.y ** 2 + world.sphere.origin.z ** 2) - world.sphere.radius ** 2;
        b_r <= ((pixel.x * world.sphere.origin.x + pixel.y * world.sphere.origin.y + pixel.z * world.sphere.origin.z) * 2);
        a_r <= (pixel.x ** 2 + pixel.y ** 2 + pixel.z ** 2);
        temp_r <= ((a_r * c_r) * 4);
        dis_r <= b_r ** 2 - temp_r;
        if(dis_r < 0) begin
            less_than_zero <= 1'b1;
        end else begin
            less_than_zero <= 1'b0;
        end
    end
endmodule
