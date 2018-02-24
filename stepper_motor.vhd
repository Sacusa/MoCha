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
    Port ( SPEED     : in  STD_LOGIC_VECTOR (4 downto 0);
           STEPS     : in  STD_LOGIC_VECTOR (7 downto 0);
           DIR       : in  STD_LOGIC;
           ENABLE    : in  STD_LOGIC;
           LD_SPEED  : in  STD_LOGIC;
           LD_STEPS  : in  STD_LOGIC;
           LD_DIR    : in  STD_LOGIC;
           LD_ENABLE : in  STD_LOGIC;
           CLOCK     : in  STD_LOGIC;
           MOTOR     : out STD_LOGIC_VECTOR (3 downto 0));
end stepper_motor;

architecture Behavioral of stepper_motor is

   -- internal registers
   signal SPEED_I : STD_LOGIC_VECTOR (4 downto 0);
   signal STEPS_I : STD_LOGIC_VECTOR (7 downto 0);
   signal DIR_I : STD_LOGIC;
   
   -- global load signal
   signal LOAD : STD_LOGIC;
   
   -- enable signals
   signal ENABLE_I : STD_LOGIC;
   signal EN : STD_LOGIC;
   
   -- counter signals
   signal COUNTER : STD_LOGIC_VECTOR (31 downto 0);
   
   -- signals for steps processing
   signal STEPS_COUNT : STD_LOGIC_VECTOR (7 downto 0);
   signal CLOCK_I : STD_LOGIC;
   
   -- signals for output selector processing
   signal INC_OUT_SEL, DEC_OUT_SEL : STD_LOGIC_VECTOR (1 downto 0);
   signal COMP_OUT_SEL : STD_LOGIC_VECTOR (1 downto 0);
   
   -- output signals
   signal OUT_SEL : STD_LOGIC_VECTOR (1 downto 0);

begin
   LOAD <= LD_SPEED or LD_STEPS or LD_DIR or LD_ENABLE;
   
   -- determine if steps_count < steps_i and LOAD = '0'
   EN <= ((STEPS_COUNT(0) xor STEPS_I(0)) or
          (STEPS_COUNT(1) xor STEPS_I(1)) or
          (STEPS_COUNT(2) xor STEPS_I(2)) or
          (STEPS_COUNT(3) xor STEPS_I(3)) or
          (STEPS_COUNT(4) xor STEPS_I(4)) or
          (STEPS_COUNT(5) xor STEPS_I(5)) or
          (STEPS_COUNT(6) xor STEPS_I(6)) or
          (STEPS_COUNT(7) xor STEPS_I(7))) and
         (not LOAD) and ENABLE_I;

   speed_reg: process(CLOCK, LD_SPEED)
   begin
      if (rising_edge(CLOCK) and LD_SPEED = '1') then
         SPEED_I <= SPEED;
      end if;
   end process speed_reg;
   
   dir_ff: process(CLOCK, LD_DIR)
   begin
      if (rising_edge(CLOCK) and LD_DIR = '1') then
         DIR_I <= DIR;
      end if;
   end process dir_ff;
   
   enable_ff: process(CLOCK, LD_ENABLE)
   begin
      if (rising_edge(CLOCK) and LD_ENABLE = '1') then
         ENABLE_I <= ENABLE;
      end if;
   end process enable_ff;
   
   -- synchronize counter to the clock
   counter_proc: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (EN = '1') then
            COUNTER <= std_logic_vector(unsigned(COUNTER) + 1);
            CLOCK_I <= COUNTER(to_integer(unsigned(SPEED_I)));
         else
            COUNTER <= (others => '0');
            CLOCK_I <= '0';
         end if;
      end if;
   end process counter_proc;
   
   -- STEPS computation
   steps_reg: process(CLOCK, LD_STEPS)
   begin
      if (rising_edge(CLOCK) and LD_STEPS = '1') then
         STEPS_I <= STEPS;
      end if;
   end process steps_reg;
   
   steps_count_reg: process (CLOCK_I, LD_STEPS)
   begin
      if (LD_STEPS = '1') then
         STEPS_COUNT <= (others => '0');
      elsif (rising_edge(CLOCK_I)) then
         STEPS_COUNT <= std_logic_vector(unsigned(STEPS_COUNT) + 1);
      end if;
   end process steps_count_reg;
   
   -- OUT_SEL computation
   INC_OUT_SEL <= std_logic_vector(unsigned(OUT_SEL) + 1);
   DEC_OUT_SEL <= std_logic_vector(unsigned(OUT_SEL) - 1);
   
   with (DIR_I) select
      COMP_OUT_SEL <= INC_OUT_SEL     when '0',
                      DEC_OUT_SEL     when '1',
                      (others => '0') when others;
   
   out_sel_reg: process(CLOCK_I, LD_STEPS)
   begin
      if (LD_STEPS = '1') then
         OUT_SEL <= (others => '0');
      elsif (rising_edge(CLOCK_I)) then
         OUT_SEL <= COMP_OUT_SEL;
      end if;
   end process out_sel_reg;
   
   -- multiplex the output
   with (OUT_SEL) select
      MOTOR <= "0110" when "00",
               "0101" when "01",
               "1001" when "10",
               "1010" when "11",
               "0000" when others;

end Behavioral;
