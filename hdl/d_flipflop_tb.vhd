--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   10:36:10 06/09/2018
-- Module Name:   C:/Shared/hdl/processor/d_flipflop_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: d_flipflop
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY d_flipflop_tb IS
END d_flipflop_tb;
 
ARCHITECTURE behavior OF d_flipflop_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT d_flipflop
    PORT(
         D : IN  std_logic;
         CLOCK : IN  std_logic;
         RESET : IN  std_logic;
         Q : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal D : std_logic := '0';
   signal CLOCK : std_logic := '0';
   signal RESET : std_logic := '0';

 	--Outputs
   signal Q : std_logic;

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: d_flipflop PORT MAP (
          D => D,
          CLOCK => CLOCK,
          RESET => RESET,
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
      -- check reset
      D <= '-';
      RESET <= '1';
      wait for CLOCK_period;
      assert Q = '0'
         report "RESET failed ; Expected = '0' ; Received = " & std_logic'image(Q)
         severity ERROR;
      
      -- load '1'
      D <= '1';
      RESET <= '0';
      wait for CLOCK_period;
      assert Q = D
         report "RESET failed ; Expected = " &
            std_logic'image(D) & " ; Received = " &
            std_logic'image(Q)
         severity ERROR;
      
      -- load '0'
      D <= '0';
      RESET <= '0';
      wait for CLOCK_period;
      assert Q = D
         report "RESET failed ; Expected = " &
            std_logic'image(D) & " ; Received = " &
            std_logic'image(Q)
         severity ERROR;
      
      report "All Tests Completed" severity NOTE;

      wait;
   end process;

END;
