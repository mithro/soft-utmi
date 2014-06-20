------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: serdes_1_to_n_clk_ddr_s8_diff.vhd
--  /   /        Date Last Modified:  November 5 2009
-- /___/   /\    Date Created: August 1 2008
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	1-bit generic 1:n DDR clock receiver module for serdes factors from 2 to 8 with differential inputs
-- 		Instantiates necessary BUFIO2 clock buffers
--
--Reference:
--    
--Revision History:
--    Rev 1.0 - First created (nicks)
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

library unisim ;
use unisim.vcomponents.all ;

entity serdes_1_to_n_clk_ddr_s8_diff is generic (
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	DIFF_TERM		: boolean := FALSE) ;				-- Enable or disable internal differential termination
port 	(
	clkin_p			:  in std_logic ;				-- Input from LVDS receiver pin
	clkin_n			:  in std_logic ;				-- Input from LVDS receiver pin
	rxioclkp		: out std_logic ;				-- IO Clock network
	rxioclkn		: out std_logic ;				-- IO Clock network
	rx_serdesstrobe		: out std_logic ;				-- Parallel data capture strobe
	rx_bufg_x1		: out std_logic) ;				-- Global clock
end serdes_1_to_n_clk_ddr_s8_diff ;

architecture arch_serdes_1_to_n_clk_ddr_s8_diff of serdes_1_to_n_clk_ddr_s8_diff is

signal	ddly_m			: std_logic;     	-- Master output from IODELAY1
signal	ddly_s			: std_logic;     	-- Slave output from IODELAY1
signal	rx_clk_in 		: std_logic;		--
signal	iob_data_in_p 		: std_logic;		--
signal	iob_data_in_n 		: std_logic;		--
signal	rx_clk_in_p 		: std_logic;		--
signal	rx_clk_in_n 		: std_logic;		--
signal	rx_bufio2_x1 		: std_logic;		--

constant RX_SWAP_CLK  		: std_logic := '0' ;			-- pinswap mask for input clock (0 = no swap (default), 1 = swap). Allows input to be connected the wrong way round to ease PCB routing.

begin

iob_clk_in : IBUFDS_DIFF_OUT generic map(
	DIFF_TERM		=> DIFF_TERM)
port map (
	I    			=> clkin_p,
	IB       		=> clkin_n,
	O         		=> rx_clk_in_p,
	OB         		=> rx_clk_in_n) ;

iob_data_in_p <= rx_clk_in_p xor RX_SWAP_CLK ;		-- Invert clock as required
iob_data_in_n <= rx_clk_in_n xor RX_SWAP_CLK ;		-- Invert clock as required


iodelay_m : IODELAY2 generic map(
	DATA_RATE      		=> "SDR", 			-- <SDR>, DDR
	SIM_TAPDELAY_VALUE	=> 49,  			-- nominal tap delay (sim parameter only)
	IDELAY_VALUE  		=> 0, 				-- {0 ... 255}
	IDELAY2_VALUE 		=> 0, 				-- {0 ... 255}
	ODELAY_VALUE  		=> 0, 				-- {0 ... 255}
	IDELAY_MODE   		=> "NORMAL", 			-- "NORMAL", "PCI"
	SERDES_MODE   		=> "MASTER", 			-- <NONE>, MASTER, SLAVE
	IDELAY_TYPE   		=> "FIXED", 			-- "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	COUNTER_WRAPAROUND 	=> "STAY_AT_LIMIT", 		-- <STAY_AT_LIMIT>, WRAPAROUND
	DELAY_SRC     		=> "IDATAIN") 			-- "IO", "IDATAIN", "ODATAIN"
