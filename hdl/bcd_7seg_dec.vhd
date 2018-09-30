----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    12:50:00 10/26/2017
-- Module Name:    bcd_7seg_dec - Behavioral 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd12_7seg is
    Port ( BCD      : in  STD_LOGIC_VECTOR (11 DOWNTO 0);
           CLOCK    : in  STD_LOGIC;  -- Assuming 100MHz input clock
           RESET    : in  STD_LOGIC;  -- Active LOW
           SEGMENTS : out STD_LOGIC_VECTOR (7 DOWNTO 0);
           ENABLE   : out STD_LOGIC_VECTOR (2 DOWNTO 0));
end bcd12_7seg;

architecture Behavioral of bcd12_7seg is
   
   -- BCD value for the current display
   signal CURRENT_BCD : STD_LOGIC_VECTOR (3 DOWNTO 0);
   
   signal CLOCK_I : STD_LOGIC := '0';
   signal ENABLE_I : STD_LOGIC_VECTOR (2 DOWNTO 0) := "110";
   signal COUNTER : STD_LOGIC_VECTOR (13 DOWNTO 0) := (others => '0');

begin

   -- flip CLOCK_I every 2^18 clock cycles
   clock_proc: process(CLOCK, RESET)
   begin
      if (RESET = '0') then
         COUNTER <= (others => '0');
         CLOCK_I <= '0';
      elsif (rising_edge(CLOCK)) then
         COUNTER <= std_logic_vector(unsigned(COUNTER) + 1);
         CLOCK_I <= COUNTER(13);
      end if;
   end process clock_proc;
   
   -- switch to next state after 2^14 clock cycles
   clock_i_proc: process(CLOCK_I, RESET)
   begin
      if (RESET = '0') then
         ENABLE_I <= "110";
      elsif (rising_edge(CLOCK_I)) then
         ENABLE_I <= ENABLE_I(1 DOWNTO 0) & ENABLE_I(2);
      end if;
   end process clock_i_proc;
   
   -- select BCD code for current display
   with (ENABLE_I) select
      CURRENT_BCD <= BCD(3 DOWNTO 0)  when "110",
                     BCD(7 DOWNTO 4)  when "101",
                     BCD(11 DOWNTO 8) when "011",
                     "0000"           when others;
   
   -- output segments for current BCD code
   with (CURRENT_BCD) select
      --           abcdefgh
      SEGMENTS <= "00000011" when "0000",
                  "10011111" when "0001",
                  "00100101" when "0010",
                  "00001101" when "0011",
                  "10011001" when "0100",
                  "01001001" when "0101",
                  "01000001" when "0110",
                  "00011111" when "0111",
                  "00000001" when "1000",
                  "00011001" when "1001",
                  "11111111" when others;
   
   ENABLE <= ENABLE_I;

end Behavioral;
