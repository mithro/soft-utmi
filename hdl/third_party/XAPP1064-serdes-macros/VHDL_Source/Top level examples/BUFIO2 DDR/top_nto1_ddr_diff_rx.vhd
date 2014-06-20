------------------------------------------------------------------------------/
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------/
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: top_nto1_ddr_diff_rx.vhd
--  /   /        Date Last Modified:  November 5 2009
-- /___/   /\    Date Created: June 1 2009
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	Example differential input receiver for DDR clock and data using 2 x BUFIO2
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

entity top_nto1_ddr_diff_rx is port (
	reset			:  in std_logic ;				-- reset (active high)
	datain_p, datain_n	:  in std_logic_vector(7 downto 0) ;		-- differential data inputs
	clkin_p,  clkin_n	:  in std_logic ;				-- differential clock input
	dummy_out		: out std_logic_vector(63 downto 0) ) ;		-- dummy outputs
end top_nto1_ddr_diff_rx ;

architecture arch_top_nto1_ddr_diff_rx of top_nto1_ddr_diff_rx is

component serdes_1_to_n_clk_ddr_s8_diff is generic (
	S			: integer := 8) ;				-- Parameter to set the serdes factor 1..8
port 	(                                               			
	clkin_p			:  in std_logic ;				-- Input from LVDS receiver pin
	clkin_n			:  in std_logic ;				-- Input from LVDS receiver pin
	rxioclkp		: out std_logic ;				-- IO Clock network
	rxioclkn		: out std_logic ;				-- IO Clock network
	rx_serdesstrobe		: out std_logic ;				-- Parallel data capture strobe
	rx_bufg_x1		: out std_logic) ;				-- Global clock
end component ;

component serdes_1_to_n_data_ddr_s8_diff is generic (
	S			: integer := 8 ;				-- Parameter to set the serdes factor 1..8
	D 			: integer := 16) ;				-- Set the number of inputs and outputs
port 	(
	use_phase_detector	:  in std_logic ;				-- '1' enables the phase detector logic if USE_PD = TRUE
	datain_p		:  in std_logic_vector(D-1 downto 0) ;		-- Input from LVDS receiver pin
	datain_n		:  in std_logic_vector(D-1 downto 0) ;		-- Input from LVDS receiver pin
	rxioclkp		:  in std_logic ;				-- IO Clock network
	rxioclkn		:  in std_logic ;				-- IO Clock network
	rxserdesstrobe		:  in std_logic ;				-- Parallel data capture strobe
	reset			:  in std_logic ;				-- Reset line
	gclk			:  in std_logic ;				-- Global clock
	bitslip			:  in std_logic ;				-- Bitslip control line
	data_out		: out std_logic_vector((D*S)-1 downto 0) ;  	-- Output data
	debug_in		:  in std_logic_vector(1 downto 0) ;  		-- Debug Inputs, set to '0' if not required
	debug			: out std_logic_vector((2*D)+6 downto 0)) ;  	-- Debug output bus, 2D+6 = 2 lines per input (from mux and ce) + 7, leave nc if debug not required
end component ;

-- constants for serdes factor and number of IO pins

constant S			: integer := 8 ;			-- Set the serdes factor to 8
constant D			: integer := 8 ;			-- Set the number of inputs and outputs
constant DS			: integer := (D*S)-1 ;			-- Used for bus widths = serdes factor * number of inputs - 1
                        	
signal  rst			: std_logic ;
signal	rxd			: std_logic_vector(DS downto 0) ;	-- Data from serdeses
signal	rxr 			: std_logic_vector(DS downto 0);	-- signalistered Data from serdeses
signal	state			: std_logic ;
signal 	bslip			: std_logic ;
signal	count 			: std_logic_vector(3 downto 0);
signal 	rxioclkp		: std_logic ;
signal 	rxioclkn		: std_logic ;
signal 	rx_serdesstrobe		: std_logic ;
signal 	rx_bufg_x1		: std_logic ;

begin

rst <= reset ; 				-- active high reset pin
dummy_out <= rxr ;

-- Clock Input. Generate ioclocks via BUFIO2

inst_clkin : serdes_1_to_n_clk_ddr_s8_diff generic map(
      	S			=> S) 		
port map (
	clkin_p   		=> clkin_p,
	clkin_n   		=> clkin_n,
	rxioclkp    		=> rxioclkp,
	rxioclkn   		=> rxioclkn,
	rx_serdesstrobe		=> rx_serdesstrobe,
	rx_bufg_x1		=> rx_bufg_x1);

-- Data Inputs

inst_datain : serdes_1_to_n_data_ddr_s8_diff generic map(
      	S			=> S,			
      	D			=> D)
port map (                   
	use_phase_detector 	=> '1',			-- '1' enables the phase detector logic
	datain_p     		=> datain_p,
	datain_n     		=> datain_n,
	rxioclkp    		=> rxioclkp,
	rxioclkn   		=> rxioclkn,
	rxserdesstrobe 		=> rx_serdesstrobe,
	gclk    		=> rx_bufg_x1,
	bitslip   		=> bslip,
	reset   		=> rst,
	data_out  		=> rxd,
	debug_in  		=> "00",
	debug    		=> open);

process (rx_bufg_x1, rst)		-- example bitslip logic, if required
begin
if rst = '1' then
	state <= '0' ;
	bslip <= '1' ;
   	count <= "0000" ;
elsif rx_bufg_x1'event and rx_bufg_x1 = '1' then
   	if state = '0' then
   		if rxd(63 downto 60) /= "0011" then
     	   		bslip <= '1' ;			-- bitslip needed
     	   		state <= '1' ;
     	   		count <= "0000" ;
     	   	end if ;
   	elsif state = '1' then
     	   	bslip <= '0' ;				-- bitslip low
     	   	count <= count + 1 ;
   		if count = "1111" then
     	   		state <= '0' ;
     	   	end if ;
     	end if ;
end if ;
end process ;

process (rx_bufg_x1)				-- process received data
begin
if rx_bufg_x1'event and rx_bufg_x1 = '1' then
	rxr <= rxd ;
end if ;
end process ;

end arch_top_nto1_ddr_diff_rx ;

