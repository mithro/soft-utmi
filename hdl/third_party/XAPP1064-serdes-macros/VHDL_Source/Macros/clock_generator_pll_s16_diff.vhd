------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: clock_generator_pll_s16_diff.vhd
--  /   /        Date Last Modified:  November 5 2009
-- /___/   /\    Date Created: August 1 2008
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	PLL Based clock generator. Takes in a differential clock and multiplies it
--		by the amount specified. Instantiates a BUFIO2, BUFPLL and a PLL using 
--		INTERNAL feedback
--
--Reference:
--    
--Revision History:
--    Rev 1.0 - First created (nicks)
------------------------------------------------------------------------------
--
--  Disclaimer: 
--
--		This disclaimer is not a license and does not grant any rights to the materials 
--              distributed herewith. Except as otherwise provided in a valid license issued to you 
--              by Xilinx, and to the maximum extent permitted by applicable law: 
--              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
--              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
--              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
--              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
--              or tort, including negligence, or under any other theory of liability) for any loss or damage 
--              of any kind or nature related to, arising under or in connection with these materials, 
--              including for any direct, or any indirect, special, incidental, or consequential loss 
--              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
--              as a result of any action brought by a third party) even if such damage or loss was 
--              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
--  Critical Applications:
--
--		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
--		requiring fail-safe performance, such as life-support or safety devices or systems, 
--		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
--		or any other applications that could lead to death, personal injury, or severe property or 
--		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
--		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
--		to applicable laws and regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

library unisim ;
use unisim.vcomponents.all ;

entity clock_generator_pll_s16_diff is generic (
	PLLD			: integer := 1 ;				-- Parameter to set the division factor in the PLL
	PLLX			: integer := 8 ;				-- Parameter to set the multiplication factor in the PLL
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	CLKIN_PERIOD		: real := 6.000 ;				-- clock period (ns) of input clock on clkin_p
	DIFF_TERM		: boolean := FALSE) ;				-- Enable or disable internal differential termination
port 	(
	reset			:  in std_logic ;                     		-- reset (active high)
	clkin_p, clkin_n	:  in std_logic ;                     		-- differential clock input
	ioclk			: out std_logic ;             			-- ioclock from BUFPLL
	serdesstrobe		: out std_logic ;             			-- serdes strobe from BUFPLL
	gclk1			: out std_logic ;             			-- global clock output from BUFG x1
	gclk2			: out std_logic ;             			-- global clock output from BUFG x2
	bufpll_lckd		: out std_logic) ; 				-- Locked output from BUFPLL
end clock_generator_pll_s16_diff ;

architecture arch_clock_generator_pll_s16_diff of clock_generator_pll_s16_diff is

signal 	clkint			: std_logic ;			--
signal 	dummy			: std_logic ;			--
signal 	pllout_xs		: std_logic ;			--
signal 	pllout_x1		: std_logic ;			--
signal 	pllout_x2		: std_logic ;			--
signal 	pll_lckd		: std_logic ;			--
signal 	gclk2_int		: std_logic ;			--
signal 	buf_pll_lckd		:std_logic ;

begin

gclk2 <= gclk2_int ;

iob_freqgen_in : IBUFDS generic map(
	DIFF_TERM		=> DIFF_TERM)
port map (
	I    			=> clkin_p,
	IB       		=> clkin_n,
	O         		=> clkint);

