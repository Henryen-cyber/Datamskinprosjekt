module SR_tb();
    
    logic       clk;
    logic       rst_;
    logic       start;
    logic[11:0] A;
    logic[23:0] Q;

    SquareRoot SquareRoot_DUT(.clk(clk),
                              .rst_(rst_),
                              .A(A),
                              .start(start),
                              .Q(Q));

    initial begin
        clk <= 1'b1;
        A <= 12'b111100000000;
        start <= 1'b1;
        rst_ <= 1'b1;
        #150 $finish;
    end

    always #1 clk <= ~clk;

endmodule
