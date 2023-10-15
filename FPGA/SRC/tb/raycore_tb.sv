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
        world.sphere.origin.x <= 0;
        world.sphere.origin.y <= 0;
        world.sphere.origin.z <= 0;
        world.sphere.radius <= 9'b000000111;

        pixel.x <= -320;
        pixel.y <= 240;
        pixel.z <= 15;

        #200 $finish;
    end

    always #1 clk <= ~clk;

endmodule
