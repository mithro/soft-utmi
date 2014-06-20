------------------------------------------------------------------------------
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: tb_top_nto1_pll.vhd
--  /   /        Date Last Modified:  November 5 2009
-- /___/   /\    Date Created: June 1 2009
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 	Spartan 6
--Purpose:  	Test Bench
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all ;

entity tb_top_nto1_pll is end tb_top_nto1_pll ;

architecture rtl of tb_top_nto1_pll is

component top_nto1_pll_diff_tx is port (
	refclkin_p,  refclkin_n	:  in std_logic ;  				-- reference clock input
	reset			:  in std_logic ;                     		-- reset (active high)
	clkout_p, clkout_n	: out std_logic ;             			-- lvds clock output
	dataout_p, dataout_n	: out std_logic_vector(5 downto 0)) ;  		-- lvds data outputs
end component;

component top_nto1_pll_diff_rx is port (
	reset			:  in std_logic ;                     		-- reset (active high)
	clkin_p, clkin_n	:  in std_logic ;                     		-- lvds clock input
	datain_p, datain_n	:  in std_logic_vector(5 downto 0) ;  		-- lvds data inputs
	dummy_out		: out std_logic_vector(41 downto 0)) ;            -- dummy outputs
end component ;

component top_nto1_pll_diff_rx_and_tx is port (
	reset			:  in std_logic ;                     		-- reset (active high)
	clkin_p, clkin_n	:  in std_logic ;                     		-- lvds clock input
	datain_p, datain_n	:  in std_logic_vector(5 downto 0) ;  		-- lvds data inputs
	clkout_p, clkout_n	: out std_logic ;             			-- lvds clock output
	dataout_p, dataout_n	: out std_logic_vector(5 downto 0)) ;  		-- lvds data outputs
end component ;

signal clkout_p 	: std_logic ;
signal clkout_n 	: std_logic ;
signal dummy_out 	: std_logic_vector(41 downto 0) ;
signal dummy_out2 	: std_logic_vector(41 downto 0) ;
signal old 		: std_logic_vector(41 downto 0) ;
signal clkin_p		: std_logic ;
signal old2 		: std_logic_vector(41 downto 0) ;
signal pixelclock_p	: std_logic := '0' ;
signal pixelclock_n	: std_logic ;
signal match		: std_logic ;
signal reset		: std_logic := '1' ;
signal reset2		: std_logic := '1' ;
signal dataout_p 	: std_logic_vector(5 downto 0) ;
signal dataout_n 	: std_logic_vector(5 downto 0) ;
signal match2		: std_logic ;
signal dataout2_p 	: std_logic_vector(5 downto 0) ;
signal dataout2_n 	: std_logic_vector(5 downto 0) ;
signal clkout2_p 	: std_logic ;
signal clkout2_n 	: std_logic ;

begin

pixelclock_p <= not pixelclock_p after 3 nS ;		-- local clock
reset <= '0' after 150 nS;
reset2 <= '0' after 300 nS;
pixelclock_n <= not pixelclock_p ;

process (pixelclock_p)
begin
if pixelclock_p'event and pixelclock_p = '1' then
	old <= dummy_out ;
	if dummy_out = old(40 downto 0) & old(41) then
		match <= '1' ;
	else
		match <= '0' ;
	end if ;
end if ;
end process ;

process (pixelclock_p)
begin
if pixelclock_p'event and pixelclock_p = '1' then
	old2 <= dummy_out2 ;
	if dummy_out2 = old2(40 downto 0) & old2(41) then
		match2 <= '1' ;
	else
		match2 <= '0' ;
	end if ;
end if ;
end process ;

diff_tx : top_nto1_pll_diff_tx  port map (
	refclkin_p		=> pixelclock_p,  
	refclkin_n		=> pixelclock_n,
	reset			=> reset,
	clkout_p		=> clkout_p, 
	clkout_n		=> clkout_n, 
	dataout_p		=> dataout_p, 
	dataout_n		=> dataout_n) ;

diff_rx : top_nto1_pll_diff_rx  port map (
	reset			=> reset,
	clkin_p			=> clkout_p, 
	clkin_n			=> clkout_n,
	datain_p		=> dataout_p, 
	datain_n		=> dataout_n,
	dummy_out		=> dummy_out) ;

diff_rx_and_tx : top_nto1_pll_diff_rx_and_tx  port map (
	reset			=> reset,
	clkin_p			=> clkout_p, 
	clkin_n			=> clkout_n,
	datain_p		=> dataout_p, 
	datain_n		=> dataout_n,
	clkout_p		=> clkout2_p, 
	clkout_n		=> clkout2_n, 
	dataout_p		=> dataout2_p, 
	dataout_n		=> dataout2_n) ;

diff_rx2 : top_nto1_pll_diff_rx  port map (
	reset			=> reset,
	clkin_p			=> clkout2_p, 
	clkin_n			=> clkout2_n,
	datain_p		=> dataout2_p, 
	datain_n		=> dataout2_n,
	dummy_out		=> dummy_out2) ;
		
end rtl ;
