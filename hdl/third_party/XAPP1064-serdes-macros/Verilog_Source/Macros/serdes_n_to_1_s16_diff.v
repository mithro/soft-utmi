///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.0
//  \   \        Filename: serdes_n_to_1_s16_diff.v
//  /   /        Date Last Modified:  November 5 2009
// /___/   /\    Date Created: September 1 2009
// \   \  /  \
//  \___\/\___\
// 
//Device: 	Spartan 6
//Purpose:  	D-bit generic n:1 transmitter module for differential outputs with serdes factors of 10,12,14,16
// 		Takes in n bits of data and serialises this to 1 bit
// 		data is transmitted LSB first
// 		Parallel input word
//		DS, DS-1 ..... 1, 0
//		Serial output words
//		Line0     : 0,   ...... DS-(S+1)
// 		Line1 	  : 1,   ...... DS-(S+2)
// 		Line(D-1) : .           .
// 		Line0(D)  : D-1, ...... DS
//		Data inversion can be accomplished via the TX_SWAP_MASK parameter if required
//Reference:
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
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

module serdes_n_to_1_s16_diff (txioclk, txserdesstrobe, reset, tx_bufg_pll_x2, tx_bufg_pll_x1, datain, clkin, dataout_p, dataout_n, clkout_p, clkout_n) ;

parameter integer S = 10 ;   		// Parameter to set the serdes factor 10,12,14,16
parameter integer D = 16 ;		// Set the number of inputs and outputs

input 			txioclk ;		// IO Clock network
input 			txserdesstrobe ;	// Parallel data capture strobe
input 			reset ;			// Reset
input 			tx_bufg_pll_x2 ;	// Global clock x2
input 			tx_bufg_pll_x1 ;	// Global clock
input 	[(D*S)-1:0]	datain ;  		// Data for output
input 	[S-1:0]		clkin ;  		// pattern for clock output
output 	[D-1:0]		dataout_p ;		// output data
output 	[D-1:0]		dataout_n ;		// output data
output 			clkout_p ;		// output clock
output 			clkout_n ;		// output clock

wire	[D-1:0]	cascade_di ;		//
wire	[D-1:0]	cascade_do ;		//
wire	[D-1:0]	cascade_ti ;		//
wire	[D-1:0]	cascade_to ;		//
wire	[D-1:0]	tx_data_out ;		//
wire	[D*8:0]	mdatain ;
reg		tx_toggle ;		//
reg		old_tx_toggle ;		//
reg	[7:0] 	tx_clk_int ;		//
reg	[(D*S/2)-1:0] txd_int ;		//

parameter [D-1:0] TX_SWAP_MASK = 16'h0000 ;	// pinswap mask for output bits (0 = no swap (default), 1 = swap). Allows outputs to be connected the 'wrong way round' to ease PCB routing.

genvar i ;
genvar j ;

always @ (posedge tx_bufg_pll_x1 or posedge reset)
if (reset == 1'b1) begin
	tx_toggle <= 1'b0 ;
end
else begin
	tx_toggle <= ~tx_toggle ;
end

always @ (posedge tx_bufg_pll_x2)
begin
	old_tx_toggle <= tx_toggle ;
	if (tx_toggle != old_tx_toggle) begin
		txd_int <= datain[(D*S/2)-1:0] ;
		tx_clk_int <= clkin[S/2-1:0] ;
	end
	else begin
		txd_int <= datain[(D*S)-1:D*S/2] ;
		tx_clk_int <= clkin[S-1:S/2] ;
	end
end

OBUFDS io_data_out (
	.O    			(clkout_p),
	.OB       		(clkout_n),
	.I         		(tx_clk_out));

generate
for (i = 0 ; i <= (D-1) ; i = i+1)
begin : loop0

OBUFDS #(
	.IOSTANDARD     	("DEFAULT" ))
io_data_out (
	.O    			(dataout_p[i]),
	.OB       		(dataout_n[i]),
	.I         		(tx_data_out[i]));

for (j = 0 ; j <= (S/2-1) ; j = j+1)
begin : loop1
// re-arrange data bits for transmission and invert lines as given by the mask
// NOTE If pin inversion is required (non-zero SWAP MASK) then inverters will occur in fabric, as there are no inverters in the OSERDES2
// This can be avoided by doing the inversion (if necessary) in the user logic
assign mdatain[(8*i)+j] = txd_int[(i)+(D*j)] ^ TX_SWAP_MASK[i] ;
end

OSERDES2 #(
	.DATA_WIDTH     	(S/2), 			// SERDES word width.  This should match the setting is BUFPLL
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_OT      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("MASTER"), 		// <DEFAULT>, MASTER, SLAVE
	.OUTPUT_MODE 		("DIFFERENTIAL"))
