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
        world.sphere.origin.x <= 4'hffff;
        world.sphere.origin.y <= 14'b01111111111111;
        world.sphere.origin.z <= 4'hffff;
        world.sphere.radius <= 9'b111111111;

        pixel.x <= 320;
        pixel.y <= 240;
        pixel.z <= 31;

        #10 $finish;
    end

    always #1 clk <= ~clk;

endmodule
