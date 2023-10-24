module spi_interface(

    input clk,

    input logic mosi,
    input logic ssel_,
    input logic sck,
    output logic miso,
    output logic[7:0] data_out,
    output logic[7:0] led
);

    logic[2:0] sckr; always @(posedge clk) sckr <= {sckr[1:0], sck};
    logic sck_risingedge = (sckr[2:1] == 2'b01);
    logic sck_fallingedge = (sckr[2:1] == 2'b10);

    logic[2:0] sselr; always @(posedge clk) sselr <= {sselr[1:0], ssel_};
    logic ssel_active = ~sselr[1];
    logic ssel_startmessage = (sselr[2:1] == 2'b10);
    logic ssel_endmessage = (sselr[2:1] == 2'b01);

    logic[1:0] mosir; always @(posedge clk) mosir <= {mosir[0], mosi};
    logic mosi_data = mosir[1];
    
    logic[3:0] bit_cnt;

    logic byte_recieved;
    logic[7:0] byte_data_recieved;

    always @(posedge clk)
    begin
        if(~ssel_active)
            bit_cnt <= 4'b000;
        else if(sck_risingedge)
        begin
            bit_cnt <= bit_cnt + 4'b001;
            byte_data_recieved <= {byte_data_recieved[6:0], mosi_data};
        end
    end

    always @(posedge clk) byte_recieved <= ssel_active && sck_risingedge && (bit_cnt == 4'b1000);

    always_ff @(posedge clk) begin
        if(byte_recieved) begin
            led <= byte_data_recieved;
        end
    end

    logic[7:0] byte_data_sendt;
    logic[7:0] cnt;

    always @(posedge clk) if(ssel_startmessage) cnt <= cnt + 8'h1;

    always @(posedge clk) begin
        if(ssel_active)
        begin
            if(ssel_startmessage)
                byte_data_sendt <= cnt;
            else if(sck_fallingedge)
            begin
                if(bit_cnt == 3'b000)
                    byte_data_sendt <= 8'h00;
                else
                    byte_data_sendt <= {byte_data_sendt[6:0], 1'b0};
            end
        end
        miso <= byte_data_sendt[7];

        if(ssel_endmessage) begin
            data_out <= byte_data_sendt;
        end
    end
endmodule
