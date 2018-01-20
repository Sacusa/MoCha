--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   13:53:49 09/26/2017
-- Module Name:   C:/Shared/hdl/processor/control_unit_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: control_unit
-- 
-- Revision:
-- Revision 0.01 - File Created
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
 
ENTITY control_unit_tb IS
END control_unit_tb;
 
ARCHITECTURE behavior OF control_unit_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT control_unit
    PORT(
         DATA_IN  : IN  std_logic_vector(7 downto 0);
         FLAG     : IN  std_logic;
         CLOCK    : IN  std_logic;
         RESET    : IN  std_logic;
         DATA_OUT : OUT std_logic_vector(27 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal RESET : std_logic := '0';
   signal FLAG : std_logic := '0';
   signal CLOCK : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic_vector(27 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: control_unit PORT MAP (
          DATA_IN  => DATA_IN,
          FLAG     => FLAG,
          RESET    => RESET,
          CLOCK    => CLOCK,
          DATA_OUT => DATA_OUT
        );

   -- Clock process definitions
   CLOCK_process: process
   begin
		CLOCK <= '0';
		wait for CLOCK_period/2;
		CLOCK <= '1';
		wait for CLOCK_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 10 cycles
      DATA_IN <= "00100000";
      FLAG <= '0';
      RESET <= '1';
      wait for 10*CLOCK_period;

      RESET <= '0';
      
      -- RESET : 1
      wait for CLOCK_period;
      assert DATA_OUT = "0010010000000001000000110000" report "RESET:1" severity ERROR;
      
      -- RESET : 2
      wait for CLOCK_period;
      assert DATA_OUT = "1000100001000000000000000000" report "RESET:2" severity ERROR;
      
      -- RESET : 3
      wait for CLOCK_period;
      assert DATA_OUT = "1000000001000000000000000000" report "RESET:3" severity ERROR;
      
      -- RESET : 4
      wait for CLOCK_period;
      assert DATA_OUT = "0011000000000000000000000000" report "RESET:4" severity ERROR;
      
      -- RESET : 5
      wait for CLOCK_period;
      assert DATA_OUT = "1000000000000000000000000000" report "RESET:5" severity ERROR;
      
      -- RESET : 6
      wait for CLOCK_period;
      assert DATA_OUT = "1000010000000000000000000000" report "RESET:6" severity ERROR;
      
      -- RESET : 7
      wait for CLOCK_period;
      assert DATA_OUT = "0011000000000000000000000000" report "RESET:7" severity ERROR;
      
      -- RESET : 8
      wait for CLOCK_period;
      assert DATA_OUT = "1000100000000000000000000000" report "RESET:8" severity ERROR;
      
      -- RESET : 9
      wait for CLOCK_period;
      assert DATA_OUT = "1000000000100000000000000001" report "RESET:9" severity ERROR;
      
      -- RESET : 10
      wait for CLOCK_period;
      assert DATA_OUT = "0000000000010000000000000000" report "RESET:10" severity ERROR;
      
      -- MVI : 1
      wait for CLOCK_period;
      assert DATA_OUT = "0011000000000000000000000000" report "MVI:1" severity ERROR;
      
      -- MVI : 2
      wait for CLOCK_period;
      assert DATA_OUT = "1000000000000000000000000000" report "MVI:2" severity ERROR;
      
      -- MVI : 3
      wait for CLOCK_period;
      assert DATA_OUT = "1000100000000000000000000010" report "MVI:3" severity ERROR;
      
      -- MVI : 4
      wait for CLOCK_period;
      assert DATA_OUT = "0011000000000000000000000000" report "MVI:4" severity ERROR;
      
      -- MVI : 5
      wait for CLOCK_period;
      assert DATA_OUT = "1000100000000000000000000000" report "MVI:5" severity ERROR;
      
      -- MVI : 6
      wait for CLOCK_period;
      assert DATA_OUT = "1000000000100000000000000001" report "MVI:6" severity ERROR;
      
      -- MVI : 7
      wait for CLOCK_period;
      assert DATA_OUT = "0000000000010000000000000000" report "MVI:7" severity ERROR;
      
      wait;
   end process;

END;
