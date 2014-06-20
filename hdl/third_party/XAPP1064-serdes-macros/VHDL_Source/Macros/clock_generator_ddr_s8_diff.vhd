------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: clock_generator_ddr_s8_diff.vhd
--  /   /        Date Last Modified:  November 5 2009
-- /___/   /\    Date Created: August 1 2008
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	BUFIO2 Based DDR clock generator. Takes in a differential clock 
--		and instantiates two sets of 2 BUFIO2s, one for each half bank
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

entity clock_generator_ddr_s8_diff is generic (
	S			: integer := 8 ;		-- Parameter to set the serdes factor
	DIFF_TERM		: boolean := FALSE) ;		-- Enable or disable internal differential termination
port (
	clkin_p, clkin_n	:  in std_logic ;               -- differential clock input
	ioclkap			: out std_logic ;             	-- A P ioclock from BUFIO2
	ioclkan			: out std_logic ;             	-- A N ioclock from BUFIO2
	serdesstrobea		: out std_logic ;             	-- A serdes strobe from BUFIO2
	ioclkbp			: out std_logic ;             	-- B P ioclock from BUFIO2 - leave open if not required
	ioclkbn			: out std_logic ;             	-- B N ioclock from BUFIO2 - leave open if not required
	serdesstrobeb		: out std_logic ;             	-- B serdes strobe from BUFIO2 - leave open if not required
	gclk			: out std_logic) ;             	-- global clock output from BUFIO2
end clock_generator_ddr_s8_diff ;

architecture arch_clock_generator_ddr_s8_diff of clock_generator_ddr_s8_diff is

signal 	clkint			: std_logic ;			--
signal 	gclk_int		: std_logic ;			--
signal 	freqgen_in_p	      	: std_logic ;			--
signal 	tx_bufio2_x1	      	: std_logic ;			--

begin

gclk <= gclk_int ;

iob_freqgen_in : IBUFGDS generic map(
	DIFF_TERM		=> DIFF_TERM)
port map (
	I    			=> clkin_p,
	IB       		=> clkin_n,
	O         		=> freqgen_in_p);

bufio2_inst1 : BUFIO2 generic map(
      DIVIDE			=> S,              		-- The DIVCLK divider divide-by value; default 1
      I_INVERT			=> FALSE,               	--
      DIVIDE_BYPASS		=> FALSE,               	--
      USE_DOUBLER		=> TRUE)               		--
port map (
      I				=> freqgen_in_p,  		-- Input source clock 0 degrees
      IOCLK			=> ioclkap,        		-- Output Clock for IO
      DIVCLK			=> tx_bufio2_x1,                -- Output Divided Clock
      SERDESSTROBE		=> serdesstrobea) ;           	-- Output SERDES strobe (Clock Enable)

bufio2_inst2 : BUFIO2 generic map(
      I_INVERT			=> TRUE,               		--
      DIVIDE_BYPASS		=> FALSE,               	--
      USE_DOUBLER		=> FALSE)               	--
port map (
      I				=> freqgen_in_p,               	-- N_clk input from IDELAY
      IOCLK			=> ioclkan,        		-- Output Clock
      DIVCLK			=> open,                	-- Output Divided Clock
      SERDESSTROBE		=> open) ;           		-- Output SERDES strobe (Clock Enable)

bufio2_inst3 : BUFIO2 generic map(
      DIVIDE			=> S,              		-- The DIVCLK divider divide-by value; default 1
      I_INVERT			=> FALSE,               	--
      DIVIDE_BYPASS		=> FALSE,               	--
      USE_DOUBLER		=> TRUE)               		--
port map (
      I				=> freqgen_in_p,  		-- Input source clock 0 degrees
      IOCLK			=> ioclkbp,        		-- Output Clock for IO
      DIVCLK			=> open,                	-- Output Divided Clock
      SERDESSTROBE		=> serdesstrobeb) ;           	-- Output SERDES strobe (Clock Enable)

bufio2_inst4 : BUFIO2 generic map(
      I_INVERT			=> TRUE,               		--
      DIVIDE_BYPASS		=> FALSE,               	--
      USE_DOUBLER		=> FALSE)               	--
port map  (
      I				=> freqgen_in_p,               	-- N_clk input from IDELAY
      IOCLK			=> ioclkbn,        		-- Output Clock
      DIVCLK			=> open,                	-- Output Divided Clock
      SERDESSTROBE		=> open) ;           		-- Output SERDES strobe (Clock Enable)

bufg_tx : BUFG port map	 (I => tx_bufio2_x1, O => gclk_int) ;

end arch_clock_generator_ddr_s8_diff ;