--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:53:47 09/19/2017
-- Design Name:   
-- Module Name:   C:/Shared/hdl/processor/cs_tb.vhd
-- Project Name:  processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cs
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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
 
ENTITY cs_tb IS
END cs_tb;
 
ARCHITECTURE behavior OF cs_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT cs
    PORT(
         DATA_IN  : IN  std_logic_vector(7 downto 0);
         SCS      : IN  std_logic_vector(1 downto 0);
         DATA_OUT : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal SCS : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);
 
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cs PORT MAP (
          DATA_IN  => DATA_IN,
          SCS      => SCS,
          DATA_OUT => DATA_OUT
        ); 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 10 cycles.
      DATA_IN <= "10101010";
      wait for CLOCK_period*10;
      
      -- check pass
      SCS <= "00";
      wait for CLOCK_period;
      assert DATA_OUT = "10101010" report "Pass output (00) failed" severity ERROR;

      -- check complement
      SCS <= "01";
      wait for CLOCK_period;
      assert DATA_OUT = "01010101" report "Complement output (01) failed" severity ERROR;
      
      -- check left shift
      SCS <= "10";
      wait for CLOCK_period;
      assert DATA_OUT = "01010100" report "Left shift output (10) failed" severity ERROR;
      
      -- check right shift
      SCS <= "11";
      wait for CLOCK_period;
      assert DATA_OUT = "11010101" report "Right shift output (11) failed" severity ERROR;

      wait;
   end process;

END;
