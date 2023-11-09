`timescale 1ns / 1ps

module spi_64_tb(

    );
    

    logic i_Rst_L = 0;
    logic i_Clk = 1;
    logic o_RX_DV;
    logic [7:0] o_RX_Byte;
    logic o_Acc_DV;
    logic [63:0] o_Acc_Bytes;
    // logic i_TX_DV;
    // logic i_TX_Byte;

    logic i_SPI_Clk = 1;
    logic o_SPI_MISO;
    logic i_SPI_MOSI = 0;
    logic i_SPI_CS_n = 1;

    

    SPI_Slave slave (
    .i_Rst_L(i_Rst_L),    // FPGA Reset, active low
    .i_Clk(i_Clk),      // FPGA Clock
    .o_RX_DV(o_RX_DV),    // Data Valid pulse (1 clock cycle)
    .o_RX_Byte(o_RX_Byte),  // Byte received on MOSI
    // .i_TX_DV(i_TX_DV),    // Data Valid pulse to register i_TX_Byte
    // .i_TX_Byte(i_TX_Byte),  // Byte to serialize to MISO.
    // SPI Interface
    .i_SPI_Clk(i_SPI_Clk),
    .o_SPI_MISO(o_SPI_MISO),
    .i_SPI_MOSI(i_SPI_MOSI),
    .i_SPI_CS_n(i_SPI_CS_n)  
    );

    SPI_Slave_Acc dut (
        .rst_(i_Rst_L),
        .clk(i_Clk),
        .i_RX_DV(o_RX_DV),
        .i_RX_Byte(o_RX_Byte),
        .o_Acc_DV(o_Acc_DV),
        .o_Acc_Bytes(o_Acc_Bytes)
    );



    initial begin 
        #3 i_Rst_L = 1;

        #4 i_SPI_CS_n = 0;
        i_SPI_MOSI = 1;

        #8 i_SPI_MOSI = 0;

        #8 i_SPI_MOSI = 1; 

        #522 i_SPI_CS_n = 1;

        #1000 $finish;
    end

    always #1 i_Clk = ~i_Clk;
    always #4 i_SPI_Clk = ~i_SPI_Clk;


endmodule
