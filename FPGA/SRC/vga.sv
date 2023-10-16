`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2023 12:17:37 PM
// Design Name: 
// Module Name: vga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

typedef struct packed {
 logic [3:0] r;
 logic [3:0] g;
 logic [3:0] b;
} Color;

module vga(
    input CLK25MHZ,
    input ck_rst,
    input Color [479:0] color_in, // RRRRGGGGBBBB
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output vga_hs,
    output vga_vs,
    output [9:0] next_y,
    output next_line
    );
   
    
    // Horizontal parameters (measured in clock cycles)
    parameter [9:0] H_ACTIVE  = 10'd639 ;
    parameter [9:0] H_FRONT   = 10'd15 ;
    parameter [9:0] H_PULSE   = 10'd95 ;
    parameter [9:0] H_BACK    = 10'd47 ;

    // Vertical parameters (measured in lines)
    parameter [9:0] V_ACTIVE  = 10'd479 ;
    parameter [9:0] V_FRONT   = 10'd9 ;
    parameter [9:0] V_PULSE   = 10'd1 ;
    parameter [9:0] V_BACK    = 10'd32 ;

    // Parameters for readability
    parameter   LOW     = 1'b0 ;
    parameter   HIGH    = 1'b1 ;

    // States (more readable)
    parameter[7:0] H_ACTIVE_STATE = 8'd0 ;
    parameter[7:0] H_FRONT_STATE  = 8'd1 ;
    parameter[7:0] H_PULSE_STATE  = 8'd2 ;
    parameter[7:0] H_BACK_STATE   = 8'd3 ;

    parameter[7:0] V_ACTIVE_STATE = 8'd0 ;
    parameter[7:0] V_FRONT_STATE  = 8'd1 ;
    parameter[7:0] V_PULSE_STATE  = 8'd2 ;
    parameter[7:0] V_BACK_STATE   = 8'd3 ;
    
    // Clocked registers
    logic      hysncr ;
    logic      vsyncr ;
    logic[3:0] redr ;
    logic[3:0] greenr ;
    logic[3:0] bluer ;
    logic      line_done ;
    logic      next_liner;

    // Control registers
    logic[9:0] h_counter ;
    logic[9:0] v_counter ;

    logic[7:0] h_state ;
    logic[7:0] v_state ;
    
    logic inter_offset = 1'b0 ;
    
    logic [9:0] next_x;
    
    // State machine
    always@(posedge CLK25MHZ) begin 
        // At reset . . .
        if (ck_rst) begin
            // Zero the counters
            h_counter   <= 10'd0 ;
            v_counter   <= 10'd0 ;
            // States to ACTIVE
            h_state     <= H_ACTIVE_STATE  ;
            v_state     <= V_ACTIVE_STATE  ;
            // Deassert line done
            line_done   <= LOW ;
        end
        else begin
            //////////////////////////////////////////////////////////////////////////
            ///////////////////////// HORIZONTAL /////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////
            if (h_state == H_ACTIVE_STATE) begin
                // Iterate horizontal counter, zero at end of ACTIVE mode
                h_counter <= (h_counter==H_ACTIVE)?10'd0:(h_counter + 10'd1) ;
                // Set hsync
                hysncr <= HIGH ;
                // Deassert line done
                line_done <= LOW ;
                next_liner <= LOW ;
                // State transition
                h_state <= (h_counter == H_ACTIVE)?H_FRONT_STATE:H_ACTIVE_STATE ;
            end
            if (h_state == H_FRONT_STATE) begin
                // Iterate horizontal counter, zero at end of H_FRONT mode
                h_counter <= (h_counter==H_FRONT)?10'd0:(h_counter + 10'd1) ;
                // Set hsync
                hysncr <= HIGH ;
                // State transition
                h_state <= (h_counter == H_FRONT)?H_PULSE_STATE:H_FRONT_STATE ;
            end
            if (h_state == H_PULSE_STATE) begin
                // Iterate horizontal counter, zero at end of H_PULSE mode
                h_counter <= (h_counter==H_PULSE)?10'd0:(h_counter + 10'd1) ;
                // Clear hsync
                hysncr <= LOW ;
                // State transition
                h_state <= (h_counter == H_PULSE)?H_BACK_STATE:H_PULSE_STATE ;
                next_liner <= HIGH ;
            end
            if (h_state == H_BACK_STATE) begin
                // Iterate horizontal counter, zero at end of H_BACK mode
                h_counter <= (h_counter==H_BACK)?10'd0:(h_counter + 10'd1) ;
                // Set hsync
                hysncr <= HIGH ;
                // State transition
                h_state <= (h_counter == H_BACK)?H_ACTIVE_STATE:H_BACK_STATE ;
                // Signal line complete at state transition (offset by 1 for synchronous state transition)
                line_done <= (h_counter == (H_BACK-1))?HIGH:LOW ;
            end
            //////////////////////////////////////////////////////////////////////////
            ///////////////////////// VERTICAL ///////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////
            if (v_state == V_ACTIVE_STATE) begin
                // increment vertical counter at end of line, zero on state transition
                v_counter<=(line_done==HIGH)?((v_counter==V_ACTIVE)?10'd0:(v_counter+10'd1)):v_counter ;
                // set vsync in active mode
                vsyncr <= HIGH ;
                // state transition - only on end of lines
                v_state<=(line_done==HIGH)?((v_counter==V_ACTIVE)?V_FRONT_STATE:V_ACTIVE_STATE):V_ACTIVE_STATE ;
            end
            if (v_state == V_FRONT_STATE) begin
                // increment vertical counter at end of line, zero on state transition
                v_counter<=(line_done==HIGH)?((v_counter==V_FRONT)?10'd0:(v_counter + 10'd1)):v_counter ;
                // set vsync in front porch
                vsyncr <= HIGH ;
                // state transition
                v_state<=(line_done==HIGH)?((v_counter==V_FRONT)?V_PULSE_STATE:V_FRONT_STATE):V_FRONT_STATE;
            end
            if (v_state == V_PULSE_STATE) begin
                // increment vertical counter at end of line, zero on state transition
                v_counter<=(line_done==HIGH)?((v_counter==V_PULSE)?10'd0:(v_counter + 10'd1)):v_counter ;
                // clear vsync in pulse
                vsyncr <= LOW ;
                // state transition
                v_state<=(line_done==HIGH)?((v_counter==V_PULSE)?V_BACK_STATE:V_PULSE_STATE):V_PULSE_STATE;
            end
            if (v_state == V_BACK_STATE) begin
                // increment vertical counter at end of line, zero on state transition
                v_counter<=(line_done==HIGH)?((v_counter==V_BACK)?10'd0:(v_counter + 10'd1)):v_counter ;
                // set vsync in back porch
                vsyncr <= HIGH ;
                // state transition
                v_state<=(line_done==HIGH)?((v_counter==V_BACK)?V_ACTIVE_STATE:V_BACK_STATE):V_BACK_STATE ;
            end

            //////////////////////////////////////////////////////////////////////////
            //////////////////////////////// COLOR OUT ///////////////////////////////
            //////////////////////////////////////////////////////////////////////////
            // Assign colors if in
            redr<=(h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?(inter?{color_in[next_x][11:8]} :4'd0) :4'd0) :4'd0 ;
            greenr<=(h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?(inter?{color_in[next_x][7:4]} :4'd0) :4'd0) :4'd0 ;
            bluer<=(h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?(inter?{color_in[next_x][3:0]} :4'd0):4'd0) :4'd0 ;
        end
    end
    
    always @ (negedge next_y[8]) begin
        inter_offset = inter_offset + 1'b1;
    end
    // Assign output values - to VGA connector
    assign vga_hs = hysncr ;
    assign vga_vs = vsyncr ;
    assign vga_r = redr ;
    assign vga_g = greenr ;
    assign vga_b = bluer ;
    assign next_y = (v_state==V_ACTIVE_STATE)?v_counter:10'd0 ;
    assign next_x = (h_state==H_ACTIVE_STATE)?h_counter:10'd0 ;
    assign inter = (v_state==V_ACTIVE_STATE)?v_counter[0] + inter_offset:1'b0 ;
    assign next_line = next_liner;
    
    
endmodule
