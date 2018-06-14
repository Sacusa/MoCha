----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    13:36:51 10/26/2017
-- Module Name:    controller - Structural 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
    Port ( CLOCK       : in    STD_LOGIC;
           RESET       : in    STD_LOGIC;
           SEGMENT     : out   STD_LOGIC_VECTOR (7 downto 0);
           DISP_ENABLE : out   STD_LOGIC_VECTOR (2 downto 0);
           IO_0        : in    STD_LOGIC_VECTOR (7 downto 0);   -- DIP Switches
           IO_2        : out   STD_LOGIC_VECTOR (7 downto 0);   -- LEDs
           IO_8        : inout STD_LOGIC_VECTOR (7 downto 0);   -- GPIO
           IO_9        : inout STD_LOGIC_VECTOR (7 downto 0);   -- GPIO
           IO_10       : inout STD_LOGIC_VECTOR (7 downto 0);   -- GPIO
           SM_OUT      : out   STD_LOGIC_VECTOR (3 downto 0);   -- Stepper motor pattern
           SPI_CLK     : out   STD_LOGIC;
           SPI_CS      : out   STD_LOGIC;
           SPI_DIN     : in    STD_LOGIC;
           SPI_DOUT    : out   STD_LOGIC);
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
           ADDRESS  : in    STD_LOGIC_VECTOR (15 downto 0);
           DATA_IN  : in    STD_LOGIC_VECTOR (7 downto 0);
           DATA_OUT : out   STD_LOGIC_VECTOR (7 downto 0);
           IO_0     : in    STD_LOGIC_VECTOR (7 downto 0);   -- DIP Switches
           IO_1     : out   STD_LOGIC_VECTOR (7 downto 0);   -- 7-segment display
           IO_2     : out   STD_LOGIC_VECTOR (7 downto 0);   -- LEDs
           IO_8     : inout STD_LOGIC_VECTOR (7 downto 0);   -- GPIO
           IO_9     : inout STD_LOGIC_VECTOR (7 downto 0);   -- GPIO
           IO_10    : inout STD_LOGIC_VECTOR (7 downto 0);   -- GPIO
           IO_11    : inout STD_LOGIC_VECTOR (7 downto 0);   -- Unused
           IO_12    : inout STD_LOGIC_VECTOR (7 downto 0);   -- Unused
           IO_13    : inout STD_LOGIC_VECTOR (7 downto 0);   -- Unused
           IO_14    : inout STD_LOGIC_VECTOR (7 downto 0);   -- Unused
           IO_15    : inout STD_LOGIC_VECTOR (7 downto 0);   -- Unused
           SM_OUT   : out   STD_LOGIC_VECTOR (3 downto 0);
           SPI_CLK  : out   STD_LOGIC;
           SPI_CS   : out   STD_LOGIC;
           SPI_DIN  : in    STD_LOGIC;
           SPI_DOUT : out   STD_LOGIC);
   end component;

   -- import the processor
   component processor
      Port ( RESET_IN : in  STD_LOGIC;
             CLOCK    : in  STD_LOGIC;
             MEM_OUT  : in  STD_LOGIC_VECTOR (7 downto 0);
             MEM_WEA  : out STD_LOGIC_VECTOR (0 downto 0);
             MEM_ADDR : out STD_LOGIC_VECTOR (15 downto 0);
             MEM_IN   : out STD_LOGIC_VECTOR (7 downto 0));
   end component;

   -- binary-to-BCD converter signals
   signal BCD_DEC_OUT : STD_LOGIC_VECTOR (11 downto 0);
   
   -- memory unit signals
   signal IO_1  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_11 : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_12 : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_13 : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_14 : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_15 : STD_LOGIC_VECTOR (7 downto 0);
   
   -- processor signals
   signal PROC_MEM_OUT, PROC_MEM_IN : STD_LOGIC_VECTOR (7 downto 0);
   signal PROC_MEM_ADDR : STD_LOGIC_VECTOR (15 downto 0);
   signal PROC_MEM_WEA : STD_LOGIC_VECTOR (0 downto 0);

begin

   IO_11 <= (others => 'Z');
   IO_12 <= (others => 'Z');
   IO_13 <= (others => 'Z');
   IO_14 <= (others => 'Z');
   IO_15 <= (others => 'Z');

   -- processor instance
   processor_inst : processor
      PORT MAP (
         RESET_IN => RESET,
         CLOCK => CLOCK,
         MEM_OUT => PROC_MEM_OUT,
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
         IO_0 => IO_0,
         IO_1 => IO_1,
         IO_2 => IO_2,
         IO_8 => IO_8,
         IO_9 => IO_9,
         IO_10 => IO_10,
         IO_11 => IO_11,
         IO_12 => IO_12,
         IO_13 => IO_13,
         IO_14 => IO_14,
         IO_15 => IO_15,
         SM_OUT => SM_OUT,
         SPI_CLK => SPI_CLK,
         SPI_CS => SPI_CS,
         SPI_DIN => SPI_DIN,
         SPI_DOUT => SPI_DOUT
      );

   -- convert 8b binary display output to 12b BCD
   bin8bcd_inst : bin8bcd
      PORT MAP (
         bin => IO_1,
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
