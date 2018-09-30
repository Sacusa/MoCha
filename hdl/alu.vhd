----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    23:21:30 08/29/2017
-- Module Name:    alu - Dataflow
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
    Port ( A_IN   : in  STD_LOGIC_VECTOR (7 downto 0);
           B_IN   : in  STD_LOGIC_VECTOR (7 downto 0);
           S_IN   : in  STD_LOGIC_VECTOR (2 downto 0);
           CYI    : in  STD_LOGIC;
           Y_OUT  : out STD_LOGIC_VECTOR (7 downto 0);
           FLAG_Z : out STD_LOGIC;
           FLAG_C : out STD_LOGIC;
           FLAG_S : out STD_LOGIC;
           FLAG_P : out STD_LOGIC);
end alu;

architecture Dataflow of alu is

   signal Y_INTERNAL : STD_LOGIC_VECTOR (7 downto 0);
   signal FLAG_C_SEL : STD_LOGIC_VECTOR (2 downto 0);

begin
   
   with (S_IN) select
      Y_INTERNAL <= (A_IN)              when "000",
                    (A_IN + 1)          when "001",
                    (A_IN - 1)          when "010",
                    (A_IN or B_IN)      when "011",
                    (A_IN and B_IN)     when "100",
                    (A_IN xor B_IN)     when "101",
                    (A_IN + B_IN + CYI) when "110",
                    (A_IN - B_IN - CYI) when "111",
                    (others => '0')     when others;
   
   Y_OUT <= Y_INTERNAL;
   
   with (S_IN) select
      FLAG_C_SEL <= (Y_INTERNAL(7) & A_IN(7) & B_IN(7)) when "110",
                    (Y_INTERNAL(7) & A_IN(7) & '0')     when "001",
                    "000" when others;
   with (FLAG_C_SEL) select
      FLAG_C <= '1' when "001"|"010"|"011"|"111",
                '0' when others;
   
   FLAG_Z <= not(Y_INTERNAL(0) or Y_INTERNAL(1) or Y_INTERNAL(2) or Y_INTERNAL(3)
              or Y_INTERNAL(4) or Y_INTERNAL(5) or Y_INTERNAL(6) or Y_INTERNAL(7));
   FLAG_S <= Y_INTERNAL(7);
   FLAG_P <= not (Y_INTERNAL(0) xor Y_INTERNAL(1) xor Y_INTERNAL(2) xor Y_INTERNAL(3) xor
                  Y_INTERNAL(4) xor Y_INTERNAL(5) xor Y_INTERNAL(6) xor Y_INTERNAL(7));

end Dataflow;
