--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   17:05:57 02/13/2018
-- Module Name:   C:/Shared/hdl/processor/reg16_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: reg16
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY reg16_tb IS
END reg16_tb;
 
ARCHITECTURE behavior OF reg16_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT reg16
    PORT(
         DATA_IN : IN  std_logic_vector(7 downto 0);
         LOAD_EN : IN  std_logic_vector(1 downto 0);
         RESET : IN  std_logic;
         CLOCK : IN  std_logic;
         DATA_OUT : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal LOAD_EN : std_logic_vector(1 downto 0) := (others => '0');
   signal RESET : std_logic := '0';
   signal CLOCK : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   
   signal EXP_DATA_OUT : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: reg16 PORT MAP (
          DATA_IN => DATA_IN,
          LOAD_EN => LOAD_EN,
          RESET => RESET,
          CLOCK => CLOCK,
          DATA_OUT => DATA_OUT
        );

   -- Clock process definitions
   CLOCK_process :process
   begin
		CLOCK <= '0';
		wait for CLOCK_period/2;
		CLOCK <= '1';
		wait for CLOCK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
      -- reset
      LOAD_EN <= "00";
      RESET <= '1';
      EXP_DATA_OUT <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "RESET failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      ------------------
      -- LOAD(0xffff) --
      ------------------
      DATA_IN <= (others => '1');
      RESET <= '0';
      
      -- load into LSB
      LOAD_EN <= "10";
      EXP_DATA_OUT <= "00000000" & "11111111";
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0xffff) LSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- make sure data persists
      LOAD_EN <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0xffff) LSB data not persistent : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- load into MSB
      LOAD_EN <= "11";
      EXP_DATA_OUT <= (others => '1');
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0xffff) MSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- make sure data persists
      LOAD_EN <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0xffff) MSB data not persistent : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -------------
      -- LOAD(0) --
      -------------
      DATA_IN <= (others => '0');
      
      -- load into MSB
      LOAD_EN <= "11";
      EXP_DATA_OUT <= "00000000" & "11111111";
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0) MSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- make sure data persists
      LOAD_EN <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0) MSB data not persistent : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- load into LSB
      LOAD_EN <= "10";
      EXP_DATA_OUT <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0) LSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- make sure data persists
      LOAD_EN <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0) LSB data not persistent : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      report "All tests completed" severity NOTE;
      wait;
   end process;

END;
