//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.0
//  \   \        Filename: tb_top_nto1_pll.v
//  /   /        Date Last Modified:  November 5 2009
// /___/   /\    Date Created: June 1 2009
// \   \  /  \
//  \___\/\___\
// 
//Device: 	Spartan 6
//Purpose:  	Test Bench
//Reference:
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//
//////////////////////////////////////////////////////////////////////////////
//
//  Disclaimer: 
//
//		This disclaimer is not a license and does not grant any rights to the materials 
//              distributed herewith. Except as otherwise provided in a valid license issued to you 
//              by Xilinx, and to the maximum extent permitted by applicable law: 
//              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
//              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
//              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
//              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
//              or tort, including negligence, or under any other theory of liability) for any loss or damage 
//              of any kind or nature related to, arising under or in connection with these materials, 
//              including for any direct, or any indirect, special, incidental, or consequential loss 
//              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
//              as a result of any action brought by a third party) even if such damage or loss was 
//              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
//  Critical Applications:
//
//		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
//		requiring fail-safe performance, such as life-support or safety devices or systems, 
//		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
//		or any other applications that could lead to death, personal injury, or severe property or 
//		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
//		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
//		to applicable laws and regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1ps

module tb_top_nto1_pll () ;

reg 		reset ;
reg 		reset2 ;
reg 		match ;
reg 		match2 ;
reg 		clk ;
wire 		refclk_n ;
reg 		refclk_p ;
wire		clkout_p ;
wire 		clkout_n ;
wire 		clkout ;
wire	[5:0]	dataout_p ;
wire 	[5:0]	dataout_n ;
wire 	[41:0]	dummy_out ;
reg 	[41:0]	old ;
wire 	[41:0]	dummy_out2 ;
reg 	[41:0]	old2 ;
wire		clkout2_p ;
wire 		clkout2_n ;
wire	[5:0]	dataout2_p ;
wire 	[5:0]	dataout2_n ;

initial refclk_p = 0 ;
initial clk = 0 ;

always #(1000) refclk_p = ~refclk_p ;
always #(4000) clk = ~clk ;
assign refclk_n = ~refclk_p ;

initial
begin
reset = 1'b1 ;
reset2 = 1'b0 ;
#150000
reset = 1'b0;
#300000
reset2 = 1'b1 ;
end

always @ (posedge refclk_p)			// Check data
begin
	old <= dummy_out ;
	if (dummy_out[41:0] == {old[40:0], old[41]}) begin 
		match <= 1'b1 ; 
	end 
	else begin 
		match <= 1'b0 ; 
	end 
end

always @ (posedge refclk_p)			// Check data
begin
	old2 <= dummy_out2 ;
	if (dummy_out2[41:0] == {old2[40:0], old2[41]}) begin 
		match2 <= 1'b1 ; 
	end 
	else begin 
		match2 <= 1'b0 ; 
	end 
end

top_nto1_pll_diff_tx diff_tx  (
	.refclkin_p		(refclk_p),
	.refclkin_n		(refclk_n),
	.dataout_p		(dataout_p),
	.dataout_n		(dataout_n),
	.clkout_p		(clkout_p),
	.clkout_n		(clkout_n),
	.reset			(reset)) ;
	
top_nto1_pll_diff_rx diff_rx  (
	.clkin_p		(clkout_p),
	.clkin_n		(clkout_n),
	.datain_p		(dataout_p),
	.datain_n		(dataout_n),
	.reset			(reset),
	.dummy_out		(dummy_out)) ;

top_nto1_pll_diff_rx_and_tx diff_rx_and_tx  (
	.clkin_p		(clkout_p),
	.clkin_n		(clkout_n),
	.datain_p		(dataout_p),
	.datain_n		(dataout_n),
	.reset			(reset),
	.dataout_p		(dataout2_p),
	.dataout_n		(dataout2_n),
	.clkout_p		(clkout2_p),
	.clkout_n		(clkout2_n)) ;	

top_nto1_pll_diff_rx diff_rx2  (
	.clkin_p		(clkout2_p),
	.clkin_n		(clkout2_n),
	.datain_p		(dataout2_p),
	.datain_n		(dataout2_n),
	.reset			(reset),
	.dummy_out		(dummy_out2)) ;
		
endmodule


