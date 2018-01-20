--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   19:38:05 09/22/2017
-- Module Name:   C:/Shared/hdl/processor/alu_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: alu
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
USE ieee.std_logic_unsigned.ALL;
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT alu
    PORT(
         A_IN   : IN  std_logic_vector(3 downto 0);
         B_IN   : IN  std_logic_vector(3 downto 0);
         S_IN   : IN  std_logic_vector(2 downto 0);
         CYI    : IN  std_logic;
         Y_OUT  : OUT std_logic_vector(3 downto 0);
         FLAG_Z : OUT std_logic;
         FLAG_C : OUT std_logic;
         FLAG_S : OUT std_logic;
         FLAG_P : OUT std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A_IN : std_logic_vector(3 downto 0) := (others => '0');
   signal B_IN : std_logic_vector(3 downto 0) := (others => '0');
   signal S_IN : std_logic_vector(2 downto 0) := (others => '0');
   signal CYI  : std_logic := '0';

 	--Outputs
   signal Y_OUT  : std_logic_vector(3 downto 0);
   signal FLAG_Z : std_logic;
   signal FLAG_C : std_logic;
   signal FLAG_S : std_logic;
   signal FLAG_P : std_logic;
 
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          A_IN   => A_IN,
          B_IN   => B_IN,
          S_IN   => S_IN,
          CYI    => CYI,
          Y_OUT  => Y_OUT,
          FLAG_Z => FLAG_Z,
          FLAG_C => FLAG_C,
          FLAG_S => FLAG_S,
          FLAG_P => FLAG_P
        ); 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 10 clock cycles
      A_IN <= "1101";
      B_IN <= "0111";
      CYI <= '0';
      wait for CLOCK_period*10;

      -- 000 => A
      S_IN <= "000";
      wait for CLOCK_period;
      assert Y_OUT = A_IN report "000 : Y_OUT FAILED" severity ERROR;
      assert FLAG_Z = '0' report "000 : FLAG_Z FAILED" severity ERROR;
      assert FLAG_C = '0' report "000 : FLAG_C FAILED" severity ERROR;
      assert FLAG_S = '1' report "000 : FLAG_S FAILED" severity ERROR;
      assert FLAG_P = '1' report "000 : FLAGP FAILED" severity ERROR;
      
      -- 001 => A + 1
      S_IN <= "001";
      wait for CLOCK_period;
      assert Y_OUT = (A_IN + 1) report "001 : Y_OUT FAILED" severity ERROR;
      assert FLAG_Z = '0' report "001 : FLAG_Z FAILED" severity ERROR;
      assert FLAG_C = '0' report "001 : FLAG_C FAILED" severity ERROR;
      assert FLAG_S = '1' report "001 : FLAG_S FAILED" severity ERROR;
      assert FLAG_P = '1' report "001 : FLAGP FAILED" severity ERROR;
      
      -- 010 => A - 1
      S_IN <= "010";
      wait for CLOCK_period;
      assert Y_OUT = (A_IN - 1) report "010 : Y_OUT FAILED" severity ERROR;
      assert FLAG_Z = '0' report "010 : FLAG_Z FAILED" severity ERROR;
      assert FLAG_C = '0' report "010 : FLAG_C FAILED" severity ERROR;
      assert FLAG_S = '1' report "010 : FLAG_S FAILED" severity ERROR;
      assert FLAG_P = '0' report "010 : FLAGP FAILED" severity ERROR;
      
      -- 011 => A or B
      S_IN <= "011";
      wait for CLOCK_period;
      assert Y_OUT = (A_IN or B_IN) report "011 : Y_OUT FAILED" severity ERROR;
      assert FLAG_Z = '0' report "011 : FLAG_Z FAILED" severity ERROR;
      assert FLAG_C = '0' report "011 : FLAG_C FAILED" severity ERROR;
      assert FLAG_S = '1' report "011 : FLAG_S FAILED" severity ERROR;
      assert FLAG_P = '0' report "011 : FLAGP FAILED" severity ERROR;
      
      -- 100 => A and B
      S_IN <= "100";
      wait for CLOCK_period;
      assert Y_OUT = (A_IN and B_IN) report "100 : Y_OUT FAILED" severity ERROR;
      assert FLAG_Z = '0' report "100 : FLAG_Z FAILED" severity ERROR;
      assert FLAG_C = '0' report "100 : FLAG_C FAILED" severity ERROR;
      assert FLAG_S = '0' report "100 : FLAG_S FAILED" severity ERROR;
      assert FLAG_P = '0' report "100 : FLAGP FAILED" severity ERROR;
      
      -- 101 => A xor B
      S_IN <= "101";
      wait for CLOCK_period;
      assert Y_OUT = (A_IN xor B_IN) report "101 : Y_OUT FAILED" severity ERROR;
      assert FLAG_Z = '0' report "101 : FLAG_Z FAILED" severity ERROR;
      assert FLAG_C = '0' report "101 : FLAG_C FAILED" severity ERROR;
      assert FLAG_S = '1' report "101 : FLAG_S FAILED" severity ERROR;
      assert FLAG_P = '0' report "101 : FLAGP FAILED" severity ERROR;
      
      -- 110 => A + B + CYI
      CYI <= '1';
      S_IN <= "110";
      wait for CLOCK_period;
      assert Y_OUT = (A_IN + B_IN + CYI) report "110 : Y_OUT FAILED" severity ERROR;
      assert FLAG_Z = '0' report "110 : FLAG_Z FAILED" severity ERROR;
      assert FLAG_C = '1' report "110 : FLAG_C FAILED" severity ERROR;
      assert FLAG_S = '0' report "110 : FLAG_S FAILED" severity ERROR;
      assert FLAG_P = '0' report "110 : FLAGP FAILED" severity ERROR;
      
      -- 111 => A - B - CYI    1101 0111
      CYI <= '0';
      S_IN <= "111";
      wait for CLOCK_period;
      assert Y_OUT = (A_IN - B_IN - CYI) report "111 : Y_OUT FAILED" severity ERROR;
      assert FLAG_Z = '0' report "111 : FLAG_Z FAILED" severity ERROR;
      assert FLAG_C = '0' report "111 : FLAG_C FAILED" severity ERROR;
      assert FLAG_S = '0' report "111 : FLAG_S FAILED" severity ERROR;
      assert FLAG_P = '0' report "111 : FLAGP FAILED" severity ERROR;

      wait;
   end process;

END;
