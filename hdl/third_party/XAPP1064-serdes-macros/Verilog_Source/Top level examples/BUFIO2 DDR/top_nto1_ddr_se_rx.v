///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.0
//  \   \        Filename: top_nto1_ddr_se_rx.v
//  /   /        Date Last Modified:  November 5 2009
// /___/   /\    Date Created: June 1 2009
// \   \  /  \
//  \___\/\___\
// 
//Device: 	Spartan 6
//Purpose:  	Example single ended input receiver for DDR clock and data using 2 x BUFIO2
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

module top_nto1_ddr_se_rx (
input		reset,				// reset (active high)
input	[7:0]	datain,				// single ended data inputs
input		clkin1,  clkin2,		// TWO single ended clock input
output	[63:0]	dummy_out) ;			// dummy outputs

// Parameters for serdes factor and number of IO pins

parameter integer     S = 8 ;			// Set the serdes factor to 8
parameter integer     D = 8 ;			// Set the number of inputs and outputs
parameter integer     DS = (D*S)-1 ;		// Used for bus widths = serdes factor * number of inputs - 1

wire       	rst ;
wire	[DS:0] 	rxd ;				// Data from serdeses
reg	[DS:0] 	rxr ;				// Registered Data from serdeses
reg		state ;
reg 		bslip ;
reg	[3:0]	count ;

assign rst = reset ; 				// active high reset pin
assign dummy_out = rxr ;

// Clock Input. Generate ioclocks via BUFIO2

serdes_1_to_n_clk_ddr_s8_se #(
      	.S			(S)) 		
inst_clkin (
	.clkin1   		(clkin1),
	.clkin2   		(clkin2),
	.rxioclkp    		(rxioclkp),
	.rxioclkn   		(rxioclkn),
	.rx_serdesstrobe	(rx_serdesstrobe),
	.rx_bufg_x1		(rx_bufg_x1));

// Data Inputs

serdes_1_to_n_data_ddr_s8_se #(
      	.S			(S),			
      	.D			(D),
      	.USE_PD			("TRUE"))		// Enables use of the phase detector - will require 2 input serdes whatever the serdes ratio required
inst_datain (
	.use_phase_detector 	(1'b1),			// '1' enables the phase detector logic
	.datain     		(datain),
	.rxioclkp    		(rxioclkp),
	.rxioclkn   		(rxioclkn),
	.rxserdesstrobe 	(rx_serdesstrobe),
	.gclk    		(rx_bufg_x1),
	.bitslip   		(bslip),
	.reset   		(rst),
	.data_out  		(rxd),
	.debug_in  		(2'b00),
	.debug    		());

always @ (posedge rx_bufg_x1 or posedge rst)		// example bitslip logic, if required
begin
if (rst == 1'b1) begin
	state <= 0 ;
	bslip <= 1'b0 ;
   	count <= 4'b0000 ;
end
else begin
   	if (state == 0) begin
   		if (rxd[63:60] != 4'h3) begin
     	   		bslip <= 1'b1 ;			// bitslip needed
     	   		state <= 1 ;
     	   		count <= 4'b0000 ;
     	   	end
	end
   	else if (state == 1) begin
     	   	bslip <= 1'b0 ;				// bitslip low
     	   	count <= count + 4'b0001 ;
   		if (count == 4'b1111) begin
     	   		state <= 0;
     	   	end
     	end
end
end

always @ (posedge rx_bufg_x1)				// process received data
begin
	rxr <= rxd ;
end

endmodule
