--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   14:59:20 09/19/2017
-- Module Name:   C:/Shared/hdl/processor/pc_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: pc
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
 
ENTITY pc_tb IS
END pc_tb;
 
ARCHITECTURE behavior OF pc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT pc
    PORT(
         DATA_IN  : IN  std_logic_vector(7 downto 0);
         CLOCK    : IN  std_logic;
         RESET    : IN  std_logic;
         OE       : IN  std_logic;
         INC      : IN  std_logic;
         LOAD     : IN  std_logic;
         DATA_OUT : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal CLOCK   : std_logic := '0';
   signal RESET   : std_logic := '0';
   signal OE      : std_logic := '0';
   signal INC     : std_logic := '0';
   signal LOAD    : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pc PORT MAP (
          DATA_IN  => DATA_IN,
          CLOCK    => CLOCK,
          RESET    => RESET,
          OE       => OE,
          INC      => INC,
          LOAD     => LOAD,
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
      DATA_IN <= "11111111";
      RESET <= '1';
      OE <= '1';
      INC <= '0';
      LOAD <= '0';
      wait for CLOCK_period*10;

      -- check RESET
      assert DATA_OUT = "00000000" report "RESET failed" severity ERROR;
      
      -- check OE
      OE <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "ZZZZZZZZ" report "OE failed" severity ERROR;
      
      ---------------------------------------------------------
      -- Following test cases increment PC till it resets to 0.
      ---------------------------------------------------------
      RESET <= '0';
      OE <= '1';
      INC <= '1';
      LOAD <= '0';
      
      -- check "00000001"
      wait for CLOCK_period;
      assert DATA_OUT = "00000001" report "Expected 00000001" severity ERROR;    

      -- check "00000010"
      wait for CLOCK_period;
      assert DATA_OUT = "00000010" report "Expected 00000010" severity ERROR;
      
      -- check "00000100"
      wait for CLOCK_period*2;
      assert DATA_OUT = "00000100" report "Expected 00000100" severity ERROR;
      
      -- check "00001000"
      wait for CLOCK_period*4;
      assert DATA_OUT = "00001000" report "Expected 00001000" severity ERROR;
      
      -- check "00010000"
      wait for CLOCK_period*8;
      assert DATA_OUT = "00010000" report "Expected 00010000" severity ERROR;
      
      -- check "00100000"
      wait for CLOCK_period*16;
      assert DATA_OUT = "00100000" report "Expected 00100000" severity ERROR;
      
      -- check "01000000"
      wait for CLOCK_period*32;
      assert DATA_OUT = "01000000" report "Expected 01000000" severity ERROR;
      
      -- check "10000000"
      wait for CLOCK_period*64;
      assert DATA_OUT = "10000000" report "Expected 10000000" severity ERROR;
      
      -- check "00000000"
      wait for CLOCK_period*128;
      assert DATA_OUT = "00000000" report "Expected 00000000" severity ERROR;
      
      -- check LOAD
      INC <= '0';
      LOAD <= '1';
      wait for CLOCK_period;
      assert DATA_OUT = "11111111" report "LOAD failed" severity ERROR;
      
      -- check OE
      OE <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "ZZZZZZZZ" report "OE failed" severity ERROR;
      
      wait;
   end process;

END;
