----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    23:04:27 01/11/2018
-- Module Name:    stepper_motor - Behavioral 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stepper_motor is
    Port ( SPEED    : in  STD_LOGIC_VECTOR (7 downto 0);
           STEPS    : in  STD_LOGIC_VECTOR (7 downto 0);
           DIR      : in  STD_LOGIC;
           LD_SPEED : in  STD_LOGIC;
           LD_STEPS : in  STD_LOGIC;
           LD_DIR   : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           MOTOR    : out STD_LOGIC_VECTOR (3 downto 0));
end stepper_motor;

architecture Behavioral of stepper_motor is

   -- internal registers
   signal SPEED_I : STD_LOGIC_VECTOR (7 downto 0);
   signal STEPS_I : STD_LOGIC_VECTOR (7 downto 0);
   signal DIR_I : STD_LOGIC;
   
   -- global load signal
   signal LOAD : STD_LOGIC;
   
   -- enable signals
   signal EN : STD_LOGIC;
   
   -- counter signals
   signal CLOCK_I, COUNTER_SEL : STD_LOGIC;
   signal COUNTER : STD_LOGIC_VECTOR (255 downto 0);
   
   -- output signals
   signal OUT_SEL : STD_LOGIC_VECTOR (1 downto 0);

begin
   LOAD <= LD_SPEED or LD_STEPS or LD_DIR;

   -- load values into SPEED_I
   ld_speed_proc: process(CLOCK, LD_SPEED)
   begin
      if (rising_edge(CLOCK) and LD_SPEED = '1') then
         SPEED_I <= SPEED;
      end if;
   end process ld_speed_proc;
   
   -- load values into DIR_I
   ld_dir_proc: process(CLOCK, LD_DIR)
   begin
      if (rising_edge(CLOCK) and LD_DIR = '1') then
         DIR_I <= DIR;
      end if;
   end process ld_dir_proc;
   
   -- synchronize counter to the clock
   counter_proc: process(CLOCK, LOAD)
   begin
      if (rising_edge(CLOCK)) then
         if (LOAD = '1') then
            COUNTER <= (others => '0');
         else
            COUNTER <= std_logic_vector(unsigned(COUNTER) + 1);
         end if;
      end if;
   end process counter_proc;
   
   -- determine if steps are >0 and LOAD = '0'
   EN <= (((STEPS_I(0) or STEPS_I(1)) or (STEPS_I(2) or STEPS_I(3))) or
         ((STEPS_I(4) or STEPS_I(5)) or (STEPS_I(6) or STEPS_I(7)))) and
         (not LOAD);
   
   -- compute the internal clock
   COUNTER_SEL <= COUNTER(to_integer(unsigned(SPEED_I)));
   CLOCK_I <= COUNTER_SEL and EN;
   
   -- responisble for STEPS_I and OUT_SEL
   steps_proc: process(CLOCK, CLOCK_I, LD_STEPS)
   begin
      if (rising_edge(CLOCK) and LD_STEPS = '1') then
         STEPS_I <= STEPS;
         OUT_SEL <= "00";
      elsif (rising_edge(CLOCK_I)) then
         STEPS_I <= std_logic_vector(unsigned(STEPS_I) - 1);
         
         if (DIR_I = '0') then
            OUT_SEL <= std_logic_vector(unsigned(OUT_SEL) + 1);
         elsif (DIR_I = '1') then
            OUT_SEL <= std_logic_vector(unsigned(OUT_SEL) - 1);
         end if;
      end if;
   end process steps_proc;
   
   -- multiplex the output
   with (OUT_SEL) select
      MOTOR <= "0110" when "00",
               "0101" when "01",
               "1001" when "10",
               "1010" when "11",
               "0000" when others;

end Behavioral;
