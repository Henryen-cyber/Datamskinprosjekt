interface in_spi ();
    int ErrCntAssertions;

    logic clk;
    logic mosi;
    logic miso;
    logic ssel_;
    logic sck;

    logic[7:0] data_out;
endinterface
