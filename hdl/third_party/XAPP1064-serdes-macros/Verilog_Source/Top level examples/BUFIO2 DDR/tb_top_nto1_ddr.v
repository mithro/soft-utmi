//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.0
//  \   \        Filename: tb_top_nto1_ddr.v
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

module tb_top_nto1_ddr () ;

reg 		reset ;
reg 		reset2 ;
reg 		match ;
reg 		matcha ;
reg 		clk ;
wire 		refclk_n ;
reg 		refclk_p ;
wire		clkout_p ;
wire 		clkout_n ;
wire 		clkout ;
wire	[7:0]	dataout_p ;
wire 	[7:0]	dataout_n ;
wire 	[7:0]	dataout ;
wire 	[63:0]	dummy_out ;
reg 	[63:0]	old ;
wire 	[63:0]	dummy_outa ;
reg 	[63:0]	olda ;

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

always @ (posedge clk)			// Check data
begin
	old <= dummy_out ;
	if (dummy_out[63:60] == 4'h3 && dummy_out[59:0] == {old[58:0], old[59]}) begin 
		match <= 1'b1 ; 
	end 
	else begin 
		match <= 1'b0 ; 
	end 
end


top_nto1_ddr_diff_tx diff_tx  (
	.refclkin_p		(refclk_p),
	.refclkin_n		(refclk_n),
	.dataout_p		(dataout_p),
	.dataout_n		(dataout_n),
	.clkout_p		(clkout_p),
	.clkout_n		(clkout_n),
	.reset			(reset)) ;
	
top_nto1_ddr_diff_rx diff_rx  (
	.clkin_p		(clkout_p),
	.clkin_n		(clkout_n),
	.datain_p		(dataout_p),
	.datain_n		(dataout_n),
	.reset			(reset),
	.dummy_out		(dummy_out)) ;

always @ (posedge clk)			// Check data
begin
	olda <= dummy_outa ;
	if (dummy_outa[63:60] == 4'h3 && dummy_outa[59:0] == {olda[58:0], olda[59]}) begin 
		matcha <= 1'b1 ; 
	end 
	else begin 
		matcha <= 1'b0 ; 
	end 
end

top_nto1_ddr_se_tx se_tx  (
	.refclkin_p		(refclk_p),
	.refclkin_n		(refclk_n),
	.dataout		(dataout),
	.clkout			(clkout),
	.reset			(reset)) ;
	
top_nto1_ddr_se_rx se_rx  (
	.clkin1			(clkout),
	.clkin2			(clkout),
	.datain			(dataout),
	.reset			(reset),
	.dummy_out		(dummy_outa)) ;
	
endmodule


