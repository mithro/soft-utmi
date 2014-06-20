------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: serdes_1_to_n_clk_ddr_s8_se.vhd
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

entity serdes_1_to_n_clk_ddr_s8_se is generic (
	S			: integer := 8) ;	-- Parameter to set the serdes factor 1..8
port 	(
	clkin1			:  in std_logic ;	-- Input from se receiver pin
	clkin2			:  in std_logic ;	-- Input from se receiver pin
	rxioclkp		: out std_logic ;	-- IO Clock network
	rxioclkn		: out std_logic ;	-- IO Clock network
	rx_serdesstrobe		: out std_logic ;	-- Parallel data capture strobe
	rx_bufg_x1		: out std_logic) ;	-- Global clock
end serdes_1_to_n_clk_ddr_s8_se ;

architecture arch_serdes_1_to_n_clk_ddr_s8_se of serdes_1_to_n_clk_ddr_s8_se is

signal	ddly_m			: std_logic;     	-- Master output from IODELAY1
signal	ddly_s			: std_logic;     	-- Slave output from IODELAY1
signal	rx_clk_in 		: std_logic;		--
signal	iob_data_in_p 		: std_logic;		--
signal	iob_data_in_n 		: std_logic;		--
signal	rx_clk_in_p 		: std_logic;		--
signal	rx_clk_in_n 		: std_logic;		--
signal	rx_bufio2_x1 		: std_logic;		--

constant RX_SWAP_CLK  		: std_logic := '0' ;		-- pinswap mask for input clock (0 = no swap (default), 1 = swap). Allows input to be connected the wrong way round to ease PCB routing.

begin

iob_clk_in1 : IBUFG port map (
	I    			=> clkin1,
	O         		=> rx_clk_in_p) ;

iob_clk_in2 : IBUFG port map (
	I    			=> clkin2,
	O         		=> rx_clk_in_n) ;
	
iob_data_in_p <= rx_clk_in_p xor RX_SWAP_CLK ;			-- Invert clock as required
iob_data_in_n <= not rx_clk_in_n xor RX_SWAP_CLK ;		-- Invert clock as required, remembering the 2nd parallle clock input needs to be inverted


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
      DIVCLK			=> rx_bufio2_x1,                	-- Output Divided Clock
      SERDESSTROBE		=> rx_serdesstrobe) ;           	-- Output SERDES strobe (Clock Enable)

bufio2_inst : BUFIO2 generic map(
      I_INVERT			=> FALSE,               	--
      DIVIDE_BYPASS		=> FALSE,               	--
      USE_DOUBLER		=> FALSE)               	--
port map (
      I				=> ddly_s,               	-- N_clk input from IDELAY
      IOCLK			=> rxioclkn,        		-- Output Clock
      DIVCLK			=> open,                	-- Output Divided Clock
      SERDESSTROBE		=> open) ;           		-- Output SERDES strobe (Clock Enable)

end arch_serdes_1_to_n_clk_ddr_s8_se ;
