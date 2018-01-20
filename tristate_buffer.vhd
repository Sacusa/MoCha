----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    10:22:37 09/01/2017 
-- Module Name:    tristate_buffer - Behavioral 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2 
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tristate_buffer is
    Port ( A : in  STD_LOGIC;
           G : in  STD_LOGIC;
           Y : out STD_LOGIC);
end tristate_buffer;

architecture Behavioral of tristate_buffer is
begin

   with (G) select
      Y <= A when '1',
           'Z' when others;

end Behavioral;

