module tb;
    logic mosi, miso, ssel_, sck, led, ssel_endmessage, ssel_active;
    logic clk;
    logic [7:0] byte_data_recieved;
    
    logic [7:0] data_to_send = 8'b11110000;
    int i = 0;
    
    spi_interface DUT_spi(.*);

    always #1 clk = ~clk;
    always #3 sck = ~sck;

    initial begin
        #0 ssel_ = 1;
        #6 ssel_ = 0;
        @(posedge sck);
        if(ssel_active) begin
            mosi = data_to_send[i];
            i++;
        end else begin
            $display("ssel_ is high");
        end
        #30 ssel_ = 1;
        #31 $finish;
    end

    assert property ( @(posedge clk) ssel_endmessage |-> byte_data_recieved == 8'b11110000);

endmodule


