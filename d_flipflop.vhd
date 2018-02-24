----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:05:33 09/01/2017 
-- Design Name: 
-- Module Name:    d_flipflop - Behavioral 
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

entity d_flipflop is
    Port ( D     : in  STD_LOGIC;
           CLOCK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           Q     : out STD_LOGIC);
end d_flipflop;

architecture Behavioral of d_flipflop is

   signal DATA : STD_LOGIC;

begin

   dff: process(CLOCK, RESET)
   begin
      if (RESET = '1') then
         DATA <= '0';
      elsif (rising_edge(CLOCK)) then
         DATA <= D;
      end if;
   end process dff;
   
   Q <= DATA;

end Behavioral;

