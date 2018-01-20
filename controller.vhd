----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    13:36:51 10/26/2017
-- Module Name:    controller - Structural 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
    Port ( CLOCK       : in    STD_LOGIC;
           RESET       : in    STD_LOGIC;
           SEGMENT     : out   STD_LOGIC_VECTOR (7 downto 0);
           DISP_ENABLE : out   STD_LOGIC_VECTOR (2 downto 0);
           GPIO_0      : inout STD_LOGIC_VECTOR (7 downto 0);
           GPIO_1      : inout STD_LOGIC_VECTOR (7 downto 0);
           GPIO_2      : inout STD_LOGIC_VECTOR (7 downto 0);
           GPIO_3      : inout STD_LOGIC_VECTOR (7 downto 0);
           GPIO_4      : inout STD_LOGIC_VECTOR (7 downto 0);
           GPIO_5      : inout STD_LOGIC_VECTOR (7 downto 0));
end controller;

architecture Structural of controller is

   -- import 12b BCD display module
   component bcd12_7seg
      Port ( BCD      : in  STD_LOGIC_VECTOR (11 DOWNTO 0);
             CLOCK    : in  STD_LOGIC;
             RESET    : in  STD_LOGIC;
             SEGMENTS : out STD_LOGIC_VECTOR (7 DOWNTO 0);
             ENABLE   : out STD_LOGIC_VECTOR (2 DOWNTO 0));
   end component;

   -- import 8b binary to 12b BCD converter module
   component bin8bcd
      Port ( bin : in  std_logic_vector (7 downto 0);
             bcd : out std_logic_vector (11 downto 0));
   end component;
   
   -- import memory unit
   component memory_unit
      Port ( CLOCK    : in    STD_LOGIC;
             WEA      : in    STD_LOGIC;
             ADDRESS  : in    STD_LOGIC_VECTOR (7 downto 0);
             DATA_IN  : in    STD_LOGIC_VECTOR (7 downto 0);
             DATA_OUT : out   STD_LOGIC_VECTOR (7 downto 0);
             GPIO_0   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_1   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_2   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_3   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_4   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_5   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_6   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_7   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_8   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_9   : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_10  : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_11  : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_12  : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_13  : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_14  : inout STD_LOGIC_VECTOR (7 downto 0);
             GPIO_15  : inout STD_LOGIC_VECTOR (7 downto 0));
   end component;

   -- import the processor
   component processor
      Port ( RESET_IN : in  STD_LOGIC;
             CLOCK    : in  STD_LOGIC;
             MEM_OUT  : in  STD_LOGIC_VECTOR (7 downto 0);
             DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0);
             MEM_WEA  : out STD_LOGIC_VECTOR (0 downto 0);
             MEM_ADDR : out STD_LOGIC_VECTOR (7 downto 0);
             MEM_IN   : out STD_LOGIC_VECTOR (7 downto 0));
   end component;

   -- binary-to-BCD converter signals
   signal BCD_DEC_OUT : STD_LOGIC_VECTOR (11 downto 0);
   
   -- stub signals for memory unit
   signal GPIO_6  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_7  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_8  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_9  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_10 : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_11 : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_12 : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_13 : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_14 : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_15 : STD_LOGIC_VECTOR (7 downto 0);
   
   -- processor signals
   signal PROC_MEM_OUT, PROC_DATA_OUT, PROC_MEM_ADDR, PROC_MEM_IN : STD_LOGIC_VECTOR (7 downto 0);
   signal PROC_MEM_WEA : STD_LOGIC_VECTOR (0 downto 0);

begin

   GPIO_6  <= (others => 'Z');
   GPIO_7  <= (others => 'Z');
   GPIO_8  <= (others => 'Z');
   GPIO_9  <= (others => 'Z');
   GPIO_10 <= (others => 'Z');
   GPIO_11 <= (others => 'Z');
   GPIO_12 <= (others => 'Z');
   GPIO_13 <= (others => 'Z');
   GPIO_14 <= (others => 'Z');
   GPIO_15 <= (others => 'Z');

   -- processor instance
   processor_inst : processor
      PORT MAP (
         RESET_IN => RESET,
         CLOCK => CLOCK,
         MEM_OUT => PROC_MEM_OUT,
         DATA_OUT => PROC_DATA_OUT,
         MEM_WEA => PROC_MEM_WEA,
         MEM_ADDR => PROC_MEM_ADDR,
         MEM_IN => PROC_MEM_IN
      );
   
   -- memory unit instance
   memory_unit_inst: memory_unit
      PORT MAP(
         CLOCK => CLOCK,
         WEA => PROC_MEM_WEA(0),
         ADDRESS => PROC_MEM_ADDR,
         DATA_IN => PROC_MEM_IN,
         DATA_OUT => PROC_MEM_OUT,
         GPIO_0 => GPIO_0,
         GPIO_1 => GPIO_1,
         GPIO_2 => GPIO_2,
         GPIO_3 => GPIO_3,
         GPIO_4 => GPIO_4,
         GPIO_5 => GPIO_5,
         GPIO_6 => GPIO_6,
         GPIO_7 => GPIO_7,
         GPIO_8 => GPIO_8,
         GPIO_9 => GPIO_9,
         GPIO_10 => GPIO_10,
         GPIO_11 => GPIO_11,
         GPIO_12 => GPIO_12,
         GPIO_13 => GPIO_13,
         GPIO_14 => GPIO_14,
         GPIO_15 => GPIO_15
      );

   -- convert 8b binary processor output to 12b BCD
   bin8bcd_inst : bin8bcd
      PORT MAP (
         bin => PROC_DATA_OUT,
         bcd => BCD_DEC_OUT
      );

   -- display the 12b BCD data using POV
   bcd12_7seg_inst : bcd12_7seg
      PORT MAP (
         BCD => BCD_DEC_OUT,
         CLOCK => CLOCK,
         RESET => RESET,
         SEGMENTS => SEGMENT,
         ENABLE => DISP_ENABLE
      );

end Structural;
