----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    20:32:34 10/06/2017
-- Module Name:    flag_register - Behavioral 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flag_register is
    Port ( FLAG_Z   : in  STD_LOGIC;
           FLAG_C   : in  STD_LOGIC;
           FLAG_S   : in  STD_LOGIC;
           FLAG_P   : in  STD_LOGIC;
           LOAD     : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0));
end flag_register;

architecture Behavioral of flag_register is

   component reg8
      Port ( DATA     : in  STD_LOGIC_VECTOR (7 downto 0);
             LOAD_EN  : in  STD_LOGIC;
             RESET    : in  STD_LOGIC;
             CLOCK    : in  STD_LOGIC;
             Q        : out STD_LOGIC_VECTOR (7 downto 0));
   end component;
   
   signal FLAG_NZ, FLAG_NC, FLAG_PL : STD_LOGIC;

begin
   
   FLAG_NZ <= not FLAG_Z;
   FLAG_NC <= not FLAG_C;
   FLAG_PL <= FLAG_S nor FLAG_Z;

   flag_reg: reg8
      Port map (
         DATA(0)  => '1',
         DATA(1)  => FLAG_Z,
         DATA(2)  => FLAG_NZ,
         DATA(3)  => FLAG_C,
         DATA(4)  => FLAG_NC,
         DATA(5)  => FLAG_PL,
         DATA(6)  => FLAG_S,
         DATA(7)  => FLAG_P,
         LOAD_EN  => LOAD,
         RESET    => '0',
         CLOCK    => CLOCK,
         Q        => DATA_OUT
      );

end Behavioral;

