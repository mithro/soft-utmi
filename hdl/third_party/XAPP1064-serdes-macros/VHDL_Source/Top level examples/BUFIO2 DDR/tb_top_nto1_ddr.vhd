------------------------------------------------------------------------------/
-- Copyright (c) 2009 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------/
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: tb_top_nto1_ddr.vhd
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all ;

entity tb_top_nto1_ddr is end tb_top_nto1_ddr ;
architecture rtl of tb_top_nto1_ddr is

component top_nto1_ddr_diff_rx is port (
	reset			:  in std_logic ;				-- reset (active high)
	datain_p, datain_n	:  in std_logic_vector(7 downto 0) ;		-- differential data inputs
	clkin_p,  clkin_n	:  in std_logic ;				-- differential clock input
	dummy_out		: out std_logic_vector(63 downto 0) ) ;		-- dummy outputs
end component ;

component top_nto1_ddr_diff_tx is port (
	reset				:  in std_logic ;			-- reset (active high)
	refclkin_p,  refclkin_n		:  in std_logic ;			-- frequency generator clock input
	dataout_p, dataout_n		: out std_logic_vector(7 downto 0) ;	-- differential data outputs
	clkout_p, clkout_n		: out std_logic ) ;			-- differential clock output
end component ;

component top_nto1_ddr_se_rx is port (
	reset			:  in std_logic ;				-- reset (active high)
	datain			:  in std_logic_vector(7 downto 0) ;		-- single ended data inputs
	clkin1,  clkin2		:  in std_logic ;				-- TWO single ended clock input
	dummy_out		: out std_logic_vector(63 downto 0) ) ;		-- dummy outputs
end component ;

component top_nto1_ddr_se_tx is port (
	reset				:  in std_logic ;			-- reset (active high)
	refclkin_p,  refclkin_n		:  in std_logic ;			-- frequency generator clock input
	dataout				: out std_logic_vector(7 downto 0) ;	-- single ended data outputs
	clkout				: out std_logic ) ;			-- single ended clock output
end component ;


signal clk 		: std_logic := '0' ;
signal notclk 		: std_logic := '1' ;
signal clkout_p 	: std_logic ;
signal clkout_n 	: std_logic ;
signal notclkd 		: std_logic ;
signal reset 		: std_logic := '1' ;
signal reset2 		: std_logic := '1' ;
signal notrxclk 	: std_logic := '0' ;
signal notframe 	: std_logic := '0' ;
signal dataout_p	: std_logic_vector(7 downto 0) ;
signal dataout_n	: std_logic_vector(7 downto 0) ;
signal dataout		: std_logic_vector(7 downto 0) ;
signal dummy_out	: std_logic_vector(63 downto 0) ;
signal dummy_outa	: std_logic_vector(63 downto 0) ;
signal old 		: std_logic_vector(63 downto 0) ;
signal olda 		: std_logic_vector(63 downto 0) ;
signal match 		: std_logic ;
signal matcha 		: std_logic ;
signal clkin_p		: std_logic ;
signal refclk_p		: std_logic := '0' ;
signal refclk_n		: std_logic ;
signal oldclk		: std_logic ;
signal clkout		: std_logic ;

begin

clk <= not clk after 4 nS ;			-- local clock
refclk_p <= not refclk_p after 1 nS ;		-- local clock
reset <= '0' after 150 nS;
reset2 <= '0' after 300 nS;
notclk <= not clk ;
refclk_n <= not refclk_p ;


process (clk)			-- Check data
begin
if clk'event and clk = '1' then
	old <= dummy_out ;
	if dummy_out(63 downto 60) = "0011" and dummy_out(59 downto 0) = old(58 downto 0) & old(59) then 
		match <= '1' ; 
	else  
		match <= '0' ; 
	end if ;
end if ;
end process ;


diff_tx : top_nto1_ddr_diff_tx port map  (
	refclkin_p		=> refclk_p,
	refclkin_n		=> refclk_n,
	dataout_p		=> dataout_p,
	dataout_n		=> dataout_n,
	clkout_p		=> clkout_p,
	clkout_n		=> clkout_n,
	reset			=> reset) ;
	
diff_rx : top_nto1_ddr_diff_rx port map  (
	clkin_p			=> clkout_p,
	clkin_n			=> clkout_n,
	datain_p		=> dataout_p,
	datain_n		=> dataout_n,
	reset			=> reset,
	dummy_out		=> dummy_out) ;

process (clk)			-- Check data
begin
if clk'event and clk = '1' then
	olda <= dummy_outa ;
	if dummy_outa(63 downto 60) = "0011" and dummy_outa(59 downto 0) = olda(58 downto 0) & olda(59) then 
		matcha <= '1' ; 
	else  
		matcha <= '0' ; 
	end if ;
end if ;
end process ;

se_tx : top_nto1_ddr_se_tx port map  (
	refclkin_p		=> refclk_p,
	refclkin_n		=> refclk_n,
	dataout			=> dataout,
	clkout			=> clkout,
	reset			=> reset) ;
	
se_rx : top_nto1_ddr_se_rx port map  (
	clkin1			=> clkout,
	clkin2			=> clkout,
	datain			=> dataout,
	reset			=> reset,
	dummy_out		=> dummy_outa) ;

end rtl ;
