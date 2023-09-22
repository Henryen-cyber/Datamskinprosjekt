module tb();
    logic mosi, miso, ssel_, sck, led;
    logic clk;

    spi_interface DUT(
        .clk(clk),
        .mosi(mosi),
        .miso(miso),
        .ssel_(ssel_),
        .sck(sck),
        .led(led)
    );

    initial begin
        clk = 0;
        sck = 0;
        ssel_ = 1;
        #5 ssel_ = 0;
        #5 mosi = 1;
        #5 mosi = 1;
        #5 mosi = 0;
        #5 mosi = 0;
        #5 mosi = 1;
        #5 mosi = 0;
        #5 mosi = 0;
        #5 mosi = 0;
        #10 $finish;
    end

    always #1 clk = ~clk;
    always #5 sck = ~sck;

    property p_led;
        always @(posedge sck) !ssel_ |-> led;
    endproperty

    assert property(p_led)
        else
            $error("Led is not in sync with ssel_");

endmodule


