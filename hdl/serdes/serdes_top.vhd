----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:22:23 06/20/2014 
-- Design Name: 
-- Module Name:    serdes_top - Behavioral 
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
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all ;

library unisim ;
use unisim.vcomponents.all ;



entity serdes_top is
    Port ( dp : in  STD_LOGIC;
           dn : in  STD_LOGIC;
	   debug_clkout : out STD_LOGIC;	   
           data : inout  STD_LOGIC_VECTOR (8 downto 0)
	   );
end serdes_top;

architecture Behavioral of serdes_top is

begin


end Behavioral;

