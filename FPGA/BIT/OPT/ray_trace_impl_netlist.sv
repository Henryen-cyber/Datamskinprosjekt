// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
// Date        : Wed Sep 13 15:53:03 2023
// Host        : Henry-LinuxMint running 64-bit Linux Mint 21.2
// Command     : write_verilog -force OPT/ray_trace_impl_netlist.sv -mode timesim -sdf_anno true
// Design      : spi_interface
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7a35ticsg324-1L
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* ECO_CHECKSUM = "c37c3943" *) 
(* NotValidForBitStream *)
module spi_interface
   (clk,
    mosi,
    ssel_,
    sck,
    miso,
    led);
  input clk;
  input mosi;
  input ssel_;
  input sck;
  output miso;
  output led;

  wire [2:0]bit_cnt;
  wire \bit_cnt[0]_i_1_n_0 ;
  wire \bit_cnt[1]_i_1_n_0 ;
  wire \bit_cnt[2]_i_1_n_0 ;
  wire [7:7]byte_data_sendt;
  wire [7:7]byte_data_sendt0_in;
  wire \byte_data_sendt[0]_i_1_n_0 ;
  wire \byte_data_sendt_reg_n_0_[0] ;
  wire \byte_data_sendt_reg_n_0_[1] ;
  wire \byte_data_sendt_reg_n_0_[2] ;
  wire \byte_data_sendt_reg_n_0_[3] ;
  wire \byte_data_sendt_reg_n_0_[4] ;
  wire \byte_data_sendt_reg_n_0_[5] ;
  wire \byte_data_sendt_reg_n_0_[6] ;
  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire \cnt[7]_i_3_n_0 ;
  wire [0:0]cnt_reg;
  wire [7:1]cnt_reg__0;
  wire led;
  wire miso;
  wire miso_OBUF;
  wire [1:0]p_0_in;
  wire p_0_in0;
  wire [7:0]p_0_in__0;
  wire p_0_out;
  wire [7:1]p_1_in;
  wire sck;
  wire sck_IBUF;
  wire \sckr_reg_n_0_[0] ;
  wire sel;
  wire ssel_;
  wire ssel__IBUF;
  wire \sselr_reg_n_0_[0] ;
  wire \sselr_reg_n_0_[2] ;

initial begin
 $sdf_annotate("ray_trace_impl_netlist.sdf",,,,"tool_control");
