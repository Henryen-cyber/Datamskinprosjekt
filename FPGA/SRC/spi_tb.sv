module tb();
    logic mosi, miso, ssel_, sck, led;
    logic clk;
    logic[7:0] data_out;

    spi_interface DUT(
        .clk(clk),
        .mosi(mosi),
        .miso(miso),
        .ssel_(ssel_),
        .sck(sck),
        .led(led),
        .data_out(data_out)
    );

    always #1 clk = ~clk;
    always #5 sck = ~sck;

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
        $display("%h", DUT.ssel_endmessage);
        #10 $finish;
    end

    property a;
        always @(posedge clk) DUT.ssel_endmessage |-> data_out == 8'b011001000;
    endproperty

    assert property (a) begin
        $display("Correct output");
    end else begin
        $error("Data out is wrong!");
    end
endmodule


