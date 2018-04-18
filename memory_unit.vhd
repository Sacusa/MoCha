----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    09:54:24 10/25/2017
-- Module Name:    memory_unit - Structural
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - Update for 64K memory space
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_unit is
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
           SM_OUT   : out   STD_LOGIC_VECTOR (3 downto 0);   -- Stepper motor pattern
           SPI_CLK  : out   STD_LOGIC;
           SPI_CS   : out   STD_LOGIC;
           SPI_DIN  : in    STD_LOGIC;
           SPI_DOUT : out   STD_LOGIC);
end memory_unit;

architecture Structural of memory_unit is

   -- import IO block
   COMPONENT io_block
      PORT (
         DATA_IN   : in    STD_LOGIC_VECTOR (7 downto 0);
         DATA_LOAD : in    STD_LOGIC;
         DIR_LOAD  : in    STD_LOGIC;
         CLOCK     : in    STD_LOGIC;
         DATA_OUT  : out   STD_LOGIC_VECTOR (7 downto 0);
         IO        : inout STD_LOGIC_VECTOR (7 downto 0)
      );
   END COMPONENT;
   
   -- import RAM
   COMPONENT main_ram
      PORT (
         clka  : IN  STD_LOGIC;
         wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
         addra : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);
         dina  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
         douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
   END COMPONENT;
   
   -- import 8-bit register
   COMPONENT reg8
      PORT (
         DATA    : in  STD_LOGIC_VECTOR (7 downto 0);
         LOAD_EN : in  STD_LOGIC;
         RESET   : in  STD_LOGIC;
         CLOCK   : in  STD_LOGIC;
         Q       : out STD_LOGIC_VECTOR (7 downto 0)
      );
   END COMPONENT;
   
   -- import stepper motor peripheral
   COMPONENT stepper_motor
      PORT (
         SPEED     : IN  STD_LOGIC_VECTOR (4 downto 0);
         STEPS     : IN  STD_LOGIC_VECTOR (7 downto 0);
         DIR       : IN  STD_LOGIC;
         ENABLE    : IN  STD_LOGIC;
         LD_SPEED  : IN  STD_LOGIC;
         LD_STEPS  : IN  STD_LOGIC;
         LD_DIR    : IN  STD_LOGIC;
         LD_ENABLE : IN  STD_LOGIC;
         CLOCK     : IN  STD_LOGIC;
         MOTOR     : OUT STD_LOGIC_VECTOR (3 downto 0)
      );
   END COMPONENT;
   
   -- main memory signals
   signal RAM_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal RAM_WEA : STD_LOGIC_VECTOR (0 downto 0);
   
   -- IO blocks' signals
   signal IO_DATA_WEA    : STD_LOGIC_VECTOR (15 downto 0);
   signal IO_DIR_WEA     : STD_LOGIC_VECTOR (15 downto 0);
   
   signal IO_0_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_1_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_2_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_3_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_4_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_5_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_6_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_7_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_8_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_9_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_10_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_11_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_12_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_13_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_14_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal IO_15_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);

   -- stepper motor's signals
   signal MOTOR_OUT : STD_LOGIC_VECTOR (3 downto 0);
   
   -- SPI flash controller signals
   signal SPI_CTRL_REG : STD_LOGIC_VECTOR (3 downto 0);
   
   -- selection and intermediate signals
   signal IO_BLOCK_SEL     : STD_LOGIC_VECTOR (4 downto 0);
   signal IO_BLOCK_EN      : STD_LOGIC_VECTOR (15 downto 0);
   signal ADDRESS_AND_15_5 : STD_LOGIC;

