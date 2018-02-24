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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
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
      wait for CLOCK_period;
      assert DATA_OUT = "0000000000000000" report "RESET: failed" severity ERROR;
      
      report "RESET: completed" severity NOTE;
      
      --------------
      -- LOAD(-1) --
      --------------
      DATA_IN <= (others => '1');
      RESET <= '0';
      
      -- load into LSB
      LOAD_EN <= "10";
      wait for CLOCK_period;
      assert DATA_OUT = "0000000011111111" report "LOAD(-1): load into LSB failed" severity ERROR;
      
      -- make sure data persists
      LOAD_EN <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = "0000000011111111" report "LOAD(-1): LSB data non-persistent" severity ERROR;
      
      -- load into MSB
      LOAD_EN <= "11";
      wait for CLOCK_period;
      assert DATA_OUT = "1111111111111111" report "LOAD(-1): load into MSB failed" severity ERROR;
      
      -- make sure data persists
      LOAD_EN <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = "1111111111111111" report "LOAD(-1): MSB data non-persistent" severity ERROR;
      
      report "LOAD(-1): completed" severity NOTE;
      
      -------------
      -- LOAD(0) --
      -------------
      DATA_IN <= (others => '0');
      
      -- load into MSB
      LOAD_EN <= "11";
      wait for CLOCK_period;
      assert DATA_OUT = "0000000011111111" report "LOAD(0): load into MSB failed" severity ERROR;
      
      -- make sure data persists
      LOAD_EN <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = "0000000011111111" report "LOAD(0): MSB data non-persistent" severity ERROR;
      
      -- load into LSB
      LOAD_EN <= "10";
      wait for CLOCK_period;
      assert DATA_OUT = "0000000000000000" report "LOAD(0): load into LSB failed" severity ERROR;
      
      -- make sure data persists
      LOAD_EN <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = "0000000000000000" report "LOAD(0): LSB data non-persistent" severity ERROR;
      
      report "LOAD(0): completed" severity NOTE;
      
      report "All tests completed" severity NOTE;
      wait;
   end process;

END;
