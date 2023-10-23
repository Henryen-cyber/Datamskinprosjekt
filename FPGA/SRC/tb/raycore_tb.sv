module raytrace_core_tb(
    );
    
    logic clk;

    World_s world;
    Pixel_s pixel;

    logic less_than_zero;

    RayTraceCore DUT(.clk(clk),
                     .world(world),
                     .pixel(pixel),
                     .less_than_zero(less_than_zero));

    initial begin
        clk <= 1;
        world.sphere.origin.x <= -32768;
        world.sphere.origin.y <= -8192;
        world.sphere.origin.z <= -32768;
        world.sphere.radius <= 511;

        pixel.x <= 320;
        pixel.y <= 240;
        pixel.z <= 31;

        #10 $finish;
    end

    always #1 clk <= ~clk;

endmodule