oserdes_m (
	.OQ       		(tx_data_out[i]),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(tx_bufg_pll_x2),
	.D4  			(mdatain[(8*i)+7]),
	.D3  			(mdatain[(8*i)+6]),
	.D2  			(mdatain[(8*i)+5]),
	.D1  			(mdatain[(8*i)+4]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TRAIN    		(1'b0),
	.TCE	   		(1'b1),
	.SHIFTIN1 		(1'b1),			// Dummy input in Master
	.SHIFTIN2 		(1'b1),			// Dummy input in Master
	.SHIFTIN3 		(cascade_do[i]),	// Cascade output D data from slave
	.SHIFTIN4 		(cascade_to[i]),	// Cascade output T data from slave
	.SHIFTOUT1 		(cascade_di[i]),	// Cascade input D data to slave
	.SHIFTOUT2 		(cascade_ti[i]),	// Cascade input T data to slave
	.SHIFTOUT3 		(),			// Dummy output in Master
	.SHIFTOUT4 		()) ;			// Dummy output in Master

OSERDES2 #(
	.DATA_WIDTH     	(S/2), 			// SERDES word width.  This should match the setting is BUFPLL
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_OT      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("SLAVE"), 		// <DEFAULT>, MASTER, SLAVE
	.OUTPUT_MODE 		("DIFFERENTIAL"))
oserdes_s (
	.OQ       		(),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(tx_bufg_pll_x2),
	.D4  			(mdatain[(8*i)+3]),
	.D3  			(mdatain[(8*i)+2]),
	.D2  			(mdatain[(8*i)+1]),
	.D1  			(mdatain[(8*i)+0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3  			(1'b0),
	.T4  			(1'b0),
	.TRAIN 			(1'b0),
	.TCE	 		(1'b1),
	.SHIFTIN1 		(cascade_di[i]),	// Cascade input D from Master
	.SHIFTIN2 		(cascade_ti[i]),	// Cascade input T from Master
	.SHIFTIN3 		(1'b1),			// Dummy input in Slave
	.SHIFTIN4 		(1'b1),			// Dummy input in Slave
	.SHIFTOUT1 		(),			// Dummy output in Slave
	.SHIFTOUT2 		(),			// Dummy output in Slave
	.SHIFTOUT3 		(cascade_do[i]),   	// Cascade output D data to Master
	.SHIFTOUT4 		(cascade_to[i])) ; 	// Cascade output T data to Master
end
endgenerate

OSERDES2 #(
	.DATA_WIDTH     	(S/2), 			// SERDES word width.  This should match the setting is BUFPLL
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_OT      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("MASTER"), 		// <DEFAULT>, MASTER, SLAVE
	.OUTPUT_MODE 		("DIFFERENTIAL"))
oserdes_cm (
	.OQ       		(tx_clk_out),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(tx_bufg_pll_x2),
	.D4  			(tx_clk_int[7]),
	.D3  			(tx_clk_int[6]),
	.D2  			(tx_clk_int[5]),
	.D1  			(tx_clk_int[4]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TRAIN    		(1'b0),
	.TCE	   		(1'b1),
	.SHIFTIN1 		(1'b1),			// Dummy input in Master
	.SHIFTIN2 		(1'b1),			// Dummy input in Master
	.SHIFTIN3 		(cascade_dco),		// Cascade output D data from slave
	.SHIFTIN4 		(cascade_tco),		// Cascade output T data from slave
	.SHIFTOUT1 		(cascade_dci),		// Cascade input D data to slave
	.SHIFTOUT2 		(cascade_tci),		// Cascade input T data to slave
	.SHIFTOUT3 		(),			// Dummy output in Master
	.SHIFTOUT4 		()) ;			// Dummy output in Master

OSERDES2 #(
	.DATA_WIDTH     	(S/2), 			// SERDES word width.  This should match the setting is BUFPLL
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_OT      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("SLAVE"), 		// <DEFAULT>, MASTER, SLAVE
	.OUTPUT_MODE 		("DIFFERENTIAL"))
oserdes_cs (
	.OQ       		(),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(tx_bufg_pll_x2),
	.D4  			(tx_clk_int[3]),
	.D3  			(tx_clk_int[2]),
	.D2  			(tx_clk_int[1]),
	.D1  			(tx_clk_int[0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3  			(1'b0),
	.T4  			(1'b0),
	.TRAIN 			(1'b0),
	.TCE	 		(1'b1),
	.SHIFTIN1 		(cascade_dci),		// Cascade input D from Master
	.SHIFTIN2 		(cascade_tci),		// Cascade input T from Master
	.SHIFTIN3 		(1'b1),			// Dummy input in Slave
	.SHIFTIN4 		(1'b1),			// Dummy input in Slave
	.SHIFTOUT1 		(),			// Dummy output in Slave
	.SHIFTOUT2 		(),			// Dummy output in Slave
	.SHIFTOUT3 		(cascade_dco),   	// Cascade output D data to Master
	.SHIFTOUT4 		(cascade_tco)) ; 	// Cascade output T data to Master

endmodule