begin

   ADDRESS_AND_15_5 <= ADDRESS(15) and ADDRESS(14) and ADDRESS(13) and ADDRESS(12) and 
                       ADDRESS(11) and ADDRESS(10) and ADDRESS(9)  and ADDRESS(8)  and 
                       ADDRESS(7)  and ADDRESS(6)  and ADDRESS(5);

   -- set main memory write enable
   RAM_WEA(0) <= WEA and not(ADDRESS_AND_15_5);
   
   -- decode and enable IO block
   IO_BLOCK_SEL <= ADDRESS_AND_15_5 & ADDRESS(3 downto 0);
   with (IO_BLOCK_SEL) select
      IO_BLOCK_EN <= "0000000000000001" when "10000",
                     "0000000000000010" when "10001",
                     "0000000000000100" when "10010",
                     "0000000000001000" when "10011",
                     "0000000000010000" when "10100",
                     "0000000000100000" when "10101",
                     "0000000001000000" when "10110",
                     "0000000010000000" when "10111",
                     "0000000100000000" when "11000",
                     "0000001000000000" when "11001",
                     "0000010000000000" when "11010",
                     "0000100000000000" when "11011",
                     "0001000000000000" when "11100",
                     "0010000000000000" when "11101",
                     "0100000000000000" when "11110",
                     "1000000000000000" when "11111",
                     (others => '0')    when others;
   
   -- set IO blocks' data write enable bits
   IO_DATA_WEA(0)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(0);
   IO_DATA_WEA(1)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(1);
   IO_DATA_WEA(2)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(2);
   IO_DATA_WEA(3)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(3);
   IO_DATA_WEA(4)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(4);
   IO_DATA_WEA(5)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(5);
   IO_DATA_WEA(6)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(6);
   IO_DATA_WEA(7)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(7);
   IO_DATA_WEA(8)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(8);
   IO_DATA_WEA(9)  <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(9);
   IO_DATA_WEA(10) <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(10);
   IO_DATA_WEA(11) <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(11);
   IO_DATA_WEA(12) <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(12);
   IO_DATA_WEA(13) <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(13);
   IO_DATA_WEA(14) <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(14);
   IO_DATA_WEA(15) <= WEA and (not ADDRESS(4)) and IO_BLOCK_EN(15);
   
   -- set IO blocks' direction write enable bits
   IO_DIR_WEA(0)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(0);
   IO_DIR_WEA(1)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(1);
   IO_DIR_WEA(2)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(2);
   IO_DIR_WEA(3)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(3);
   IO_DIR_WEA(4)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(4);
   IO_DIR_WEA(5)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(5);
   IO_DIR_WEA(6)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(6);
   IO_DIR_WEA(7)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(7);
   IO_DIR_WEA(8)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(8);
   IO_DIR_WEA(9)  <= WEA and ADDRESS(4) and IO_BLOCK_EN(9);
   IO_DIR_WEA(10) <= WEA and ADDRESS(4) and IO_BLOCK_EN(10);
   IO_DIR_WEA(11) <= WEA and ADDRESS(4) and IO_BLOCK_EN(11);
   IO_DIR_WEA(12) <= WEA and ADDRESS(4) and IO_BLOCK_EN(12);
   IO_DIR_WEA(13) <= WEA and ADDRESS(4) and IO_BLOCK_EN(13);
   IO_DIR_WEA(14) <= WEA and ADDRESS(4) and IO_BLOCK_EN(14);
   IO_DIR_WEA(15) <= WEA and ADDRESS(4) and IO_BLOCK_EN(15);
   
   -- multiplex data output
   with (IO_BLOCK_SEL) select
      DATA_OUT <= IO_0_DATA_OUT  when "10000",
                  IO_1_DATA_OUT  when "10001",
                  IO_2_DATA_OUT  when "10010",
                  IO_3_DATA_OUT  when "10011",
                  IO_4_DATA_OUT  when "10100",
                  IO_5_DATA_OUT  when "10101",
                  IO_6_DATA_OUT  when "10110",
                  IO_7_DATA_OUT  when "10111",
                  IO_8_DATA_OUT  when "11000",
                  IO_9_DATA_OUT  when "11001",
                  IO_10_DATA_OUT when "11010",
                  IO_11_DATA_OUT when "11011",
                  IO_12_DATA_OUT when "11100",
                  IO_13_DATA_OUT when "11101",
                  IO_14_DATA_OUT when "11110",
                  IO_15_DATA_OUT when "11111",
                  RAM_OUT        when others;
   
   -- main memory instances
   main_mem_inst: main_ram
      PORT MAP (
         clka => CLOCK,
         wea => RAM_WEA,
         addra => ADDRESS(13 downto 0),
         dina => DATA_IN,
         douta => RAM_OUT
      );
   
   -----------------------
   -- IO Block instances
   -----------------------
   IO_0_inst: reg8
      PORT MAP (
         DATA => IO_0,
         LOAD_EN => '1',
         RESET => '0',
         CLOCK => CLOCK,
         Q => IO_0_DATA_OUT
      );
   
   IO_1_inst: reg8
      PORT MAP (
         DATA => DATA_IN,
         LOAD_EN => IO_DATA_WEA(1),
         RESET => '0',
         CLOCK => CLOCK,
         Q => IO_1_DATA_OUT
      );
   IO_1 <= IO_1_DATA_OUT;
   
   IO_2_inst: reg8
      PORT MAP (
         DATA => DATA_IN,
         LOAD_EN => IO_DATA_WEA(2),
         RESET => '0',
         CLOCK => CLOCK,
         Q => IO_2_DATA_OUT
      );
   IO_2 <= IO_2_DATA_OUT;
   
   -- IO 3,4,5,6 dedicated to stepper motor peripheral
   stepper_motor_inst: stepper_motor
      PORT MAP (
         SPEED => DATA_IN(4 downto 0),
         STEPS => DATA_IN,
         DIR => DATA_IN(0),
         ENABLE => DATA_IN(0),
         LD_SPEED => IO_DATA_WEA(3),
         LD_STEPS => IO_DATA_WEA(4),
         LD_DIR => IO_DATA_WEA(5),
         LD_ENABLE => IO_DATA_WEA(6),
         CLOCK => CLOCK,
         MOTOR => MOTOR_OUT
      );
   SM_OUT <= MOTOR_OUT;
   IO_3_DATA_OUT <= (others => '0');
   IO_4_DATA_OUT <= (others => '0');
   IO_5_DATA_OUT <= (others => '0');
   IO_6_DATA_OUT <= (others => '0');
   
   -- IO 7 to SPI flash
   --   IO_7(3) --> SPI_CS
   --   IO_7(2) --> SPI_CLK
   --   IO_7(1) --> SPI_MISO
   --   IO_7(0) --> SPI_MOSI
   spi_ctrl_reg_inst: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         SPI_CTRL_REG(1) <= SPI_DIN;
         
         if (IO_DATA_WEA(7) = '1') then
            SPI_CTRL_REG(0) <= DATA_IN(0);
            SPI_CTRL_REG(2) <= DATA_IN(2);
            SPI_CTRL_REG(3) <= DATA_IN(3);
         end if;
      end if;
   end process spi_ctrl_reg_inst;
   IO_7_DATA_OUT <= "0000" & SPI_CTRL_REG;
   SPI_CS <= SPI_CTRL_REG(3);
   SPI_CLK <= SPI_CTRL_REG(2);
   SPI_DOUT <= SPI_CTRL_REG(0);
   
   IO_8_inst: io_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => IO_DATA_WEA(8),
         DIR_LOAD => IO_DIR_WEA(8),
         CLOCK => CLOCK,
         DATA_OUT => IO_8_DATA_OUT,
         IO => IO_8
      );
   
   IO_9_inst: io_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => IO_DATA_WEA(9),
         DIR_LOAD => IO_DIR_WEA(9),
         CLOCK => CLOCK,
         DATA_OUT => IO_9_DATA_OUT,
         IO => IO_9
      );
   
   IO_10_inst: io_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => IO_DATA_WEA(10),
         DIR_LOAD => IO_DIR_WEA(10),
         CLOCK => CLOCK,
         DATA_OUT => IO_10_DATA_OUT,
         IO => IO_10
      );
   
   IO_11_inst: io_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => IO_DATA_WEA(11),
         DIR_LOAD => IO_DIR_WEA(11),
         CLOCK => CLOCK,
         DATA_OUT => IO_11_DATA_OUT,
         IO => IO_11
      );
   
   IO_12_inst: io_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => IO_DATA_WEA(12),
         DIR_LOAD => IO_DIR_WEA(12),
         CLOCK => CLOCK,
         DATA_OUT => IO_12_DATA_OUT,
         IO => IO_12
      );
      
   IO_13_inst: io_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => IO_DATA_WEA(13),
         DIR_LOAD => IO_DIR_WEA(13),
         CLOCK => CLOCK,
         DATA_OUT => IO_13_DATA_OUT,
         IO => IO_13
      );
      
   IO_14_inst: io_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => IO_DATA_WEA(14),
         DIR_LOAD => IO_DIR_WEA(14),
         CLOCK => CLOCK,
         DATA_OUT => IO_14_DATA_OUT,
         IO => IO_14
      );
      
   IO_15_inst: io_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => IO_DATA_WEA(15),
         DIR_LOAD => IO_DIR_WEA(15),
         CLOCK => CLOCK,
         DATA_OUT => IO_15_DATA_OUT,
         IO => IO_15
      );

end Structural;
