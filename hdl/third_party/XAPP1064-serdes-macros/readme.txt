*******************************************************************************
** © Copyright 2009–20xx Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/    
**  \   \        readme.txt Version: 1.0  
**  /   /        Date Last Modified: November 6 2009
** /___/   /\    Date Created: November 6 2009
** \   \  /  \   Associated Filename: xapp1064.zip
**  \___\/\___\ 
** 
**  Device: Spartan 6
**  Purpose: ISERDES and OSERDES use in Spartan 6
**  Reference: XAPP1064.pdf
**  Revision History: Revision 1.0 initial release
**   
*******************************************************************************
**
**  Disclaimer: 
**
**		This disclaimer is not a license and does not grant any rights to the materials 
**              distributed herewith. Except as otherwise provided in a valid license issued to you 
**              by Xilinx, and to the maximum extent permitted by applicable law: 
**              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**              or tort, including negligence, or under any other theory of liability) for any loss or damage 
**              of any kind or nature related to, arising under or in connection with these materials, 
**              including for any direct, or any indirect, special, incidental, or consequential loss 
**              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**              as a result of any action brought by a third party) even if such damage or loss was 
**              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
**
**  Critical Applications:
**
**		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
**		requiring fail-safe performance, such as life-support or safety devices or systems, 
**		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
**		or any other applications that could lead to death, personal injury, or severe property or 
**		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
**		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
**		to applicable laws and regulations governing limitations on product liability.

**  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

*******************************************************************************

This readme describes how to use the files that come with XAPP1064.

*******************************************************************************

** IMPORTANT NOTES **

1) 

2)
******************************************************************************* 

Included Files

Macros

Clock Generator Designs            
                                   
clock_generator_ddr_s8_diff.v/vhd        
clock_generator_pll_s16_diff.v/vhd         
clock_generator_pll_s8_diff.v/vhd          
clock_generator_sdr_s8_diff.v/vhd          
                                   
Clock Receivers                    
                                   
serdes_1_to_n_clk_ddr_s8_diff.v/vhd        
serdes_1_to_n_clk_ddr_s8_se.v/vhd          
serdes_1_to_n_clk_pll_s16_diff.v/vhd       
serdes_1_to_n_clk_pll_s8_diff.v/vhd        
serdes_1_to_n_clk_pll_s8_se.v/vhd          
serdes_1_to_n_clk_sdr_s8_diff.v/vhd        
                                   
Data Receivers                     
                                   
serdes_1_to_n_data_ddr_s8_diff.v/vhd       
serdes_1_to_n_data_ddr_s8_se.v/vhd         
serdes_1_to_n_data_s16_diff.v/vhd          
serdes_1_to_n_data_s8_diff.v/vhd           
serdes_1_to_n_data_s8_se.v/vhd             
                                   
Data Transmitters                  
                                   
serdes_n_to_1_ddr_s8_diff.v/vhd            
serdes_n_to_1_ddr_s8_se.v/vhd              
serdes_n_to_1_s16_diff.v/vhd               
serdes_n_to_1_s8_diff.v/vhd                
serdes_n_to_1_s8_se.v/vhd                 


Top Level Examples ucfs, and testbenches

n to 1 DDR BUFIO2 based transmitter 
n to 1 DDR BUFIO2 based receiver 

n to 1 PLL based transmitter 
n to 1 PLL based receiver
