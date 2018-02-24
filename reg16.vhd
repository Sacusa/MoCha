----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    16:47:18 02/13/2018
-- Module Name:    reg16 - Behavioral 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg16 is
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           LOAD_EN  : in  STD_LOGIC_VECTOR (1 downto 0);
           RESET    : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (15 downto 0));
end reg16;

architecture Behavioral of reg16 is

   -- import D flipflop
   component d_flipflop is
    Port ( D     : in  STD_LOGIC;
           CLOCK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           Q     : out STD_LOGIC);
   end component;
   
   signal DFF_IN, DFF_OUT : STD_LOGIC_VECTOR(15 downto 0);
   signal LSB_LOAD, MSB_LOAD : STD_LOGIC;
   signal NOT_LSB_LOAD, NOT_MSB_LOAD : STD_LOGIC;

begin

   -- compute load signal for MSB and LSB
   LSB_LOAD <= LOAD_EN(1) and (not LOAD_EN(0));
   MSB_LOAD <= LOAD_EN(1) and LOAD_EN(0);
   NOT_LSB_LOAD <= not LSB_LOAD;
   NOT_MSB_LOAD <= not MSB_LOAD;

   -- compute next value for lower order byte
   DFF_IN(0)  <= (DATA_IN(0) and LSB_LOAD) or (DFF_OUT(0) and NOT_LSB_LOAD);
   DFF_IN(1)  <= (DATA_IN(1) and LSB_LOAD) or (DFF_OUT(1) and NOT_LSB_LOAD);
   DFF_IN(2)  <= (DATA_IN(2) and LSB_LOAD) or (DFF_OUT(2) and NOT_LSB_LOAD);
   DFF_IN(3)  <= (DATA_IN(3) and LSB_LOAD) or (DFF_OUT(3) and NOT_LSB_LOAD);
   DFF_IN(4)  <= (DATA_IN(4) and LSB_LOAD) or (DFF_OUT(4) and NOT_LSB_LOAD);
   DFF_IN(5)  <= (DATA_IN(5) and LSB_LOAD) or (DFF_OUT(5) and NOT_LSB_LOAD);
   DFF_IN(6)  <= (DATA_IN(6) and LSB_LOAD) or (DFF_OUT(6) and NOT_LSB_LOAD);
   DFF_IN(7)  <= (DATA_IN(7) and LSB_LOAD) or (DFF_OUT(7) and NOT_LSB_LOAD);
   
   -- compute next value for higher order byte
   DFF_IN(8)  <= (DATA_IN(0) and MSB_LOAD) or (DFF_OUT(8)  and NOT_MSB_LOAD);
   DFF_IN(9)  <= (DATA_IN(1) and MSB_LOAD) or (DFF_OUT(9)  and NOT_MSB_LOAD);
   DFF_IN(10) <= (DATA_IN(2) and MSB_LOAD) or (DFF_OUT(10) and NOT_MSB_LOAD);
   DFF_IN(11) <= (DATA_IN(3) and MSB_LOAD) or (DFF_OUT(11) and NOT_MSB_LOAD);
   DFF_IN(12) <= (DATA_IN(4) and MSB_LOAD) or (DFF_OUT(12) and NOT_MSB_LOAD);
   DFF_IN(13) <= (DATA_IN(5) and MSB_LOAD) or (DFF_OUT(13) and NOT_MSB_LOAD);
   DFF_IN(14) <= (DATA_IN(6) and MSB_LOAD) or (DFF_OUT(14) and NOT_MSB_LOAD);
   DFF_IN(15) <= (DATA_IN(7) and MSB_LOAD) or (DFF_OUT(15) and NOT_MSB_LOAD);

   DFF0:  d_flipflop port map (D => DFF_IN(0),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(0));
   DFF1:  d_flipflop port map (D => DFF_IN(1),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(1));
   DFF2:  d_flipflop port map (D => DFF_IN(2),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(2));
   DFF3:  d_flipflop port map (D => DFF_IN(3),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(3));
   DFF4:  d_flipflop port map (D => DFF_IN(4),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(4));
   DFF5:  d_flipflop port map (D => DFF_IN(5),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(5));
   DFF6:  d_flipflop port map (D => DFF_IN(6),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(6));
   DFF7:  d_flipflop port map (D => DFF_IN(7),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(7));
   DFF8:  d_flipflop port map (D => DFF_IN(8),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(8));
   DFF9:  d_flipflop port map (D => DFF_IN(9),  CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(9));
   DFF10: d_flipflop port map (D => DFF_IN(10), CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(10));
   DFF11: d_flipflop port map (D => DFF_IN(11), CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(11));
   DFF12: d_flipflop port map (D => DFF_IN(12), CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(12));
   DFF13: d_flipflop port map (D => DFF_IN(13), CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(13));
   DFF14: d_flipflop port map (D => DFF_IN(14), CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(14));
   DFF15: d_flipflop port map (D => DFF_IN(15), CLOCK => CLOCK, RESET => RESET, Q => DFF_OUT(15));
   
   DATA_OUT <= DFF_OUT;

end Behavioral;
