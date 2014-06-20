------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: top_nto1_pll_diff_rx_and_tx.vhd
--  /   /        Date Last Modified:  November 5 2009
-- /___/   /\    Date Created: June 1 2009
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	Example differential input receiver and transmitter for clock and data using PLL
--		Serdes factor and number of data lines are set by constants in the code
--Reference:
--    
--Revision History:
--    Rev 1.0 - First created (nicks)
--
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

entity top_nto1_pll_diff_rx_and_tx is port (
	reset			:  in std_logic ;                     		-- reset (active high)
	clkin_p, clkin_n	:  in std_logic ;                     		-- lvds clock input
	datain_p, datain_n	:  in std_logic_vector(5 downto 0) ;  		-- lvds data inputs
	clkout_p, clkout_n	: out std_logic ;             			-- lvds clock output
	dataout_p, dataout_n	: out std_logic_vector(5 downto 0)) ;  		-- lvds data outputs
end top_nto1_pll_diff_rx_and_tx ;

architecture arch_top_nto1_pll_diff_rx_and_tx of top_nto1_pll_diff_rx_and_tx is

component serdes_1_to_n_data_s8_diff generic (
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	D 			: integer := 16) ;				-- Set the number of inputs and outputs
port 	(
	use_phase_detector	:  in std_logic ;				-- Set generation of phase detector logic
	datain_p		:  in std_logic_vector(D-1 downto 0) ;		-- Input from LVDS receiver pin
	datain_n		:  in std_logic_vector(D-1 downto 0) ;		-- Input from LVDS receiver pin
	rxioclk			:  in std_logic ;				-- IO Clock network
	rxserdesstrobe		:  in std_logic ;				-- Parallel data capture strobe
	reset			:  in std_logic ;				-- Reset line
	gclk			:  in std_logic ;				-- Global clock
	bitslip			:  in std_logic ;				-- Bitslip control line
	debug_in  		:  in std_logic_vector(1 downto 0) ;		-- input debug data
	data_out		: out std_logic_vector((D*S)-1 downto 0) ;  	-- Output data
	debug			: out std_logic_vector((2*D)+6 downto 0)) ;  	-- Debug bus, 2D+6 = 2 lines per input (from mux and ce) + 7, leave nc if debug not required
end component ;

component serdes_1_to_n_clk_pll_s8_diff generic (
	PLLD 			: integer := 1 ;   				-- Parameter to set division for PLL 
	CLKIN_PERIOD		: real := 6.700 ;   				-- Set PLL multiplier
	PLLX 			: integer := 2 ;   				-- Set PLL multiplier
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	BS 			: boolean := FALSE) ;   			-- Parameter to enable bitslip TRUE or FALSE
port 	(
	clkin_p			:  in std_logic ;				-- Input from LVDS receiver pin
	clkin_n			:  in std_logic ;				-- Input from LVDS receiver pin
	reset			:  in std_logic ;				-- Reset line
	pattern1		:  in std_logic_vector(S-1 downto 0) ;  	-- Data to define pattern that bitslip should search for
	pattern2		:  in std_logic_vector(S-1 downto 0) ;  	-- Data to define alternate pattern that bitslip should search for
	rxioclk			: out std_logic ;				-- IO Clock network
	rx_serdesstrobe		: out std_logic ;				-- Parallel data capture strobe
	rx_bufg_pll_x1		: out std_logic ;				-- Global clock
	rx_pll_lckd  		: out std_logic ;				-- PLL locked - only used if a 2nd BUFPLL is required
	rx_pllout_xs 		: out std_logic ;				-- Multiplied PLL clock - only used if a 2nd BUFPLL is required
	bitslip			: out std_logic ;				-- Bitslip control line
	datain			: out std_logic_vector(S-1 downto 0) ;  	-- Output data
	rx_bufpll_lckd		: out std_logic); 				-- BUFPLL locked
end component ;

component serdes_n_to_1_s8_diff is generic (
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	D			: integer := 16) ;				-- Set the number of inputs and outputs
port 	(
	txioclk			:  in std_logic ;				-- IO Clock network
	txserdesstrobe		:  in std_logic ;				-- Parallel data capture strobe
	reset			:  in std_logic ;				-- Reset
	gclk			:  in std_logic ;				-- Global clock
	datain			:  in std_logic_vector((D*S)-1 downto 0) ;  	-- Data for output
	dataout_p		: out std_logic_vector(D-1 downto 0) ;		-- output
	dataout_n		: out std_logic_vector(D-1 downto 0)) ;		-- output
end component ;

-- Parameters for serdes factor and number of IO pins

