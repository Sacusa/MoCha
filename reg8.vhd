----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    10:18:51 09/01/2017 
-- Module Name:    reg8 - Dataflow
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg8 is
    Port ( DATA     : in  STD_LOGIC_VECTOR (7 downto 0);
           LOAD_EN  : in  STD_LOGIC;
           RESET    : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           Q        : out STD_LOGIC_VECTOR (7 downto 0));
end reg8;

architecture Dataflow of reg8 is

   -- import D flipflop
   component d_flipflop is
    Port ( D     : in  STD_LOGIC;
           CLOCK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           Q     : out STD_LOGIC);
   end component;
   
   signal D, Q_INTERNAL : STD_LOGIC_VECTOR(7 downto 0);

begin

   D(0) <= (DATA(0) and LOAD_EN) or (Q_INTERNAL(0) and (not LOAD_EN));
   D(1) <= (DATA(1) and LOAD_EN) or (Q_INTERNAL(1) and (not LOAD_EN));
   D(2) <= (DATA(2) and LOAD_EN) or (Q_INTERNAL(2) and (not LOAD_EN));
   D(3) <= (DATA(3) and LOAD_EN) or (Q_INTERNAL(3) and (not LOAD_EN));
   D(4) <= (DATA(4) and LOAD_EN) or (Q_INTERNAL(4) and (not LOAD_EN));
   D(5) <= (DATA(5) and LOAD_EN) or (Q_INTERNAL(5) and (not LOAD_EN));
   D(6) <= (DATA(6) and LOAD_EN) or (Q_INTERNAL(6) and (not LOAD_EN));
   D(7) <= (DATA(7) and LOAD_EN) or (Q_INTERNAL(7) and (not LOAD_EN));
   
   DFF0: d_flipflop port map (D => D(0), CLOCK => CLOCK, RESET => RESET, Q => Q_INTERNAL(0));
   DFF1: d_flipflop port map (D => D(1), CLOCK => CLOCK, RESET => RESET, Q => Q_INTERNAL(1));
   DFF2: d_flipflop port map (D => D(2), CLOCK => CLOCK, RESET => RESET, Q => Q_INTERNAL(2));
   DFF3: d_flipflop port map (D => D(3), CLOCK => CLOCK, RESET => RESET, Q => Q_INTERNAL(3));
   DFF4: d_flipflop port map (D => D(4), CLOCK => CLOCK, RESET => RESET, Q => Q_INTERNAL(4));
   DFF5: d_flipflop port map (D => D(5), CLOCK => CLOCK, RESET => RESET, Q => Q_INTERNAL(5));
   DFF6: d_flipflop port map (D => D(6), CLOCK => CLOCK, RESET => RESET, Q => Q_INTERNAL(6));
   DFF7: d_flipflop port map (D => D(7), CLOCK => CLOCK, RESET => RESET, Q => Q_INTERNAL(7));
   
   Q <= Q_INTERNAL;

end Dataflow;

