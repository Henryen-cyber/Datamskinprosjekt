module SR_tb();
    
    logic       clk;
    logic       rst_;
    logic       start;
    logic[11:0] A;
    logic[11:0] Q;

    SquareRoot SquareRoot_DUT(.clk(clk),
                              .rst_(rst_),
                              .start(start),
                              .A(A),
                              .Q(Q));

    initial begin
        clk <= 1'b1;
        A <= 12'b000100000000;
        start <= 1'b1;
        rst_ <= 1'b1;
        #100 $finish;
    end

    always #1 clk <= ~clk;

endmodule