constant S 	: integer := 7 ;						-- Set the serdes factor to be 4
constant D 	: integer := 6 ;						-- Set the number of inputs and outputs to be 6
constant DS 	: integer := (D*S)-1 ;						-- Used for bus widths = serdes factor * number of inputs - 1

signal 	clk_iserdes_data 	: std_logic_vector(6 downto 0) ;        
signal 	rx_bufg_x1		: std_logic ;               		
signal 	rxd			: std_logic_vector(DS downto 0)  ;	
signal	capture 		: std_logic_vector(6 downto 0)  ;
signal	counter			: std_logic_vector(3 downto 0)  ;
signal 	bitslip 		: std_logic  ;
signal	rst	 		: std_logic  ;
signal	rx_serdesstrobe		: std_logic  ;
signal	rx_bufpll_clk_xn	: std_logic  ;
signal	rx_bufpll_lckd		: std_logic  ;
signal	not_bufpll_lckd		: std_logic  ;
signal 	temp1p			: std_logic_vector(0 downto 0)  ;
signal 	temp1n			: std_logic_vector(0 downto 0)  ;
signal 	txd			: std_logic_vector(DS downto 0)  ;	

constant TX_CLK_GEN : std_logic_vector(S-1 downto 0) := "1100001" ;	-- Transmit a constant to make a clock

begin

rst <= reset ; 							-- active high reset pin

-- Clock Input, Generate ioclocks via PLL

clkin : serdes_1_to_n_clk_pll_s8_diff generic map(
      	CLKIN_PERIOD		=> 6.700,
	PLLD 			=> 1,
      	PLLX			=> S,
      	S			=> S,
	BS 			=> TRUE)    			-- Parameter to enable bitslip TRUE or FALSE (has to be true for video applications)
port map (
	clkin_p    		=> clkin_p,
	clkin_n    		=> clkin_n,
	rxioclk    		=> rx_bufpll_clk_xn,
	pattern1		=> "1100001",			-- default values for 7:1 video applications
	pattern2		=> "1100011",
	rx_serdesstrobe 	=> rx_serdesstrobe,
	rx_bufg_pll_x1 		=> rx_bufg_x1,
	bitslip   		=> bitslip,
	reset     		=> rst,
	datain  		=> clk_iserdes_data,
	rx_pll_lckd  		=> open,			-- PLL locked - only used if a 2nd BUFPLL is required
	rx_pllout_xs 		=> open,			-- Multiplied PLL clock - only used if a 2nd BUFPLL is required
	rx_bufpll_lckd		=> rx_bufpll_lckd) ;

-- Data Inputs

not_bufpll_lckd <= not rx_bufpll_lckd ;

datain : serdes_1_to_n_data_s8_diff generic map(
      	S			=> S,
      	D			=> D)
port map (
	use_phase_detector	=> '1',
	datain_p    		=> datain_p,
	datain_n    		=> datain_n,
	rxioclk    		=> rx_bufpll_clk_xn,
	rxserdesstrobe 		=> rx_serdesstrobe,
	gclk    		=> rx_bufg_x1,
	bitslip   		=> bitslip,
	reset   		=> not_bufpll_lckd,
	debug_in  		=> "00",
	data_out  		=> rxd,
	debug	  		=> open) ;

process (rx_bufg_x1)
begin
if rx_bufg_x1'event and rx_bufg_x1 = '1' then
	txd <= rxd ;
end if ;

end process ;

-- Transmitter Logic - Instantiate serialiser to generate forwarded clock

clkout : serdes_n_to_1_s8_diff generic map (
      	S			=> S,
      	D			=> 1)
port map (
	dataout_p   		=> temp1p,
	dataout_n   		=> temp1n,
	txioclk    		=> rx_bufpll_clk_xn,
	txserdesstrobe 		=> rx_serdesstrobe,
	gclk    		=> rx_bufg_x1,
	reset     		=> rst,
	datain  		=> TX_CLK_GEN);			-- Transmit a constant to make the clock

clkout_p <= temp1p(0) ;
clkout_n <= temp1n(0) ;

-- Instantiate Outputs and output serialisers for output data lines

dataout : serdes_n_to_1_s8_diff generic map(
      	S			=> S,
      	D			=> D)
port map (
	dataout_p   		=> dataout_p,
	dataout_n   		=> dataout_n,
	txioclk    		=> rx_bufpll_clk_xn,
	txserdesstrobe 		=> rx_serdesstrobe,
	gclk    		=> rx_bufg_x1,
	reset   		=> rst,
	datain  		=> txd);
	
end arch_top_nto1_pll_diff_rx_and_tx ;