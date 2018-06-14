--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   10:39:36 06/09/2018
-- Module Name:   C:/Shared/hdl/processor/reg8_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: reg8
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY reg8_tb IS
END reg8_tb;
 
ARCHITECTURE behavior OF reg8_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT reg8
    PORT(
         DATA : IN  std_logic_vector(7 downto 0);
         LOAD_EN : IN  std_logic;
         RESET : IN  std_logic;
         CLOCK : IN  std_logic;
         Q : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA : std_logic_vector(7 downto 0) := (others => '0');
   signal LOAD_EN : std_logic := '0';
   signal RESET : std_logic := '0';
   signal CLOCK : std_logic := '0';

 	--Outputs
   signal Q : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   
   signal EXP_Q : std_logic_vector(7 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: reg8 PORT MAP (
          DATA => DATA,
          LOAD_EN => LOAD_EN,
          RESET => RESET,
          CLOCK => CLOCK,
          Q => Q
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
      LOAD_EN <= '0';
      RESET <= '1';
      EXP_Q <= (others => '0');
      wait for CLOCK_period;
      assert Q = EXP_Q
         report "RESET failed : Expected Q = " &
            integer'image(to_integer(unsigned(EXP_Q))) & " ; Received Q = " &
            integer'image(to_integer(unsigned(Q)))
         severity ERROR;

      -- load 0xaa
      DATA <= "1010" & "1010";
      LOAD_EN <= '1';
      RESET <= '0';
      wait for CLOCK_period / 2;
      EXP_Q <= DATA;
      wait for CLOCK_period / 2;
      assert Q = EXP_Q
         report "LOAD 0xaa failed : Expected Q = " &
            integer'image(to_integer(unsigned(EXP_Q))) & " ; Received Q = " &
            integer'image(to_integer(unsigned(Q)))
         severity ERROR;
      
      -- load 0x55
      DATA <= "0101" & "0101";
      LOAD_EN <= '1';
      RESET <= '0';
      wait for CLOCK_period / 2;
      EXP_Q <= DATA;
      wait for CLOCK_period / 2;
      assert Q = EXP_Q
         report "LOAD 0x55 failed : Expected Q = " &
            integer'image(to_integer(unsigned(EXP_Q))) & " ; Received Q = " &
            integer'image(to_integer(unsigned(Q)))
         severity ERROR;
      
      -- load 0x00
      DATA <= (others => '0');
      LOAD_EN <= '1';
      RESET <= '0';
      wait for CLOCK_period / 2;
      EXP_Q <= DATA;
      wait for CLOCK_period / 2;
      assert Q = EXP_Q
         report "LOAD 0x00 failed : Expected Q = " &
            integer'image(to_integer(unsigned(EXP_Q))) & " ; Received Q = " &
            integer'image(to_integer(unsigned(Q)))
         severity ERROR;

      report "All tests completed" severity NOTE;
      
      wait;
   end process;

END;
