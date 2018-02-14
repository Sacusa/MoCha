----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    00:07:59 09/09/2017
-- Module Name:    sp - Behavioral
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - Update to 2B
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sp is
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           CLOCK    : in  STD_LOGIC;
           INC      : in  STD_LOGIC;
           DEC      : in  STD_LOGIC;
           LOAD     : in  STD_LOGIC_VECTOR (1 downto 0);
           DATA_OUT : out STD_LOGIC_VECTOR (15 downto 0));
end sp;

architecture Behavioral of sp is

   signal SP_DATA : STD_LOGIC_VECTOR (15 downto 0);

begin

   sync_proc: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         -- only one of INC, DEC and LOAD must be asserted for any change
         if (INC = '1' and DEC = '0' and LOAD(1) = '0') then
            SP_DATA <= SP_DATA + 1;
         
         elsif (INC = '0' and DEC = '1' and LOAD(1) = '0') then
            SP_DATA <= SP_DATA - 1;
         
         elsif (INC = '0' and DEC = '0' and LOAD(1) = '1') then
            if (LOAD(0) = '0') then
               SP_DATA <= SP_DATA(15 downto 8) & DATA_IN;
            elsif (LOAD(0) = '1') then
               SP_DATA <= DATA_IN & SP_DATA(7 downto 0);
            end if;
            
         end if;
      end if;
   end process sync_proc;
   
   DATA_OUT <= SP_DATA;

end Behavioral;

