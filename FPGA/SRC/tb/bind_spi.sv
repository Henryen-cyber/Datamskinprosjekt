module bind_spi ();
bind tb assertions_spi u_assertion_bind(
    .ErrCntAssertions (uin_spi.ErrCntAssertions),
    .clk              (uin_spi.clk),
    .mosi             (uin_spi.mosi),
    .miso             (uin_spi.miso),
    .ssel_            (uin_spi.ssel_),
    .sck              (uin_spi.sck),
    .data_out         (uin_spi.data_out)
    );
endmodule
