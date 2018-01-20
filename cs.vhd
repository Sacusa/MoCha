----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    15:46:37 09/19/2017
-- Module Name:    cs - Dataflow
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cs is
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           SCS      : in  STD_LOGIC_VECTOR (1 downto 0);
           CARRY_IN : in  STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           FLAG_Z   : out STD_LOGIC;
           FLAG_C   : out STD_LOGIC;
           FLAG_S   : out STD_LOGIC;
           FLAG_P   : out STD_LOGIC);
end cs;

architecture Dataflow of cs is

   signal COMP_OUT, LS_OUT, RS_OUT, RESULT : STD_LOGIC_VECTOR (7 downto 0);

begin

   COMP_OUT <= not DATA_IN;
   LS_OUT <= DATA_IN(6 downto 0) & CARRY_IN;
   RS_OUT <= CARRY_IN & DATA_IN(7 downto 1);
   DATA_OUT <= RESULT;
   
   with (SCS) select
      RESULT <= DATA_IN         when "00",
                COMP_OUT        when "01",
                LS_OUT          when "10",
                RS_OUT          when "11",
                (others => '0') when others;
   
   with (SCS) select
      FLAG_C <= DATA_IN(7) when "10",
                DATA_IN(0) when "11",
                '0'        when others;
   
   FLAG_Z <= not(RESULT(0) or RESULT(1) or RESULT(2) or RESULT(3)
              or RESULT(4) or RESULT(5) or RESULT(6) or RESULT(7));
   FLAG_S <= RESULT(7);
   FLAG_P <= RESULT(0) xor RESULT(1) xor RESULT(2) xor RESULT(3) xor
             RESULT(4) xor RESULT(5) xor RESULT(6) xor RESULT(7);

end Dataflow;

