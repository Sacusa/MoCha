--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   15:19:55 09/19/2017
-- Module Name:   C:/Shared/hdl/processor/sp_tb.vhd
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
 
ENTITY sp_tb IS
END sp_tb;
 
ARCHITECTURE behavior OF sp_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT sp
    PORT(
         DATA_IN  : IN  std_logic_vector(7 downto 0);
         CLOCK    : IN  std_logic;
         RESET    : IN  std_logic;
         INC      : IN  std_logic;
         DEC      : IN  std_logic;
         LOAD     : IN  std_logic;
         OE       : IN  std_logic;
         DATA_OUT : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal CLOCK   : std_logic := '0';
   signal RESET   : std_logic := '0';
   signal INC     : std_logic := '0';
   signal DEC     : std_logic := '0';
   signal LOAD    : std_logic := '0';
   signal OE      : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sp PORT MAP (
          DATA_IN  => DATA_IN,
          CLOCK    => CLOCK,
          RESET    => RESET,
          INC      => INC,
          DEC      => DEC,
          LOAD     => LOAD,
          OE       => OE,
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
      -- hold reset state for 10 cycles.
      DATA_IN <= "11111111";
      RESET <= '1';
      INC <= '0';
      DEC <= '0';
      LOAD <= '0';
      OE <= '1';
      wait for CLOCK_period*10;

      -- check RESET
      assert DATA_OUT = "00000000" report "RESET failed" severity ERROR;
      
      -- check OE
      OE <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "ZZZZZZZZ" report "OE failed" severity ERROR;
      
      ----------------------------------
      -- Increment until we reach "0000"
      ----------------------------------
      RESET <= '0';
      INC <= '1';
      DEC <= '0';
      LOAD <= '0';
      OE <= '1';
      
      -- check "00000001"
      wait for CLOCK_period;
      assert DATA_OUT = "00000001" report "INC FAILED: Expected 00000001" severity ERROR;
      
      -- check "00000010"
      wait for CLOCK_period;
      assert DATA_OUT = "00000010" report "INC FAILED: Expected 00000010" severity ERROR;
      
      -- check "00000100"
      wait for CLOCK_period*2;
      assert DATA_OUT = "00000100" report "INC FAILED: Expected 00000100" severity ERROR;
      
      -- check "00001000"
      wait for CLOCK_period*4;
      assert DATA_OUT = "00001000" report "INC FAILED: Expected 00001000" severity ERROR;
      
      -- check "00010000"
      wait for CLOCK_period*8;
      assert DATA_OUT = "00010000" report "INC FAILED: Expected 00010000" severity ERROR;
      
      -- check "00100000"
      wait for CLOCK_period*16;
      assert DATA_OUT = "00100000" report "INC FAILED: Expected 00100000" severity ERROR;
      
      -- check "01000000"
      wait for CLOCK_period*32;
      assert DATA_OUT = "01000000" report "INC FAILED: Expected 01000000" severity ERROR;
      
      -- check "10000000"
      wait for CLOCK_period*64;
      assert DATA_OUT = "10000000" report "INC FAILED: Expected 10000000" severity ERROR;
      
      -- check "00000000"
      wait for CLOCK_period*128;
      assert DATA_OUT = "00000000" report "INC FAILED: Expected 00000000" severity ERROR;
      
      ----------------------------------
      -- Decrement until we reach "0000"
      ----------------------------------
      RESET <= '0';
      INC <= '0';
      DEC <= '1';
      LOAD <= '0';
      OE <= '1';
      
      -- check "10000000"
      wait for CLOCK_period*128;
      assert DATA_OUT = "10000000" report "DEC FAILED: Expected 10000000" severity ERROR;
      
      -- check "01000000"
      wait for CLOCK_period*64;
      assert DATA_OUT = "01000000" report "DEC FAILED: Expected 01000000" severity ERROR;
      
      -- check "00100000"
      wait for CLOCK_period*32;
      assert DATA_OUT = "00100000" report "DEC FAILED: Expected 00100000" severity ERROR;
      
      -- check "00010000"
      wait for CLOCK_period*16;
      assert DATA_OUT = "00010000" report "DEC FAILED: Expected 00010000" severity ERROR;
      
      -- check "00001000"
      wait for CLOCK_period*8;
      assert DATA_OUT = "00001000" report "DEC FAILED: Expected 00001000" severity ERROR;
      
      -- check "00000100"
      wait for CLOCK_period*4;
      assert DATA_OUT = "00000100" report "DEC FAILED: Expected 00000100" severity ERROR;
      
      -- check "00000010"
      wait for CLOCK_period*2;
      assert DATA_OUT = "00000010" report "DEC FAILED: Expected 00000010" severity ERROR;
      
      -- check "00000001"
      wait for CLOCK_period;
      assert DATA_OUT = "00000001" report "DEC FAILED: Expected 00000001" severity ERROR;
      
      -- check "00000000"
      wait for CLOCK_period;
      assert DATA_OUT = "00000000" report "DEC FAILED: Expected 00000000" severity ERROR;
      
      -- check LOAD
      RESET <= '0';
      INC <= '0';
      DEC <= '0';
      LOAD <= '1';
      OE <= '1';
      wait for CLOCK_period;
      assert DATA_OUT = "11111111" report "LOAD failed" severity ERROR;
      
      -- check OE
      OE <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "ZZZZZZZZ" report "OE failed" severity ERROR;

      wait;
   end process;

END;
