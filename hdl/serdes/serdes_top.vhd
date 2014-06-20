
-- Recommended reading 

-- 1) XAPP224 (v2.5) July 11, 2005 -- Data Recovery -- Author: Nick Sawyer
-- 2) XAPP250 (v1.3.2) May 2, 2007 -- Clock and Data Recovery with Coded Data Streams -- Author: Leonard Dieguez
-- 3) XAPP861 (v1.1) July 20, 2007 -- Efficient 8X Oversampling Asynchronous Serial Data Recovery Using IDELAY -- Author: John F. Snow
-- 4) XAPP523 (v1.0) April 6, 2012 -- LVDS 4x Asynchronous Oversampling Using 7 Series FPGAs -- Author: Marc Defossez
-- 5) XAPP1064 (v1.2) November 19, 2013 -- Source-Synchronous Serialization and Deserialization (up to 1050 Mb/s) -- Author: NIck Sawyer

-- *) UG381 (v1.6) February 14, 2014 -- Spartan-6 FPGA SelectIO Resources User Guide


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

library unisim ;
use unisim.vcomponents.all ;

library XAPP1064_serdes_macros;
use XAPP1064_serdes_macros.all;

entity serdes_top is port (
	reset			:  in std_logic ;                     		-- reset (active high)
	d_p, d_n		:  in std_logic ;
	ioclk			: out std_logic ;
	dummy_out		: out std_logic_vector(7 downto 0)) ;
end serdes_top ;

architecture arch_serdes_top of serdes_top is

component serdes_1_to_n_clk_pll_s8_diff generic (
	PLLD 			: integer := 4 ;   				-- Parameter to set division for PLL 
	PLLX 			: integer := 4 ;   				-- Parameter to set multiplier for PLL (7 for video links, 2 for DDR etc)
	CLKIN_PERIOD 		: real := 2.0833333333333335 ;			-- clock period (ns) of input clock on clkin_p
	S			: integer := 7 ;				-- Parameter to set the serdes factor 1..8
	BS 			: boolean := TRUE ;   				-- Parameter to enable bitslip TRUE or FALSE
	DIFF_TERM		: boolean := FALSE) ;				-- Enable or disable internal differential termination
port 	(
	clkin_p			:  in std_logic ;				-- Input from LVDS receiver pin
	clkin_n			:  in std_logic ;				-- Input from LVDS receiver pin
	reset			:  in std_logic ;				-- Reset line
	pattern1		:  in std_logic_vector(S-1 downto 0) ;  	-- Data to define pattern that bitslip should search for
	pattern2		:  in std_logic_vector(S-1 downto 0) ;  	-- Data to define alternate pattern that bitslip should search for
	rxioclk			: out std_logic ;				-- IO Clock network
	rx_serdesstrobe		: out std_logic ;				-- Parallel data capture strobe
	rx_bufg_pll_x1		: out std_logic ;				-- Global clock
	bitslip			: out std_logic ;				-- Bitslip control line
	datain			: out std_logic_vector(S-1 downto 0) ;  	-- Output data
	rx_bufpll_lckd		: out std_logic); 				-- BUFPLL locked
end component ;

-- Parameters for serdes factor and number of IO pins

constant S 	: integer := 7 ;						-- Set the serdes factor to be 4

signal 	clk_iserdes_data 	: std_logic_vector(6 downto 0) ;        
signal 	rx_bufg_x1		: std_logic ;               		
signal 	rxd			: std_logic_vector(7 downto 0)  ;	
signal 	bitslip 		: std_logic  ;
signal	rst	 		: std_logic  ;
signal	rx_serdesstrobe		: std_logic  ;
signal	rx_bufpll_clk_xn	: std_logic  ;
signal	rx_bufpll_lckd		: std_logic  ;
signal	not_bufpll_lckd		: std_logic  ;

begin

rst <= reset ; 							-- active high reset pin
ioclk <= rx_bufpll_clk_xn ;

-- The source of the packet signals the Start of Packet (SOP) in high-speed mode by driving the D+ and D- lines
-- from the high-speed Idle state to the K state. This K is the first symbol of the SYNC pattern (NRZI sequence
-- KJKJKJKJ KJKJKJKJ KJKJKJKJ KJKJKJKK) as described in Section 7.1.10.

clkin : serdes_1_to_n_clk_pll_s8_diff generic map(
      	CLKIN_PERIOD		=> 2.0833333333333335,
	PLLD 			=> 1,
      	PLLX			=> 2,
      	S			=> S,
	BS 			=> TRUE)    			-- Parameter to enable bitslip TRUE or FALSE (has to be true for video applications)
port map (
	clkin_p    		=> d_p,
	clkin_n    		=> d_n,
	rxioclk    		=> rx_bufpll_clk_xn,
	pattern1		=> "1010100",			-- default values for 7:1 video applications
	pattern2		=> "1010100",
	rx_serdesstrobe 	=> rx_serdesstrobe,
	rx_bufg_pll_x1 		=> rx_bufg_x1,
	bitslip   		=> bitslip,
	reset     		=> rst,
	datain  		=> clk_iserdes_data,
	rx_bufpll_lckd		=> rx_bufpll_lckd) ;

-- 6 Video Data Inputs

not_bufpll_lckd <= not rx_bufpll_lckd ;

end arch_serdes_top ;