tx_pll_adv_inst : PLL_ADV generic map(
      BANDWIDTH			=> "OPTIMIZED",  		-- "high", "low" or "optimized"
      CLKFBOUT_MULT		=> PLLX,       			-- multiplication factor for all output clocks
      CLKFBOUT_PHASE		=> 0.0,     			-- phase shift (degrees) of all output clocks
      CLKIN1_PERIOD		=> CLKIN_PERIOD,  		-- clock period (ns) of input clock on clkin1
      CLKIN2_PERIOD		=> CLKIN_PERIOD,  		-- clock period (ns) of input clock on clkin2
      CLKOUT0_DIVIDE		=> 1,       			-- division factor for clkout0 (1 to 128)
      CLKOUT0_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout0 (0.01 to 0.99)
      CLKOUT0_PHASE		=> 0.0, 			-- phase shift (degrees) for clkout0 (0.0 to 360.0)
      CLKOUT1_DIVIDE		=> 1,   			-- division factor for clkout1 (1 to 128)
      CLKOUT1_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout1 (0.01 to 0.99)
      CLKOUT1_PHASE		=> 0.0, 			-- phase shift (degrees) for clkout1 (0.0 to 360.0)
      CLKOUT2_DIVIDE		=> S,   			-- division factor for clkout2 (1 to 128)
      CLKOUT2_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout2 (0.01 to 0.99)
      CLKOUT2_PHASE		=> 0.0, 			-- phase shift (degrees) for clkout2 (0.0 to 360.0)
      CLKOUT3_DIVIDE		=> S/2,   			-- division factor for clkout3 (1 to 128)
      CLKOUT3_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout3 (0.01 to 0.99)
      CLKOUT3_PHASE		=> 0.0, 			-- phase shift (degrees) for clkout3 (0.0 to 360.0)
      CLKOUT4_DIVIDE		=> S,   			-- division factor for clkout4 (1 to 128)
      CLKOUT4_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout4 (0.01 to 0.99)
      CLKOUT4_PHASE		=> 0.0,      			-- phase shift (degrees) for clkout4 (0.0 to 360.0)
      CLKOUT5_DIVIDE		=> S,       			-- division factor for clkout5 (1 to 128)
      CLKOUT5_DUTY_CYCLE	=> 0.5, 			-- duty cycle for clkout5 (0.01 to 0.99)
      CLKOUT5_PHASE		=> 0.0,      			-- phase shift (degrees) for clkout5 (0.0 to 360.0)
      COMPENSATION		=> "INTERNAL",			-- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "INTERNAL", "EXTERNAL", "DCM2PLL", "PLL2DCM"
      DIVCLK_DIVIDE		=> PLLD,       			-- division factor for all clocks (1 to 52)
      REF_JITTER		=> 0.100)       		-- input reference jitter (0.000 to 0.999 ui%)
port map (
      CLKFBDCM			=> open,              		-- output feedback signal used when pll feeds a dcm
      CLKFBOUT			=> dummy,              		-- general output feedback signal
      CLKOUT0			=> pllout_xs,      		-- x7 clock for transmitter
      CLKOUT1			=> open,      			--
      CLKOUT2			=> pllout_x1,              	-- x1 clock for BUFG
      CLKOUT3			=> pllout_x2,              	-- x2 clock for BUFG
      CLKOUT4			=> open,              		-- one of six general clock output signals
      CLKOUT5			=> open,              		-- one of six general clock output signals
      CLKOUTDCM0		=> open,            		-- one of six clock outputs to connect to the dcm
      CLKOUTDCM1		=> open,            		-- one of six clock outputs to connect to the dcm
      CLKOUTDCM2		=> open,            		-- one of six clock outputs to connect to the dcm
      CLKOUTDCM3		=> open,            		-- one of six clock outputs to connect to the dcm
      CLKOUTDCM4		=> open,            		-- one of six clock outputs to connect to the dcm
      CLKOUTDCM5		=> open,            		-- one of six clock outputs to connect to the dcm
      DO			=> open,                	-- dynamic reconfig data output (16-bits)
      DRDY			=> open,                	-- dynamic reconfig ready output
      LOCKED			=> pll_lckd,        		-- active high pll lock signal
      CLKFBIN			=> dummy,			-- clock feedback input
      CLKIN1			=> clkint,	     		-- primary clock input
      CLKIN2			=> '0', 	    		-- secondary clock input
      CLKINSEL			=> '1',             		-- selects '1' = clkin1, '0' = clkin2
      DADDR			=> "00000",            		-- dynamic reconfig address input (5-bits)
      DCLK			=> '0',               		-- dynamic reconfig clock input
      DEN			=> '0',                		-- dynamic reconfig enable input
      DI			=> "0000000000000000", 		-- dynamic reconfig data input (16-bits)
      DWE			=> '0',                		-- dynamic reconfig write enable input
      RST			=> reset,               	-- asynchronous pll reset
      REL			=> '0') ;               	-- used to force the state of the PFD outputs (test only)

bufg_tx_x1 : BUFG port map (I => pllout_x1, O => gclk1 ) ;
bufg_tx_x2 : BUFG port map (I => pllout_x2, O => gclk2_int ) ;

tx_bufpll_inst : BUFPLL generic map(
      DIVIDE			=> S/2)              		-- PLLIN0 divide-by value to produce SERDESSTROBE (1 to 8); default 1
port map (
      PLLIN			=> pllout_xs,        		-- PLL Clock input
      GCLK			=> gclk2_int,	 		-- Global Clock input
      LOCKED			=> pll_lckd,             	-- Clock0 locked input
      IOCLK			=> ioclk,	 		-- Output PLL Clock
      LOCK			=> buf_pll_lckd,          	-- BUFPLL Clock and strobe locked
      SERDESSTROBE		=> serdesstrobe) ; 		-- Output SERDES strobe

bufpll_lckd <= buf_pll_lckd and pll_lckd ;

end arch_clock_generator_pll_s16_diff ;