module SR_tb();
    
    logic       clk;
    logic       rst_;
    logic       start;
    logic[7:0] A;
    logic[7:0] Q;

    SquareRoot SquareRoot_DUT(.clk(clk),
                              .rst_(rst_),
                              .start(start),
                              .A(A),
                              .Q(Q));

    initial begin
        clk <= 1'b1;
        A <= 12'b00001000_0000;
        start <= 1'b1;
        rst_ <= 1'b0;
        #10 rst_ <= 1'b1;
        #30 $finish;
    end

    always #1 clk <= ~clk;

endmodule
