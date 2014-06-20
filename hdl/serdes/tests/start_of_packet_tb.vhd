--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:11:05 06/21/2014
-- Design Name:   
-- Module Name:   /home/tansell/foss/utmi/hdl/serdes/tests/start_of_packet_tb.vhd
-- Project Name:  ise
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: serdes_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY start_of_packet_tb IS
END start_of_packet_tb;
 
ARCHITECTURE behavior OF start_of_packet_tb IS 
 
 
    -- Component Declaration for the Unit Under Test (UUT) 
    COMPONENT serdes_top
    PORT(
         reset : IN  std_logic;
         d_p : IN  std_logic;
         d_n : IN  std_logic;
	 ioclk	: out std_logic ;
         dummy_out : OUT  std_logic_vector(7 downto 0) );
    END COMPONENT;

    COMPONENT usbgen is generic (
	bitclk_period : time := 1 ns );
    PORT(
        go : in std_logic := '0';
        d_p : out std_logic := '0';
        d_n : out std_logic := '1';
	dummy_clk : out std_logic := '0';
	dummy_idle : out std_logic := '1';
	dummy_in_sop : out std_logic := '1';
	dummy_in_pid : out std_logic := '1' );
    END COMPONENT;

   constant usb_bitclk_period : time := 2.0833333333333335 ns;
   constant usb_bitclk_jitter : time := (usb_bitclk_period * 0.30);
   constant usb_bitclk_slow_period : time := (usb_bitclk_period + usb_bitclk_jitter / 2);
   constant usb_bitclk_fast_period : time := (usb_bitclk_period - usb_bitclk_jitter / 2);
   
   signal clk : std_logic;
   signal usb_clk : std_logic;
   signal usb_idle : std_logic;
   signal go : std_logic := '0';

   --Inputs
   signal reset : std_logic := '0';
   signal d_p : std_logic := '0';
   signal d_n : std_logic := '1';

   --Outputs
   signal dummy_out : std_logic_vector(7 downto 0);
   signal ioclk : std_logic := '0';
 
BEGIN

   usb_perfect: usbgen generic map (
	bitclk_period => usb_bitclk_slow_period)
   port map (
        go => go,
        d_p => d_p,
	d_n => d_n,
        dummy_clk => usb_clk,
	dummy_in_sop => open,
	dummy_in_pid => open,
	dummy_idle => usb_idle );
 
   -- Instantiate the Unit Under Test (UUT)
   uut: serdes_top PORT MAP (
          reset => reset,
          d_p => d_p,
          d_n => d_n,
	  ioclk => ioclk,
          dummy_out => dummy_out);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for usb_bitclk_period/2;
		clk <= '1';
		wait for usb_bitclk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for usb_bitclk_period*10;

      go <= '1';
      
      wait for usb_bitclk_period*10;
   end process;

END;
