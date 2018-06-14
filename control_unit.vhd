----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    21:36:59 09/22/2017
-- Module Name:    control_unit - Behavioral
-- Target Devices: Numato MIMAS V2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control_unit is
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           FLAGS    : in  STD_LOGIC_VECTOR (7 downto 0);
           RESET    : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (32 downto 0));
end control_unit;

architecture Behavioral of control_unit is

   component decoder_ram
      Port ( clka  : in  STD_LOGIC;
             wea   : in  STD_LOGIC_VECTOR (0 DOWNTO 0);
             addra : in  STD_LOGIC_VECTOR (4 DOWNTO 0);
             dina  : in  STD_LOGIC_VECTOR (8 DOWNTO 0);
             douta : out STD_LOGIC_VECTOR (8 DOWNTO 0));
   end component;
   
   component mp_ram
      Port ( clka  : in  STD_LOGIC;
             wea   : in  STD_LOGIC_VECTOR (0 DOWNTO 0);
             addra : in  STD_LOGIC_VECTOR (8 DOWNTO 0);
             dina  : in  STD_LOGIC_VECTOR (32 DOWNTO 0);
             douta : out STD_LOGIC_VECTOR (32 DOWNTO 0));
   end component;
   
   -- Decoder memory signals
   signal mp_address : STD_LOGIC_VECTOR (8 DOWNTO 0);
   
   -- Microprogram sequencer signals
   signal sequencer_data : STD_LOGIC_VECTOR (8 DOWNTO 0);
   
   -- Microprogram memory signals
   signal instruction : STD_LOGIC_VECTOR (32 DOWNTO 0);
   
   -- Control signals
   signal OP_CODE : STD_LOGIC_VECTOR (4 DOWNTO 0);
   signal FLAG_SEL : STD_LOGIC_VECTOR (2 DOWNTO 0);
   signal LMS, RMS, FLAG : STD_LOGIC;

begin

   OP_CODE <= DATA_IN (7 downto 3);
   FLAG_SEL <= DATA_IN (2 downto 0);
   LMS <= instruction(14);
   RMS <= RESET or instruction(12);
   DATA_OUT <= instruction;
   
   with (FLAG_SEL) select
      FLAG <= FLAGS(0) when "000",
              FLAGS(1) when "001",
              FLAGS(2) when "010",
              FLAGS(3) when "011",
              FLAGS(4) when "100",
              FLAGS(5) when "101",
              FLAGS(6) when "110",
              FLAGS(7) when "111",
              '0'     when others;

   -- Memory containing addresses of microprograms
   dec_mem: decoder_ram
      Port map (
         clka  => CLOCK,
         wea   => "0",
         addra => OP_CODE,
         dina  => (others => '0'),
         douta => mp_address
      );
   
   -- Program counter for the microprograms
   sequencer: process (CLOCK)
   begin
      if (rising_edge(CLOCK)) then
         -- handle RESET
         if (RMS = '1') then
            sequencer_data <= (others => '0');
         
         -- handle LOAD
         elsif (LMS = '1') then
            -- handling for JPD, JPP and CAD when <fl>=0
            if (((OP_CODE(4 DOWNTO 0) = "10101") or    -- JPD
                 (OP_CODE(4 DOWNTO 0) = "10110") or    -- JPP
                 (OP_CODE(4 DOWNTO 0) = "11000")) and  -- CAD
                (FLAG /= '1')) then
               sequencer_data <= "101011101";  -- address of FLF - 1
            -- handling for JPR, CAR and RET when <fl>=0
            elsif (((OP_CODE(4 DOWNTO 0) = "10111") or    -- JPR
                    (OP_CODE(4 DOWNTO 0) = "11001") or    -- CAR
                    (OP_CODE(4 DOWNTO 0) = "11010")) and  -- RET
                   (FLAG /= '1')) then
               sequencer_data <= "000010010";  -- address of NOP - 1
            else
               sequencer_data <= mp_address;
            end if;
            
         else
            sequencer_data <= sequencer_data + 1;
         end if;
      end if;
   end process sequencer;
   
   -- Memory containing microinstructions
   mp_mem: mp_ram
      Port map (
         clka  => CLOCK,
         wea   => "0",
         addra => sequencer_data,
         dina  => (others => '0'),
         douta => instruction
      );

end Behavioral;
