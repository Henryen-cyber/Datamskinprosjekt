module assertions_spi (
    input logic         clk,
    input logic         mosi,
    input logic         miso,
    input logic         sck,
    input logic         ssel_,
    output logic[7:0]   data_out
);
