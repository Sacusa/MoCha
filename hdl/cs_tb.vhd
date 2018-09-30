--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   11:25:18 06/09/2018
-- Module Name:   C:/Shared/hdl/processor/cs_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: cs
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY cs_tb IS
END cs_tb;
 
ARCHITECTURE behavior OF cs_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cs
    PORT(
         DATA_IN : IN  std_logic_vector(7 downto 0);
         SCS : IN  std_logic_vector(1 downto 0);
         DATA_OUT : OUT  std_logic_vector(7 downto 0);
         FLAG_Z : OUT  std_logic;
         FLAG_C : OUT  std_logic;
         FLAG_S : OUT  std_logic;
         FLAG_P : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal SCS : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);
   signal FLAG_Z : std_logic;
   signal FLAG_C : std_logic;
   signal FLAG_S : std_logic;
   signal FLAG_P : std_logic;
   
   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   
   signal EXP_DATA_OUT : std_logic_vector(7 downto 0);
   signal EXP_FLAG_Z : std_logic;
   signal EXP_FLAG_C : std_logic;
   signal EXP_FLAG_S : std_logic;
   signal EXP_FLAG_P : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cs PORT MAP (
          DATA_IN => DATA_IN,
          SCS => SCS,
          DATA_OUT => DATA_OUT,
          FLAG_Z => FLAG_Z,
          FLAG_C => FLAG_C,
          FLAG_S => FLAG_S,
          FLAG_P => FLAG_P
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 10 cycles.
      DATA_IN <= "10101010";
      wait for CLOCK_period*10;
      
      -- check pass
      SCS <= "00";
      EXP_DATA_OUT <= DATA_IN;
      wait for CLOCK_period;
      if (EXP_DATA_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= '0';
      EXP_FLAG_S <= EXP_DATA_OUT(7);
      EXP_FLAG_P <= not(EXP_DATA_OUT(0) xor EXP_DATA_OUT(1) xor EXP_DATA_OUT(2) xor
                        EXP_DATA_OUT(3) xor EXP_DATA_OUT(4) xor EXP_DATA_OUT(5) xor
                        EXP_DATA_OUT(6) xor EXP_DATA_OUT(7));
      wait for CLOCK_period;
      
      assert DATA_OUT = EXP_DATA_OUT
         report "00 : DATA_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " Received = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report "00 : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report "00 : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report "00 : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report "00 : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;

      -- check complement
      SCS <= "01";
      EXP_DATA_OUT <= not(DATA_IN);
      wait for CLOCK_period;
      if (EXP_DATA_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= '0';
      EXP_FLAG_S <= EXP_DATA_OUT(7);
      EXP_FLAG_P <= not(EXP_DATA_OUT(0) xor EXP_DATA_OUT(1) xor EXP_DATA_OUT(2) xor
                        EXP_DATA_OUT(3) xor EXP_DATA_OUT(4) xor EXP_DATA_OUT(5) xor
                        EXP_DATA_OUT(6) xor EXP_DATA_OUT(7));
      wait for CLOCK_period;
      
      assert DATA_OUT = EXP_DATA_OUT
         report "00 : DATA_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " Received = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report "00 : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report "00 : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report "00 : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report "00 : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- check left shift
      SCS <= "10";
      EXP_DATA_OUT <= DATA_IN(6 downto 0) & '0';
      wait for CLOCK_period;
      if (EXP_DATA_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= DATA_IN(7);
      EXP_FLAG_S <= EXP_DATA_OUT(7);
      EXP_FLAG_P <= not(EXP_DATA_OUT(0) xor EXP_DATA_OUT(1) xor EXP_DATA_OUT(2) xor
                        EXP_DATA_OUT(3) xor EXP_DATA_OUT(4) xor EXP_DATA_OUT(5) xor
                        EXP_DATA_OUT(6) xor EXP_DATA_OUT(7));
      wait for CLOCK_period;
      
      assert DATA_OUT = EXP_DATA_OUT
         report "00 : DATA_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " Received = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report "00 : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report "00 : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report "00 : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report "00 : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- check right shift
      SCS <= "11";
      EXP_DATA_OUT <= DATA_IN(7) & DATA_IN(7 downto 1);
      wait for CLOCK_period;
      if (EXP_DATA_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= DATA_IN(0);
      EXP_FLAG_S <= EXP_DATA_OUT(7);
      EXP_FLAG_P <= not(EXP_DATA_OUT(0) xor EXP_DATA_OUT(1) xor EXP_DATA_OUT(2) xor
                        EXP_DATA_OUT(3) xor EXP_DATA_OUT(4) xor EXP_DATA_OUT(5) xor
                        EXP_DATA_OUT(6) xor EXP_DATA_OUT(7));
      wait for CLOCK_period;
      
      assert DATA_OUT = EXP_DATA_OUT
         report "00 : DATA_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " Received = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report "00 : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report "00 : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report "00 : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report "00 : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      report "All Tests Completed" severity NOTE;

      wait;
   end process;

END;
