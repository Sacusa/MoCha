--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   10:40:34 06/09/2018
-- Module Name:   C:/Shared/hdl/processor/tristate_buffer_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: tristate_buffer
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tristate_buffer_tb IS
END tristate_buffer_tb;
 
ARCHITECTURE behavior OF tristate_buffer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT tristate_buffer
    PORT(
         A : IN  std_logic;
         G : IN  std_logic;
         Y : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic := '0';
   signal G : std_logic := '0';

 	--Outputs
   signal Y : std_logic;
   
   -- Clock period definitions
   constant CLOCK_period : time := 1 ns;
   
   signal EXP_Y : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: tristate_buffer PORT MAP (
          A => A,
          G => G,
          Y => Y
        );

   -- Stimulus process
   stim_proc: process
   begin
      -- disable output
      A <= '-';
      G <= '0';
      EXP_Y <= 'Z';      
      wait for CLOCK_period;
      assert Y = EXP_Y
         report "DISABLE check failed : Expected Y = " &
            std_logic'image(EXP_Y) & " ; Received Y = " &
            std_logic'image(Y)
         severity ERROR;
      
      -- enable output with A = 0
      A <= '0';
      G <= '1';
      EXP_Y <= '0';      
      wait for CLOCK_period;
      assert Y = EXP_Y
         report "ENABLE with A = " &
            std_logic'image(A) & " failed : Expected Y = " &
            std_logic'image(EXP_Y) & " ; Received Y = " &
            std_logic'image(Y)
         severity ERROR;
      
      -- enable output with A = 1
      A <= '1';
      G <= '1';
      EXP_Y <= '1';      
      wait for CLOCK_period;
      assert Y = EXP_Y
         report "ENABLE with A = " &
            std_logic'image(A) & " failed : Expected Y = " &
            std_logic'image(EXP_Y) & " ; Received Y = " &
            std_logic'image(Y)
         severity ERROR;
      wait;
   end process;

END;
