--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:04:47 11/01/2017
-- Design Name:   
-- Module Name:   C:/Shared/hdl/processor/gpio_block_tb.vhd
-- Project Name:  processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: gpio_block
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY gpio_block_tb IS
END gpio_block_tb;
 
ARCHITECTURE behavior OF gpio_block_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT gpio_block
    PORT(
         DATA_IN   : IN    std_logic_vector(7 downto 0);
         DATA_LOAD : IN    std_logic;
         DIR_LOAD  : IN    std_logic;
         CLOCK     : IN    std_logic;
         DATA_OUT  : OUT   std_logic_vector(7 downto 0);
         GPIO      : INOUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal DATA_LOAD : std_logic := '0';
   signal DIR_LOAD : std_logic := '0';
   signal CLOCK : std_logic := '0';

	--BiDirs
   signal GPIO : std_logic_vector(7 downto 0);

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: gpio_block PORT MAP (
          DATA_IN => DATA_IN,
          DATA_LOAD => DATA_LOAD,
          DIR_LOAD => DIR_LOAD,
          CLOCK => CLOCK,
          DATA_OUT => DATA_OUT,
          GPIO => GPIO
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
      ------------------
      -- All pins output
      ------------------
      DATA_IN <= (others => '1');
      DATA_LOAD <= '0';
      DIR_LOAD <= '1';
      GPIO <= (others => 'Z');
      wait for CLOCK_period;
      
      -- output "00000000"
      DATA_IN <= "00000000";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "00000000" report "ERROR: Expected GPIO=00000000" severity ERROR;

      -- output "00000001"
      DATA_IN <= "00000001";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "00000001" report "ERROR: Expected GPIO=00000001" severity ERROR;
      
      -- output "00000011"
      DATA_IN <= "00000011";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "00000011" report "ERROR: Expected GPIO=00000011" severity ERROR;
      
      -- output "00000111"
      DATA_IN <= "00000111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "00000111" report "ERROR: Expected GPIO=00000111" severity ERROR;
      
      -- output "00001111"
      DATA_IN <= "00001111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "00001111" report "ERROR: Expected GPIO=00001111" severity ERROR;
      
      -- output "00011111"
      DATA_IN <= "00011111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "00011111" report "ERROR: Expected GPIO=00011111" severity ERROR;
      
      -- output "00111111"
      DATA_IN <= "00111111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "00111111" report "ERROR: Expected GPIO=00111111" severity ERROR;
      
      -- output "01111111"
      DATA_IN <= "01111111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "01111111" report "ERROR: Expected GPIO=01111111" severity ERROR;
      
      -- output "11111111"
      DATA_IN <= "11111111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert GPIO = "11111111" report "ERROR: Expected GPIO=11111111" severity ERROR;
      
      -----------------
      -- All pins input
      -----------------
      DATA_IN <= (others => '0');
      DATA_LOAD <= '0';
      DIR_LOAD <= '1';
      wait for CLOCK_period;
      
      -- input "00000000"
      GPIO <= "00000000";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "00000000" report "ERROR: Expected DATA_OUT=00000000" severity ERROR;
      
      -- input "00000001"
      GPIO <= "00000001";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "00000001" report "ERROR: Expected DATA_OUT=00000001" severity ERROR;
      
      -- input "00000011"
      GPIO <= "00000011";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "00000011" report "ERROR: Expected DATA_OUT=00000011" severity ERROR;
      
      -- input "00000111"
      GPIO <= "00000111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "00000111" report "ERROR: Expected DATA_OUT=00000111" severity ERROR;
      
      -- input "00001111"
      GPIO <= "00001111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "00001111" report "ERROR: Expected DATA_OUT=00001111" severity ERROR;
      
      -- input "00011111"
      GPIO <= "00011111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "00011111" report "ERROR: Expected DATA_OUT=00011111" severity ERROR;
      
      -- input "00111111"
      GPIO <= "00111111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "00111111" report "ERROR: Expected DATA_OUT=00111111" severity ERROR;
      
      -- input "01111111"
      GPIO <= "01111111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "01111111" report "ERROR: Expected DATA_OUT=01111111" severity ERROR;
      
      -- input "11111111"
      GPIO <= "11111111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "11111111" report "ERROR: Expected DATA_OUT=11111111" severity ERROR;
      
      ------------------------------------
      -- Four MSBs input, four LSBs output
      ------------------------------------
      DATA_IN <= "00001111";
      DATA_LOAD <= '0';
      DIR_LOAD <= '1';
      GPIO <= "0000ZZZZ";
      wait for CLOCK_period;
      
      -- write "0000" to both
      DATA_IN <= "00000000";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      GPIO <= "0000ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = "00000000" report "ERROR: Expected DATA_OUT=0000" severity ERROR;
      assert GPIO = "00000000" report "ERROR: Expected GPIO=0000" severity ERROR;
      
      -- write "0001" to both
      DATA_IN <= "00000001";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      GPIO <= "0001ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = "00010001" report "ERROR: Expected DATA_OUT=0001" severity ERROR;
      assert GPIO = "00010001" report "ERROR: Expected GPIO=0001" severity ERROR;
      
      -- write "0011" to both
      DATA_IN <= "00000011";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      GPIO <= "0011ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = "00110011" report "ERROR: Expected DATA_OUT=0011" severity ERROR;
      assert GPIO = "00110011" report "ERROR: Expected GPIO=0011" severity ERROR;
      
      -- write "0111" to both
      DATA_IN <= "00000111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      GPIO <= "0111ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = "01110111" report "ERROR: Expected DATA_OUT=0111" severity ERROR;
      assert GPIO = "01110111" report "ERROR: Expected GPIO=0111" severity ERROR;
      
      -- write "1111" to both
      DATA_IN <= "00001111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      GPIO <= "1111ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = "11111111" report "ERROR: Expected DATA_OUT=1111" severity ERROR;
      assert GPIO = "11111111" report "ERROR: Expected GPIO=1111" severity ERROR;

      wait;
   end process;

END;