end
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h00A6)) 
    \bit_cnt[0]_i_1 
       (.I0(bit_cnt[0]),
        .I1(p_0_in[0]),
        .I2(p_0_in[1]),
        .I3(p_0_in0),
        .O(\bit_cnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h00009AAA)) 
    \bit_cnt[1]_i_1 
       (.I0(bit_cnt[1]),
        .I1(p_0_in[1]),
        .I2(p_0_in[0]),
        .I3(bit_cnt[0]),
        .I4(p_0_in0),
        .O(\bit_cnt[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h000000009AAAAAAA)) 
    \bit_cnt[2]_i_1 
       (.I0(bit_cnt[2]),
        .I1(p_0_in[1]),
        .I2(p_0_in[0]),
        .I3(bit_cnt[1]),
        .I4(bit_cnt[0]),
        .I5(p_0_in0),
        .O(\bit_cnt[2]_i_1_n_0 ));
  FDRE \bit_cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bit_cnt[0]_i_1_n_0 ),
        .Q(bit_cnt[0]),
        .R(1'b0));
  FDRE \bit_cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bit_cnt[1]_i_1_n_0 ),
        .Q(bit_cnt[1]),
        .R(1'b0));
  FDRE \bit_cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bit_cnt[2]_i_1_n_0 ),
        .Q(bit_cnt[2]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hAACAAACAAAC0AACA)) 
    \byte_data_sendt[0]_i_1 
       (.I0(\byte_data_sendt_reg_n_0_[0] ),
        .I1(cnt_reg),
        .I2(\sselr_reg_n_0_[2] ),
        .I3(p_0_in0),
        .I4(p_0_in[1]),
        .I5(p_0_in[0]),
        .O(\byte_data_sendt[0]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \byte_data_sendt[1]_i_1 
       (.I0(cnt_reg__0[1]),
        .I1(\sselr_reg_n_0_[2] ),
        .I2(\byte_data_sendt_reg_n_0_[0] ),
        .O(p_1_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \byte_data_sendt[2]_i_1 
       (.I0(cnt_reg__0[2]),
        .I1(\sselr_reg_n_0_[2] ),
        .I2(\byte_data_sendt_reg_n_0_[1] ),
        .O(p_1_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \byte_data_sendt[3]_i_1 
       (.I0(cnt_reg__0[3]),
        .I1(\sselr_reg_n_0_[2] ),
        .I2(\byte_data_sendt_reg_n_0_[2] ),
        .O(p_1_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \byte_data_sendt[4]_i_1 
       (.I0(cnt_reg__0[4]),
        .I1(\sselr_reg_n_0_[2] ),
        .I2(\byte_data_sendt_reg_n_0_[3] ),
        .O(p_1_in[4]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \byte_data_sendt[5]_i_1 
       (.I0(cnt_reg__0[5]),
        .I1(\sselr_reg_n_0_[2] ),
        .I2(\byte_data_sendt_reg_n_0_[4] ),
        .O(p_1_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \byte_data_sendt[6]_i_1 
       (.I0(cnt_reg__0[6]),
        .I1(\sselr_reg_n_0_[2] ),
        .I2(\byte_data_sendt_reg_n_0_[5] ),
        .O(p_1_in[6]));
  LUT6 #(
    .INIT(64'h0000000000000100)) 
    \byte_data_sendt[7]_i_1 
       (.I0(bit_cnt[2]),
        .I1(bit_cnt[0]),
        .I2(bit_cnt[1]),
        .I3(p_0_out),
        .I4(p_0_in0),
        .I5(\sselr_reg_n_0_[2] ),
        .O(byte_data_sendt));
  LUT4 #(
    .INIT(16'h2232)) 
    \byte_data_sendt[7]_i_2 
       (.I0(\sselr_reg_n_0_[2] ),
        .I1(p_0_in0),
        .I2(p_0_in[1]),
        .I3(p_0_in[0]),
        .O(byte_data_sendt0_in));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \byte_data_sendt[7]_i_3 
       (.I0(cnt_reg__0[7]),
        .I1(\sselr_reg_n_0_[2] ),
        .I2(\byte_data_sendt_reg_n_0_[6] ),
        .O(p_1_in[7]));
  LUT2 #(
    .INIT(4'h2)) 
    \byte_data_sendt[7]_i_4 
       (.I0(p_0_in[1]),
        .I1(p_0_in[0]),
        .O(p_0_out));
  FDRE \byte_data_sendt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\byte_data_sendt[0]_i_1_n_0 ),
        .Q(\byte_data_sendt_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \byte_data_sendt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(byte_data_sendt0_in),
        .D(p_1_in[1]),
        .Q(\byte_data_sendt_reg_n_0_[1] ),
        .R(byte_data_sendt));
  FDRE \byte_data_sendt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(byte_data_sendt0_in),
        .D(p_1_in[2]),
        .Q(\byte_data_sendt_reg_n_0_[2] ),
        .R(byte_data_sendt));
  FDRE \byte_data_sendt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(byte_data_sendt0_in),
        .D(p_1_in[3]),
        .Q(\byte_data_sendt_reg_n_0_[3] ),
        .R(byte_data_sendt));
  FDRE \byte_data_sendt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(byte_data_sendt0_in),
        .D(p_1_in[4]),
        .Q(\byte_data_sendt_reg_n_0_[4] ),
        .R(byte_data_sendt));
  FDRE \byte_data_sendt_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(byte_data_sendt0_in),
        .D(p_1_in[5]),
        .Q(\byte_data_sendt_reg_n_0_[5] ),
        .R(byte_data_sendt));
  FDRE \byte_data_sendt_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(byte_data_sendt0_in),
        .D(p_1_in[6]),
        .Q(\byte_data_sendt_reg_n_0_[6] ),
        .R(byte_data_sendt));
  FDRE \byte_data_sendt_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(byte_data_sendt0_in),
        .D(p_1_in[7]),
        .Q(miso_OBUF),
        .R(byte_data_sendt));
  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  LUT1 #(
    .INIT(2'h1)) 
    \cnt[0]_i_1 
       (.I0(cnt_reg),
        .O(p_0_in__0[0]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \cnt[1]_i_1 
       (.I0(cnt_reg),
        .I1(cnt_reg__0[1]),
        .O(p_0_in__0[1]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \cnt[2]_i_1 
       (.I0(cnt_reg),
        .I1(cnt_reg__0[1]),
        .I2(cnt_reg__0[2]),
        .O(p_0_in__0[2]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \cnt[3]_i_1 
       (.I0(cnt_reg__0[1]),
        .I1(cnt_reg),
        .I2(cnt_reg__0[2]),
        .I3(cnt_reg__0[3]),
        .O(p_0_in__0[3]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \cnt[4]_i_1 
       (.I0(cnt_reg__0[2]),
        .I1(cnt_reg),
        .I2(cnt_reg__0[1]),
        .I3(cnt_reg__0[3]),
        .I4(cnt_reg__0[4]),
        .O(p_0_in__0[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \cnt[5]_i_1 
       (.I0(cnt_reg__0[3]),
        .I1(cnt_reg__0[1]),
        .I2(cnt_reg),
        .I3(cnt_reg__0[2]),
        .I4(cnt_reg__0[4]),
        .I5(cnt_reg__0[5]),
        .O(p_0_in__0[5]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \cnt[6]_i_1 
       (.I0(\cnt[7]_i_3_n_0 ),
        .I1(cnt_reg__0[6]),
        .O(p_0_in__0[6]));
  LUT2 #(
    .INIT(4'h2)) 
    \cnt[7]_i_1 
       (.I0(\sselr_reg_n_0_[2] ),
        .I1(p_0_in0),
        .O(sel));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \cnt[7]_i_2 
       (.I0(\cnt[7]_i_3_n_0 ),
        .I1(cnt_reg__0[6]),
        .I2(cnt_reg__0[7]),
        .O(p_0_in__0[7]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \cnt[7]_i_3 
       (.I0(cnt_reg__0[5]),
        .I1(cnt_reg__0[3]),
        .I2(cnt_reg__0[1]),
        .I3(cnt_reg),
        .I4(cnt_reg__0[2]),
        .I5(cnt_reg__0[4]),
        .O(\cnt[7]_i_3_n_0 ));
  FDRE \cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(sel),
        .D(p_0_in__0[0]),
        .Q(cnt_reg),
        .R(1'b0));
  FDRE \cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(sel),
        .D(p_0_in__0[1]),
        .Q(cnt_reg__0[1]),
        .R(1'b0));
  FDRE \cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(sel),
        .D(p_0_in__0[2]),
        .Q(cnt_reg__0[2]),
        .R(1'b0));
  FDRE \cnt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(sel),
        .D(p_0_in__0[3]),
        .Q(cnt_reg__0[3]),
        .R(1'b0));
  FDRE \cnt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(sel),
        .D(p_0_in__0[4]),
        .Q(cnt_reg__0[4]),
        .R(1'b0));
  FDRE \cnt_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(sel),
        .D(p_0_in__0[5]),
        .Q(cnt_reg__0[5]),
        .R(1'b0));
  FDRE \cnt_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(sel),
        .D(p_0_in__0[6]),
        .Q(cnt_reg__0[6]),
        .R(1'b0));
  FDRE \cnt_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(sel),
        .D(p_0_in__0[7]),
        .Q(cnt_reg__0[7]),
        .R(1'b0));
  OBUFT led_OBUF_inst
       (.I(1'b0),
        .O(led),
        .T(1'b1));
  OBUF miso_OBUF_inst
       (.I(miso_OBUF),
        .O(miso));
  IBUF sck_IBUF_inst
       (.I(sck),
        .O(sck_IBUF));
  FDRE \sckr_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(sck_IBUF),
        .Q(\sckr_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \sckr_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\sckr_reg_n_0_[0] ),
        .Q(p_0_in[0]),
        .R(1'b0));
  FDRE \sckr_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[0]),
        .Q(p_0_in[1]),
        .R(1'b0));
  IBUF ssel__IBUF_inst
       (.I(ssel_),
        .O(ssel__IBUF));
  FDRE \sselr_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(ssel__IBUF),
        .Q(\sselr_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \sselr_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\sselr_reg_n_0_[0] ),
        .Q(p_0_in0),
        .R(1'b0));
  FDRE \sselr_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in0),
        .Q(\sselr_reg_n_0_[2] ),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
