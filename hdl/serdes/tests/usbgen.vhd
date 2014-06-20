----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:44:27 06/21/2014 
-- Design Name: 
-- Module Name:    usbgen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity usbgen is generic (
	bitclk_period : time := 1 ns );
    PORT(
        go : in std_logic := '0';
        d_p : out std_logic := '0';
        d_n : out std_logic := '1';
	dummy_clk : out std_logic;
	dummy_idle : out std_logic;
	dummy_in_sop : out std_logic;
	dummy_in_pid : out std_logic);
end usbgen;

architecture arch_usbgen of usbgen is
   signal in_sop : std_logic := '1';
   signal in_pid : std_logic := '1';
   signal idle : std_logic := '1';

   -- The source of the packet signals the Start of Packet (SOP) in high-speed mode by driving the D+ and D- lines
   -- from the high-speed Idle state to the K state. This K is the first symbol of the SYNC pattern (NRZI sequence
   -- KJKJKJKJ KJKJKJKJ KJKJKJKJ KJKJKJKK) as described in Section 7.1.10.
   constant sop : std_logic_vector(31 downto 0) := "10101010101010101010101010101000";
   constant pid : std_logic_vector(7 downto 0) := "11010111";

begin

   idle <= not (not in_sop or not in_pid);
   
   dummy_idle <= idle;
   dummy_in_sop <= in_sop;
   dummy_in_pid <= in_pid;

   dummy_clk_process :process
   begin
	wait until (go'event and go = '1');
	while go = '1' loop
		dummy_clk <= '0';
		wait for bitclk_period/2;
		dummy_clk <= '1';
		wait for bitclk_period/2;
	end loop;
   end process;

   data_process: process
   begin		
      wait until (go'event and go = '1');
      wait for bitclk_period*10;

      -- start of packet / sync period
      in_sop <= '0';      
      for i in sop'low to sop'high loop 
          d_p <= sop(sop'high - i);
          d_n <= not sop(sop'high - i);
          wait for bitclk_period;
      end loop;
      in_sop <= '1';      
      
      -- PID data
      in_pid <= '0';      
      for i in pid'low to pid'high loop 
          d_p <= pid(pid'high - i);
          d_n <= not pid(pid'high - i);
          wait for bitclk_period;
      end loop;
      in_pid <= '1';      
   end process;

end arch_usbgen;

