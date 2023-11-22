module SPI_Slave_Acc#(N_BYTES=8) (
    input logic rst_,
    input logic clk,
    input logic [7:0] i_RX_Byte,
    input logic i_RX_DV,
    output logic o_Acc_DV,
    output logic [N_BYTES*8-1:0] o_Acc_Bytes
);

    logic [3:0] RX_Byte_Count;

    logic [N_BYTES*8-1:0] Temp_Acc_Bytes;

    always @(posedge clk)
    begin
        if (~rst_) begin
            RX_Byte_Count <= 0;
            o_Acc_DV <= 0;
        end
        if (i_RX_DV)
        begin
            RX_Byte_Count <= RX_Byte_Count + 1;
            Temp_Acc_Bytes <= {Temp_Acc_Bytes[N_BYTES*7-1:0], i_RX_Byte};

            if (RX_Byte_Count == N_BYTES - 1) begin
                o_Acc_DV <= 1;
                o_Acc_Bytes <= {Temp_Acc_Bytes[N_BYTES*7-1:0], i_RX_Byte};
            end
        end
        else if (o_Acc_DV == 1) begin
            o_Acc_DV <= 0;
            RX_Byte_Count <= 0;
        end

    end


endmodule
