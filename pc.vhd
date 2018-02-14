----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    23:43:05 09/08/2017 
-- Module Name:    pc - Behavioral 
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

entity pc is
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           CLOCK    : in  STD_LOGIC;
           INC      : in  STD_LOGIC;
           LOAD     : in  STD_LOGIC_VECTOR (1 downto 0);
           DATA_OUT : out STD_LOGIC_VECTOR (15 downto 0));
end pc;

architecture Behavioral of pc is

   signal PC_DATA : STD_LOGIC_VECTOR (15 downto 0);

begin

   sync_proc: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         -- if both INC and LOAD are asserted, do nothing
         if (INC = '1' and LOAD(1) = '0') then
            PC_DATA <= PC_DATA + 1;
            
         elsif (INC = '0' and LOAD(1) = '1') then
            -- LSB=0 --> load lower order byte
            if (LOAD(0) = '0') then
               PC_DATA <= PC_DATA(15 downto 8) & DATA_IN;
            
            -- LSB=1 --> load higher order byte
            elsif (LOAD(0) = '1') then
               PC_DATA <= DATA_IN & PC_DATA(7 downto 0);
            
            end if;
         end if;
      end if;
   end process sync_proc;
   
   DATA_OUT <= PC_DATA;

end Behavioral;

