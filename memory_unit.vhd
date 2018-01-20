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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_unit is
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
end memory_unit;

architecture Structural of memory_unit is

   -- import GPIO block
   COMPONENT gpio_block
      PORT (
         DATA_IN   : in    STD_LOGIC_VECTOR (7 downto 0);
         DATA_LOAD : in    STD_LOGIC;
         DIR_LOAD  : in    STD_LOGIC;
         CLOCK     : in    STD_LOGIC;
         DATA_OUT  : out   STD_LOGIC_VECTOR (7 downto 0);
         GPIO      : inout STD_LOGIC_VECTOR (7 downto 0)
      );
   END COMPONENT;
   
   -- import RAM
   COMPONENT main_ram
      PORT (
         clka  : IN  STD_LOGIC;
         ena   : IN  STD_LOGIC;
         wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
         addra : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
         dina  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
         douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
   END COMPONENT;
   
   -- main memory signals
   signal RAM_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal RAM_WEA : STD_LOGIC_VECTOR (0 downto 0);

   -- GPIO blocks' signals
   signal GPIO_DATA_WEA, GPIO_DIR_WEA : STD_LOGIC_VECTOR (15 downto 0);
   signal GPIO_0_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_1_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_2_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_3_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_4_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_5_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_6_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_7_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_8_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_9_DATA_OUT  : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_10_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_11_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_12_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_13_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_14_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   signal GPIO_15_DATA_OUT : STD_LOGIC_VECTOR (7 downto 0);
   
   -- selection and intermediate signals
   signal GPIO_BLOCK_SEL : STD_LOGIC_VECTOR (6 downto 0);
   signal GPIO_BLOCK_EN : STD_LOGIC_VECTOR (15 downto 0);

begin

   -- set main memory write enable
   RAM_WEA(0) <= WEA and not(ADDRESS(7) and ADDRESS(6) and ADDRESS(5));
   
   -- decode GPIO block
   GPIO_BLOCK_SEL <= ADDRESS(7 downto 5) & ADDRESS(3 downto 0);
   with (GPIO_BLOCK_SEL) select
      GPIO_BLOCK_EN <= "0000000000000001" when "1110000",
                       "0000000000000010" when "1110001",
                       "0000000000000100" when "1110010",
                       "0000000000001000" when "1110011",
                       "0000000000010000" when "1110100",
                       "0000000000100000" when "1110101",
                       "0000000001000000" when "1110110",
                       "0000000010000000" when "1110111",
                       "0000000100000000" when "1111000",
                       "0000001000000000" when "1111001",
                       "0000010000000000" when "1111010",
                       "0000100000000000" when "1111011",
                       "0001000000000000" when "1111100",
                       "0010000000000000" when "1111101",
                       "0100000000000000" when "1111110",
                       "1000000000000000" when "1111111",
                       "0000000000000000" when others;
   
   -- set GPIO blocks' data write enable bits
   GPIO_DATA_WEA(0)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(0);
   GPIO_DATA_WEA(1)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(1);
   GPIO_DATA_WEA(2)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(2);
   GPIO_DATA_WEA(3)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(3);
   GPIO_DATA_WEA(4)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(4);
   GPIO_DATA_WEA(5)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(5);
   GPIO_DATA_WEA(6)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(6);
   GPIO_DATA_WEA(7)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(7);
   GPIO_DATA_WEA(8)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(8);
   GPIO_DATA_WEA(9)  <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(9);
   GPIO_DATA_WEA(10) <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(10);
   GPIO_DATA_WEA(11) <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(11);
   GPIO_DATA_WEA(12) <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(12);
   GPIO_DATA_WEA(13) <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(13);
   GPIO_DATA_WEA(14) <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(14);
   GPIO_DATA_WEA(15) <= WEA and (not ADDRESS(4)) and GPIO_BLOCK_EN(15);
   
   -- set GPIO blocks' direction write enable bits
   GPIO_DIR_WEA(0)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(0);
   GPIO_DIR_WEA(1)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(1);
   GPIO_DIR_WEA(2)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(2);
   GPIO_DIR_WEA(3)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(3);
   GPIO_DIR_WEA(4)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(4);
   GPIO_DIR_WEA(5)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(5);
   GPIO_DIR_WEA(6)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(6);
   GPIO_DIR_WEA(7)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(7);
   GPIO_DIR_WEA(8)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(8);
   GPIO_DIR_WEA(9)  <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(9);
   GPIO_DIR_WEA(10) <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(10);
   GPIO_DIR_WEA(11) <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(11);
   GPIO_DIR_WEA(12) <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(12);
   GPIO_DIR_WEA(13) <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(13);
   GPIO_DIR_WEA(14) <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(14);
   GPIO_DIR_WEA(15) <= WEA and ADDRESS(4) and GPIO_BLOCK_EN(15);
   
   -- multiplex data output
   with (GPIO_BLOCK_SEL) select
      DATA_OUT <= GPIO_0_DATA_OUT  when "1110000",
                  GPIO_1_DATA_OUT  when "1110001",
                  GPIO_2_DATA_OUT  when "1110010",
                  GPIO_3_DATA_OUT  when "1110011",
                  GPIO_4_DATA_OUT  when "1110100",
                  GPIO_5_DATA_OUT  when "1110101",
                  GPIO_6_DATA_OUT  when "1110110",
                  GPIO_7_DATA_OUT  when "1110111",
                  GPIO_8_DATA_OUT  when "1111000",
                  GPIO_9_DATA_OUT  when "1111001",
                  GPIO_10_DATA_OUT when "1111010",
                  GPIO_11_DATA_OUT when "1111011",
                  GPIO_12_DATA_OUT when "1111100",
                  GPIO_13_DATA_OUT when "1111101",
                  GPIO_14_DATA_OUT when "1111110",
                  GPIO_15_DATA_OUT when "1111111",
                  RAM_OUT          when others;
   
   -- main memory instance
   main_mem_inst: main_ram
      PORT MAP (
         clka => CLOCK,
         ena => '1',
         wea => RAM_WEA,
         addra => ADDRESS,
         dina => DATA_IN,
         douta => RAM_OUT
      );
   
   -----------------------
   -- GPIO Block instances
   -----------------------
   GPIO_0_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(0),
         DIR_LOAD => GPIO_DIR_WEA(0),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_0_DATA_OUT,
         GPIO => GPIO_0
      );
   
   GPIO_1_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(1),
         DIR_LOAD => GPIO_DIR_WEA(1),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_1_DATA_OUT,
         GPIO => GPIO_1
      );
   
   GPIO_2_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(2),
         DIR_LOAD => GPIO_DIR_WEA(2),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_2_DATA_OUT,
         GPIO => GPIO_2
      );
   
   GPIO_3_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(3),
         DIR_LOAD => GPIO_DIR_WEA(3),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_3_DATA_OUT,
         GPIO => GPIO_3
      );
   
   GPIO_4_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(4),
         DIR_LOAD => GPIO_DIR_WEA(4),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_4_DATA_OUT,
         GPIO => GPIO_4
      );
   
   GPIO_5_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(5),
         DIR_LOAD => GPIO_DIR_WEA(5),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_5_DATA_OUT,
         GPIO => GPIO_5
      );
   
   GPIO_6_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(6),
         DIR_LOAD => GPIO_DIR_WEA(6),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_6_DATA_OUT,
         GPIO => GPIO_6
      );
   
   GPIO_7_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(7),
         DIR_LOAD => GPIO_DIR_WEA(7),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_7_DATA_OUT,
         GPIO => GPIO_7
      );
   
   GPIO_8_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(8),
         DIR_LOAD => GPIO_DIR_WEA(8),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_8_DATA_OUT,
         GPIO => GPIO_8
      );
   
   GPIO_9_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(9),
         DIR_LOAD => GPIO_DIR_WEA(9),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_9_DATA_OUT,
         GPIO => GPIO_9
      );
   
   GPIO_10_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(10),
         DIR_LOAD => GPIO_DIR_WEA(10),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_10_DATA_OUT,
         GPIO => GPIO_10
      );
   
   GPIO_11_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(11),
         DIR_LOAD => GPIO_DIR_WEA(11),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_11_DATA_OUT,
         GPIO => GPIO_11
      );
   
   GPIO_12_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(12),
         DIR_LOAD => GPIO_DIR_WEA(12),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_12_DATA_OUT,
         GPIO => GPIO_12
      );
   
   GPIO_13_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(13),
         DIR_LOAD => GPIO_DIR_WEA(13),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_13_DATA_OUT,
         GPIO => GPIO_13
      );
   
   GPIO_14_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(14),
         DIR_LOAD => GPIO_DIR_WEA(14),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_14_DATA_OUT,
         GPIO => GPIO_14
      );
   
   GPIO_15_inst: gpio_block
      PORT MAP (
         DATA_IN => DATA_IN,
         DATA_LOAD => GPIO_DATA_WEA(15),
         DIR_LOAD => GPIO_DIR_WEA(15),
         CLOCK => CLOCK,
         DATA_OUT => GPIO_15_DATA_OUT,
         GPIO => GPIO_15
      );

end Structural;
