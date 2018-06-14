----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    16:48:43 10/31/2017
-- Module Name:    io_block - Behavioral 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity io_block is
    Port ( DATA_IN   : in    STD_LOGIC_VECTOR (7 downto 0);
           DATA_LOAD : in    STD_LOGIC;
           DIR_LOAD  : in    STD_LOGIC;
           CLOCK     : in    STD_LOGIC;
           DATA_OUT  : out   STD_LOGIC_VECTOR (7 downto 0);
           IO        : inout STD_LOGIC_VECTOR (7 downto 0));
end io_block;

architecture Behavioral of io_block is

   -- import 8-bit register
   component reg8
    Port ( DATA     : in  STD_LOGIC_VECTOR (7 downto 0);
           LOAD_EN  : in  STD_LOGIC;
           RESET    : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           Q        : out STD_LOGIC_VECTOR (7 downto 0));
   end component;
   
   -- import tristate buffer
   component tristate_buffer
    Port ( A : in  STD_LOGIC;
           G : in  STD_LOGIC;
           Y : out STD_LOGIC);
   end component;
   
   -- direction register signals
   signal DIR_REG_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
   -- data register signals
   signal DATA_REG_IN : STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal DATA_REG_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal DATA_REG_LOAD : STD_LOGIC_VECTOR (7 DOWNTO 0);

