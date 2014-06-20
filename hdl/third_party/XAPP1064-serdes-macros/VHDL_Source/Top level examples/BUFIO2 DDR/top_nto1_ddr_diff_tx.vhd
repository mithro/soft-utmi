------------------------------------------------------------------------------/
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------/
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: top_nto1_ddr_diff_tx.vhd
--  /   /        Date Last Modified:  November 5 2009
-- /___/   /\    Date Created: June 1 2009
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	Example differential output transmitter for DDR clock and data using 2 x BUFIO2
--		Serdes factor and number of data lines are set by constants in the code
--Reference:
--    
--Revision History:
--    Rev 1.0 - First created (nicks)
--
------------------------------------------------------------------------------/
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
--		to applicable laws and signalulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

library unisim ;
use unisim.vcomponents.all ;

entity top_nto1_ddr_diff_tx is port (
	reset				:  in std_logic ;			-- reset (active high)
	refclkin_p,  refclkin_n		:  in std_logic ;			-- frequency generator clock input
	dataout_p, dataout_n		: out std_logic_vector(7 downto 0) ;	-- differential data outputs
	clkout_p, clkout_n		: out std_logic ) ;			-- differential clock output
end top_nto1_ddr_diff_tx ;

architecture arch_top_nto1_ddr_diff_tx of top_nto1_ddr_diff_tx is

component clock_generator_ddr_s8_diff is generic (
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
end component ;

component serdes_n_to_1_ddr_s8_diff is generic (
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	D			: integer := 16) ;				-- Set the number of inputs and outputs
port 	(
	txioclkp		:  in std_logic ;				-- IO Clock network
	txioclkn		:  in std_logic ;				-- IO Clock network
	txserdesstrobe		:  in std_logic ;				-- Parallel data capture strobe
	reset			:  in std_logic ;				-- Reset
	gclk			:  in std_logic ;				-- Global clock
	datain			:  in std_logic_vector((D*S)-1 downto 0) ;  	-- Data for output
	dataout_p		: out std_logic_vector(D-1 downto 0) ;		-- output
	dataout_n		: out std_logic_vector(D-1 downto 0)) ;		-- output
end component ;

-- Parameters for serdes factor and number of IO pins

constant S		: integer := 8 ;				-- Set the serdes factor
constant D		: integer := 8 ;				-- Set the number of inputs and outputs
constant DS		: integer := (D*S)-1 ;				-- Used for bus widths = serdes factor * number of inputs - 1
                                                                	
signal	rst 			: std_logic ;                           	
signal	txd			: std_logic_vector(DS downto 0) ;	-- Registered Data to serdeses
signal	txioclkp 		: std_logic ;                           	
signal	txioclkn 		: std_logic ;                           	
signal	tx_serdesstrobe 	: std_logic ;                           	
signal	tx_bufg_x1	 	: std_logic ;                           	
signal	clkoutp		 	: std_logic_vector(0 downto 0) ;                           	
signal	clkoutn		 	: std_logic_vector(0 downto 0) ;                           	

-- Parameters for clock generation

constant TX_CLK_GEN   	: std_logic_vector(S-1 downto 0) := X"AA" ;	-- Transmit a constant to make a clock

begin

rst <= reset ; 

-- Reference Clock Input genertaes IO clocks via 2 x BUFIO2

inst_clkgen : clock_generator_ddr_s8_diff generic map(
	S 			=> S)
port map(
	clkin_p			=> refclkin_p, 
	clkin_n			=> refclkin_n,
	ioclkap			=> txioclkp,
	ioclkan			=> txioclkn,
	serdesstrobea		=> tx_serdesstrobe,
	ioclkbp			=> open,
	ioclkbn			=> open,
	serdesstrobeb		=> open,
	gclk			=> tx_bufg_x1) ;

process (tx_bufg_x1, rst)					-- Generate some data to transmit
begin
if rst = '1' then
	txd <= X"3000000000000001" ;
elsif tx_bufg_x1'event and tx_bufg_x1 = '1' then
	txd <= txd(63 downto 60) & txd(58 downto 0) & txd(59) ;
end if ;
end process ;

-- Transmitter Logic - Instantiate serialiser to generate forwarded clock

inst_clkout : serdes_n_to_1_ddr_s8_diff generic map(
      	S			=> S,
      	D			=> 1)
port map (                   
	dataout_p  		=> clkoutp,
	dataout_n  		=> clkoutn,
	txioclkp    		=> txioclkp,
	txioclkn    		=> txioclkn,
	txserdesstrobe 		=> tx_serdesstrobe,
	gclk    		=> tx_bufg_x1,
	reset     		=> rst,
	datain  		=> TX_CLK_GEN);			-- Transmit a constant to make the clock

clkout_p <= clkoutp(0) ;
clkout_n <= clkoutn(0) ;

-- Instantiate Outputs and output serialisers for output data lines

inst_dataout : serdes_n_to_1_ddr_s8_diff generic map(
      	S			=> S,
      	D			=> D)
port map (                  
	dataout_p  		=> dataout_p,
	dataout_n  		=> dataout_n,
	txioclkp    		=> txioclkp,
	txioclkn    		=> txioclkn,
	txserdesstrobe 		=> tx_serdesstrobe,
	gclk    		=> tx_bufg_x1,
	reset   		=> rst,
	datain  		=> txd);

end arch_top_nto1_ddr_diff_tx ;
