----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    10:05:33 09/01/2017
-- Module Name:    d_flipflop - Behavioral
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

