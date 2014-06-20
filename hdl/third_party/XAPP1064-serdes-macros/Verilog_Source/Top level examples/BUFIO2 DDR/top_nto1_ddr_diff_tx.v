///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.0
//  \   \        Filename: top_nto1_ddr_diff_tx.v
//  /   /        Date Last Modified:  November 5 2009
// /___/   /\    Date Created: June 1 2009
// \   \  /  \
//  \___\/\___\
// 
//Device: 	Spartan 6
//Purpose:  	Example differential output transmitter for DDR clock and data using 2 x BUFIO2
//		Serdes factor and number of data lines are set by constants in the code
//Reference:
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//
///////////////////////////////////////////////////////////////////////////////
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

`timescale 1ps/1ps

module top_nto1_ddr_diff_tx (
input		reset,				// reset (active high)
input		refclkin_p,  refclkin_n,	// frequency generator clock input
output	[7:0]	dataout_p, dataout_n,		// lvds data outputs
output		clkout_p,  clkout_n) ;		// lvds clock output

// Parameters for serdes factor and number of IO pins

parameter integer     S = 8 ;			// Set the serdes factor
parameter integer     D = 8 ;			// Set the number of inputs and outputs
parameter integer     DS = (D*S)-1 ;		// Used for bus widths = serdes factor * number of inputs - 1

wire       	rst ;
reg	[DS:0] 	txd ;				// Registered Data to serdeses

// Parameters for clock generation

parameter [S-1:0] TX_CLK_GEN   = 8'hAA ;	// Transmit a constant to make a clock

assign rst = reset ; 					// active high reset pin

// Reference Clock Input genertaes IO clocks via 2 x BUFIO2

clock_generator_ddr_s8_diff #(
	.S 			(S))
inst_clkgen(
	.clkin_p		(refclkin_p), 
	.clkin_n		(refclkin_n),
	.ioclkap		(txioclkp),
	.ioclkan		(txioclkn),
	.serdesstrobea		(tx_serdesstrobe),
	.ioclkbp		(),
	.ioclkbn		(),
	.serdesstrobeb		(),
	.gclk			(tx_bufg_x1)) ;

always @ (posedge tx_bufg_x1 or posedge rst)			// Generate some data to transmit
begin
if (rst == 1'b1) begin
	txd <= 64'h3000000000000001 ;
end
else begin
	txd <= {txd[63:60], txd[58:0], txd[59]} ;
end
end

// Transmitter Logic - Instantiate serialiser to generate forwarded clock

serdes_n_to_1_ddr_s8_diff #(
      	.S			(S),
      	.D			(1))
inst_clkout (
	.dataout_p  		(clkout_p),
	.dataout_n  		(clkout_n),
	.txioclkp    		(txioclkp),
	.txioclkn    		(txioclkn),
	.txserdesstrobe 	(tx_serdesstrobe),
	.gclk    		(tx_bufg_x1),
	.reset     		(rst),
	.datain  		(TX_CLK_GEN));			// Transmit a constant to make the clock

// Instantiate Outputs and output serialisers for output data lines

serdes_n_to_1_ddr_s8_diff #(
      	.S			(S),
      	.D			(D))
inst_dataout (
	.dataout_p  		(dataout_p),
	.dataout_n  		(dataout_n),
	.txioclkp    		(txioclkp),
	.txioclkn    		(txioclkn),
	.txserdesstrobe 	(tx_serdesstrobe),
	.gclk    		(tx_bufg_x1),
	.reset   		(rst),
	.datain  		(txd));

endmodule
