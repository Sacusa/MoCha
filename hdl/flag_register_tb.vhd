--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   10:37:19 06/09/2018
-- Module Name:   C:/Shared/hdl/processor/flag_register_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: flag_register
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY flag_register_tb IS
END flag_register_tb;
 
ARCHITECTURE behavior OF flag_register_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT flag_register
    PORT(
         FLAG_Z : IN  std_logic;
         FLAG_C : IN  std_logic;
         FLAG_S : IN  std_logic;
         FLAG_P : IN  std_logic;
         LOAD : IN  std_logic;
         CLOCK : IN  std_logic;
         DATA_OUT : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal FLAG_Z : std_logic := '0';
   signal FLAG_C : std_logic := '0';
   signal FLAG_S : std_logic := '0';
   signal FLAG_P : std_logic := '0';
   signal LOAD : std_logic := '0';
   signal CLOCK : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   
   signal EXP_DATA_OUT : std_logic_vector(7 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: flag_register PORT MAP (
          FLAG_Z => FLAG_Z,
          FLAG_C => FLAG_C,
          FLAG_S => FLAG_S,
          FLAG_P => FLAG_P,
          LOAD => LOAD,
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
      -- initialize for number 0
      FLAG_Z <= '1';
      FLAG_C <= '0';
      FLAG_S <= '0';
      FLAG_P <= '1';
      LOAD <= '0';
      wait for CLOCK_period;
      LOAD <= '1';
      EXP_DATA_OUT <= FLAG_P & FLAG_S & (FLAG_Z nor FLAG_S) & (not FLAG_C) &
                      FLAG_C & (not FLAG_Z) & FLAG_Z & '1';
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "INIT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- positive number with carry and odd parity
      FLAG_Z <= '0';
      FLAG_C <= '1';
      FLAG_S <= '0';
      FLAG_P <= '0';
      LOAD <= '0';
      wait for CLOCK_period;
      LOAD <= '1';
      EXP_DATA_OUT <= FLAG_P & FLAG_S & (FLAG_Z nor FLAG_S) & (not FLAG_C) &
                      FLAG_C & (not FLAG_Z) & FLAG_Z & '1';
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "INIT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- negative number without carry and even parity
      FLAG_Z <= '0';
      FLAG_C <= '0';
      FLAG_S <= '1';
      FLAG_P <= '1';
      LOAD <= '0';
      wait for CLOCK_period;
      LOAD <= '1';
      EXP_DATA_OUT <= FLAG_P & FLAG_S & (FLAG_Z nor FLAG_S) & (not FLAG_C) &
                      FLAG_C & (not FLAG_Z) & FLAG_Z & '1';
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "INIT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- make sure there are no erroneous loads
      FLAG_Z <= '0';
      FLAG_C <= '1';
      FLAG_S <= '1';
      FLAG_P <= '1';
      LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "INIT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      report "All Tests Completed" severity NOTE;

      wait;
   end process;

END;