begin

   -------------------------
   -- 8 MUXs for DATA_REG_IN
   -------------------------
   with (DIR_REG_OUT(0)) select
      DATA_REG_IN(0) <= IO(0)    when '0',
                        DATA_IN(0) when '1',
                        '0'        when others;
   with (DIR_REG_OUT(1)) select
      DATA_REG_IN(1) <= IO(1)    when '0',
                        DATA_IN(1) when '1',
                        '0'        when others;
   with (DIR_REG_OUT(2)) select
      DATA_REG_IN(2) <= IO(2)    when '0',
                        DATA_IN(2) when '1',
                        '0'        when others;
   with (DIR_REG_OUT(3)) select
      DATA_REG_IN(3) <= IO(3)    when '0',
                        DATA_IN(3) when '1',
                        '0'        when others;
   with (DIR_REG_OUT(4)) select
      DATA_REG_IN(4) <= IO(4)    when '0',
                        DATA_IN(4) when '1',
                        '0'        when others;
   with (DIR_REG_OUT(5)) select
      DATA_REG_IN(5) <= IO(5)    when '0',
                        DATA_IN(5) when '1',
                        '0'        when others;
   with (DIR_REG_OUT(6)) select
      DATA_REG_IN(6) <= IO(6)    when '0',
                        DATA_IN(6) when '1',
                        '0'        when others;
   with (DIR_REG_OUT(7)) select
      DATA_REG_IN(7) <= IO(7)    when '0',
                        DATA_IN(7) when '1',
                        '0'        when others;
   
   ---------------------------
   -- 8 MUXs for DATA_REG_LOAD
   ---------------------------
   with (DIR_REG_OUT(0)) select
      DATA_REG_LOAD(0) <= '1'       when '0',
                          DATA_LOAD when '1',
                          '0'       when others;
   with (DIR_REG_OUT(1)) select
      DATA_REG_LOAD(1) <= '1'       when '0',
                          DATA_LOAD when '1',
                          '0'       when others;
   with (DIR_REG_OUT(2)) select
      DATA_REG_LOAD(2) <= '1'       when '0',
                          DATA_LOAD when '1',
                          '0'       when others;
   with (DIR_REG_OUT(3)) select
      DATA_REG_LOAD(3) <= '1'       when '0',
                          DATA_LOAD when '1',
                          '0'       when others;
   with (DIR_REG_OUT(4)) select
      DATA_REG_LOAD(4) <= '1'       when '0',
                          DATA_LOAD when '1',
                          '0'       when others;
   with (DIR_REG_OUT(5)) select
      DATA_REG_LOAD(5) <= '1'       when '0',
                          DATA_LOAD when '1',
                          '0'       when others;
   with (DIR_REG_OUT(6)) select
      DATA_REG_LOAD(6) <= '1'       when '0',
                          DATA_LOAD when '1',
                          '0'       when others;
   with (DIR_REG_OUT(7)) select
      DATA_REG_LOAD(7) <= '1'       when '0',
                          DATA_LOAD when '1',
                          '0'       when others;
   
   DATA_OUT <= DATA_REG_OUT;

   -- 8-bit data register, with separate LOAD for each bit
   data_reg_inst0: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (DATA_REG_LOAD(0) = '1') then
            DATA_REG_OUT(0) <= DATA_REG_IN(0);
         end if;
      end if;
   end process data_reg_inst0;
   
   data_reg_inst1: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (DATA_REG_LOAD(1) = '1') then
            DATA_REG_OUT(1) <= DATA_REG_IN(1);
         end if;
      end if;
   end process data_reg_inst1;
   
   data_reg_inst2: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (DATA_REG_LOAD(2) = '1') then
            DATA_REG_OUT(2) <= DATA_REG_IN(2);
         end if;
      end if;
   end process data_reg_inst2;
   
   data_reg_inst3: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (DATA_REG_LOAD(3) = '1') then
            DATA_REG_OUT(3) <= DATA_REG_IN(3);
         end if;
      end if;
   end process data_reg_inst3;
         
   data_reg_inst4: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (DATA_REG_LOAD(4) = '1') then
            DATA_REG_OUT(4) <= DATA_REG_IN(4);
         end if;
      end if;
   end process data_reg_inst4;
   
   data_reg_inst5: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (DATA_REG_LOAD(5) = '1') then
            DATA_REG_OUT(5) <= DATA_REG_IN(5);
         end if;
      end if;
   end process data_reg_inst5;
   
   data_reg_inst6: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (DATA_REG_LOAD(6) = '1') then
            DATA_REG_OUT(6) <= DATA_REG_IN(6);
         end if;
      end if;
   end process data_reg_inst6;
   
   data_reg_inst7: process(CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         if (DATA_REG_LOAD(7) = '1') then
            DATA_REG_OUT(7) <= DATA_REG_IN(7);
         end if;
      end if;
   end process data_reg_inst7;
   
   -- 8-bit direction register
   dir_reg_inst: reg8
      PORT MAP (
         DATA => DATA_IN,
         LOAD_EN => DIR_LOAD,
         RESET => '0',
         CLOCK => CLOCK,
         Q => DIR_REG_OUT
      );
   
   -----------------------------------------------
   -- 8 tristate buffers to control output to IO
   -----------------------------------------------
   tsb0: tristate_buffer
      PORT MAP (
         A => DATA_REG_OUT(0),
         G => DIR_REG_OUT(0),
         Y => IO(0)
      );
   tsb1: tristate_buffer
      PORT MAP (
         A => DATA_REG_OUT(1),
         G => DIR_REG_OUT(1),
         Y => IO(1)
      );
   tsb2: tristate_buffer
      PORT MAP (
         A => DATA_REG_OUT(2),
         G => DIR_REG_OUT(2),
         Y => IO(2)
      );
   tsb3: tristate_buffer
      PORT MAP (
         A => DATA_REG_OUT(3),
         G => DIR_REG_OUT(3),
         Y => IO(3)
      );
   tsb4: tristate_buffer
      PORT MAP (
         A => DATA_REG_OUT(4),
         G => DIR_REG_OUT(4),
         Y => IO(4)
      );
   tsb5: tristate_buffer
      PORT MAP (
         A => DATA_REG_OUT(5),
         G => DIR_REG_OUT(5),
         Y => IO(5)
      );
   tsb6: tristate_buffer
      PORT MAP (
         A => DATA_REG_OUT(6),
         G => DIR_REG_OUT(6),
         Y => IO(6)
      );
   tsb7: tristate_buffer
      PORT MAP (
         A => DATA_REG_OUT(7),
         G => DIR_REG_OUT(7),
         Y => IO(7)
      );

end Behavioral;