port map (
	IDATAIN  		=> iob_data_in_p, 		-- data from master IOB
	TOUT     		=> open, 			-- tri-state signal to IOB
	DOUT     		=> open, 			-- output data to IOB
	T        		=> '1', 			-- tri-state control from OLOGIC/OSERDES2
	ODATAIN  		=> '0', 			-- data from OLOGIC/OSERDES2
	DATAOUT  		=> ddly_m, 			-- Output data 1 to ILOGIC/ISERDES2
	DATAOUT2 		=> open,	 		-- Output data 2 to ILOGIC/ISERDES2
	IOCLK0   		=> '0', 			-- High speed clock for calibration
	IOCLK1   		=> '0', 			-- High speed clock for calibration
	CLK      		=> '0', 			-- Fabric clock (GCLK) for control signals
	CAL      		=> '0', 			-- Calibrate enable signal
	INC      		=> '0', 			-- Increment counter
	CE       		=> '0', 			-- Clock Enable
	RST      		=> '0', 			-- Reset delay line to 1/2 max in this case
	BUSY      		=> open) ;  			-- output signal indicating sync circuit has finished / calibration has finished


iodelay_s : IODELAY2 generic map(
	DATA_RATE      		=> "SDR", 			-- <SDR>, DDR
	SIM_TAPDELAY_VALUE	=> 49,  			-- nominal tap delay (sim parameter only)
	IDELAY_VALUE  		=> 0, 				-- {0 ... 255}
	IDELAY2_VALUE 		=> 0, 				-- {0 ... 255}
	ODELAY_VALUE  		=> 0, 				-- {0 ... 255}
	IDELAY_MODE   		=> "NORMAL", 			-- "NORMAL", "PCI"
	SERDES_MODE   		=> "SLAVE", 			-- <NONE>, MASTER, SLAVE
	IDELAY_TYPE   		=> "FIXED", 			-- "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	COUNTER_WRAPAROUND 	=> "STAY_AT_LIMIT", 		-- <STAY_AT_LIMIT>, WRAPAROUND
	DELAY_SRC     		=> "IDATAIN") 			-- "IO", "IDATAIN", "ODATAIN"
port map (
	IDATAIN 		=> iob_data_in_n, 		-- data from slave IOB
	TOUT     		=> open, 			-- tri-state signal to IOB
	DOUT     		=> open, 			-- output data to IOB
	T        		=> '1', 			-- tri-state control from OLOGIC/OSERDES2
	ODATAIN  		=> '0', 			-- data from OLOGIC/OSERDES2
	DATAOUT 		=> ddly_s, 			-- Output data 1 to ILOGIC/ISERDES2
	DATAOUT2 		=> open,	 		-- Output data 2 to ILOGIC/ISERDES2
	IOCLK0    		=> '0', 			-- High speed clock for calibration
	IOCLK1   		=> '0', 			-- High speed clock for calibration
	CLK      		=> '0', 			-- Fabric clock (GCLK) for control signals
	CAL      		=> '0', 			-- Calibrate control signal, never needed as the slave supplies the clock input to the PLL
	INC      		=> '0', 			-- Increment counter
	CE       		=> '0', 			-- Clock Enable
	RST      		=> '0', 			-- Reset delay line
	BUSY      		=> open) ;			-- output signal indicating sync circuit has finished / calibration has finished

bufg_pll_x1 : BUFG port map	(I => rx_bufio2_x1, O => rx_bufg_x1) ;

bufio2_2clk_inst : BUFIO2_2CLK generic map(
      DIVIDE			=> S)               		-- The DIVCLK divider divide-by value; default 1
port map (
      I				=> ddly_m,  			-- Input source clock 0 degrees
      IB			=> ddly_s,  			-- Input source clock 0 degrees
      IOCLK			=> rxioclkp,        		-- Output Clock for IO
      DIVCLK			=> rx_bufio2_x1,                -- Output Divided Clock
      SERDESSTROBE		=> rx_serdesstrobe) ;           -- Output SERDES strobe (Clock Enable)

bufio2_inst : BUFIO2 generic map(
      I_INVERT			=> FALSE,               	--
      DIVIDE_BYPASS		=> FALSE,               	--
      USE_DOUBLER		=> FALSE)               	--
port map (
      I				=> ddly_s,               	-- N_clk input from IDELAY
      IOCLK			=> rxioclkn,        		-- Output Clock
      DIVCLK			=> open,                	-- Output Divided Clock
      SERDESSTROBE		=> open) ;           		-- Output SERDES strobe (Clock Enable)

end arch_serdes_1_to_n_clk_ddr_s8_diff ;
