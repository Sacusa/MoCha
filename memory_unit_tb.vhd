--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:27:04 11/02/2017
-- Design Name:   
-- Module Name:   C:/Shared/hdl/processor/memory_unit_tb.vhd
-- Project Name:  processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: memory_unit
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
 
ENTITY memory_unit_tb IS
END memory_unit_tb;
 
ARCHITECTURE behavior OF memory_unit_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memory_unit
    PORT(
         CLOCK : IN  std_logic;
         WEA : IN  std_logic;
         ADDRESS : IN  std_logic_vector(7 downto 0);
         DATA_IN : IN  std_logic_vector(7 downto 0);
         DATA_OUT : OUT  std_logic_vector(7 downto 0);
         GPIO_0 : INOUT  std_logic_vector(7 downto 0);
         GPIO_1 : INOUT  std_logic_vector(7 downto 0);
         GPIO_2 : INOUT  std_logic_vector(7 downto 0);
         GPIO_3 : INOUT  std_logic_vector(7 downto 0);
         GPIO_4 : INOUT  std_logic_vector(7 downto 0);
         GPIO_5 : INOUT  std_logic_vector(7 downto 0);
         GPIO_6 : INOUT  std_logic_vector(7 downto 0);
         GPIO_7 : INOUT  std_logic_vector(7 downto 0);
         GPIO_8 : INOUT  std_logic_vector(7 downto 0);
         GPIO_9 : INOUT  std_logic_vector(7 downto 0);
         GPIO_10 : INOUT  std_logic_vector(7 downto 0);
         GPIO_11 : INOUT  std_logic_vector(7 downto 0);
         GPIO_12 : INOUT  std_logic_vector(7 downto 0);
         GPIO_13 : INOUT  std_logic_vector(7 downto 0);
         GPIO_14 : INOUT  std_logic_vector(7 downto 0);
         GPIO_15 : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK : std_logic := '0';
   signal WEA : std_logic := '0';
   signal ADDRESS : std_logic_vector(7 downto 0) := (others => '0');
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');

	--BiDirs
   signal GPIO_0 : std_logic_vector(7 downto 0);
   signal GPIO_1 : std_logic_vector(7 downto 0);
   signal GPIO_2 : std_logic_vector(7 downto 0);
   signal GPIO_3 : std_logic_vector(7 downto 0);
   signal GPIO_4 : std_logic_vector(7 downto 0);
   signal GPIO_5 : std_logic_vector(7 downto 0);
   signal GPIO_6 : std_logic_vector(7 downto 0);
   signal GPIO_7 : std_logic_vector(7 downto 0);
   signal GPIO_8 : std_logic_vector(7 downto 0);
   signal GPIO_9 : std_logic_vector(7 downto 0);
   signal GPIO_10 : std_logic_vector(7 downto 0);
   signal GPIO_11 : std_logic_vector(7 downto 0);
   signal GPIO_12 : std_logic_vector(7 downto 0);
   signal GPIO_13 : std_logic_vector(7 downto 0);
   signal GPIO_14 : std_logic_vector(7 downto 0);
   signal GPIO_15 : std_logic_vector(7 downto 0);

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory_unit PORT MAP (
          CLOCK => CLOCK,
          WEA => WEA,
          ADDRESS => ADDRESS,
          DATA_IN => DATA_IN,
          DATA_OUT => DATA_OUT,
          GPIO_0 => GPIO_0,
          GPIO_1 => GPIO_1,
          GPIO_2 => GPIO_2,
          GPIO_3 => GPIO_3,
          GPIO_4 => GPIO_4,
          GPIO_5 => GPIO_5,
          GPIO_6 => GPIO_6,
          GPIO_7 => GPIO_7,
          GPIO_8 => GPIO_8,
          GPIO_9 => GPIO_9,
          GPIO_10 => GPIO_10,
          GPIO_11 => GPIO_11,
          GPIO_12 => GPIO_12,
          GPIO_13 => GPIO_13,
          GPIO_14 => GPIO_14,
          GPIO_15 => GPIO_15
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
      ---------------------------------------------------------------
      -- Sequentially set all GPIOs to output and verify their values
      ---------------------------------------------------------------
      GPIO_0  <= (others => 'Z');
      GPIO_1  <= (others => 'Z');
      GPIO_2  <= (others => 'Z');
      GPIO_3  <= (others => 'Z');
      GPIO_4  <= (others => 'Z');
      GPIO_5  <= (others => 'Z');
      GPIO_6  <= (others => 'Z');
      GPIO_7  <= (others => 'Z');
      GPIO_8  <= (others => 'Z');
      GPIO_9  <= (others => 'Z');
      GPIO_10 <= (others => 'Z');
      GPIO_11 <= (others => 'Z');
      GPIO_12 <= (others => 'Z');
      GPIO_13 <= (others => 'Z');
      GPIO_14 <= (others => 'Z');
      GPIO_15 <= (others => 'Z');
      WEA <= '1';      
      
      -- GPIO 0
      ADDRESS <= "11110000";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11100000";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_0 = DATA_IN report "Invalid GPIO_0 output" severity ERROR;
      
      -- GPIO_1
      ADDRESS <= "11110001";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11100001";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_1 = DATA_IN report "Invalid GPIO_1 output" severity ERROR;
      
      -- GPIO_2
      ADDRESS <= "11110010";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11100010";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_2 = DATA_IN report "Invalid GPIO_2 output" severity ERROR;
      
      -- GPIO_3
      ADDRESS <= "11110011";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11100011";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_3 = DATA_IN report "Invalid GPIO_3 output" severity ERROR;
      
      -- GPIO_4
      ADDRESS <= "11110100";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11100100";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_4 = DATA_IN report "Invalid GPIO_4 output" severity ERROR;
      
      -- GPIO_5
      ADDRESS <= "11110101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11100101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_5 = DATA_IN report "Invalid GPIO_5 output" severity ERROR;
      
      -- GPIO_6
      ADDRESS <= "11110110";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11100110";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_6 = DATA_IN report "Invalid GPIO_6 output" severity ERROR;
      
      -- GPIO_7
      ADDRESS <= "11110111";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11100111";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_7 = DATA_IN report "Invalid GPIO_7 output" severity ERROR;
      
      -- GPIO_8
      ADDRESS <= "11111000";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11101000";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_8 = DATA_IN report "Invalid GPIO_8 output" severity ERROR;
      
      -- GPIO_9
      ADDRESS <= "11111001";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11101001";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_9 = DATA_IN report "Invalid GPIO_9 output" severity ERROR;
      
      -- GPIO_10
      ADDRESS <= "11111010";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11101010";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_10 = DATA_IN report "Invalid GPIO_10 output" severity ERROR;
      
      -- GPIO_11
      ADDRESS <= "11111011";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11101011";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_11 = DATA_IN report "Invalid GPIO_11 output" severity ERROR;
      
      -- GPIO_12
      ADDRESS <= "11111100";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11101100";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_12 = DATA_IN report "Invalid GPIO_12 output" severity ERROR;
      
      -- GPIO_13
      ADDRESS <= "11111101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11101101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_13 = DATA_IN report "Invalid GPIO_13 output" severity ERROR;
      
      -- GPIO_14
      ADDRESS <= "11111110";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11101110";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_14 = DATA_IN report "Invalid GPIO_14 output" severity ERROR;
      
      -- GPIO_15
      ADDRESS <= "11111111";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11101111";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert GPIO_15 = DATA_IN report "Invalid GPIO_15 output" severity ERROR;
      
      
      --------------------------------------------------------------
      -- Sequentially set all GPIOs to input and verify their values
      --------------------------------------------------------------
      
      -- GPIO_0
      WEA <= '1';
      ADDRESS <= "11110000";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11100000";
      GPIO_0 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_0 report "Invalid DATA_OUT for GPIO_0" severity ERROR;
      
      -- GPIO_1
      WEA <= '1';
      ADDRESS <= "11110001";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '1';
      ADDRESS <= "11100001";
      GPIO_1 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_1 report "Invalid DATA_OUT for GPIO_1" severity ERROR;
      
      -- GPIO_2
      WEA <= '1';
      ADDRESS <= "11110010";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11100010";
      GPIO_2 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_2 report "Invalid DATA_OUT for GPIO_2" severity ERROR;
      
      -- GPIO_3
      WEA <= '1';
      ADDRESS <= "11110011";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '1';
      ADDRESS <= "11100011";
      GPIO_3 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_3 report "Invalid DATA_OUT for GPIO_3" severity ERROR;
      
      -- GPIO_4
      WEA <= '1';
      ADDRESS <= "11110100";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11100100";
      GPIO_4 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_4 report "Invalid DATA_OUT for GPIO_4" severity ERROR;
      
      -- GPIO_5
      WEA <= '1';
      ADDRESS <= "11110101";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '1';
      ADDRESS <= "11100101";
      GPIO_5 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_5 report "Invalid DATA_OUT for GPIO_5" severity ERROR;
      
      -- GPIO_6
      WEA <= '1';
      ADDRESS <= "11110110";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11100110";
      GPIO_6 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_6 report "Invalid DATA_OUT for GPIO_6" severity ERROR;
      
      -- GPIO_7
      WEA <= '1';
      ADDRESS <= "11110111";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '1';
      ADDRESS <= "11100111";
      GPIO_7 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_7 report "Invalid DATA_OUT for GPIO_7" severity ERROR;
      
      -- GPIO_8
      WEA <= '1';
      ADDRESS <= "11111000";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11101000";
      GPIO_8 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_8 report "Invalid DATA_OUT for GPIO_8" severity ERROR;
      
      -- GPIO_9
      WEA <= '1';
      ADDRESS <= "11111001";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '1';
      ADDRESS <= "11101001";
      GPIO_9 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_9 report "Invalid DATA_OUT for GPIO_9" severity ERROR;
      
      -- GPIO_10
      WEA <= '1';
      ADDRESS <= "11111010";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11101010";
      GPIO_10 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_10 report "Invalid DATA_OUT for GPIO_10" severity ERROR;
      
      -- GPIO_11
      WEA <= '1';
      ADDRESS <= "11111011";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '1';
      ADDRESS <= "11101011";
      GPIO_11 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_11 report "Invalid DATA_OUT for GPIO_11" severity ERROR;
      
      -- GPIO_12
      WEA <= '1';
      ADDRESS <= "11111100";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11101100";
      GPIO_12 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_12 report "Invalid DATA_OUT for GPIO_12" severity ERROR;
      
      -- GPIO_13
      WEA <= '1';
      ADDRESS <= "11111101";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '1';
      ADDRESS <= "11101101";
      GPIO_13 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_13 report "Invalid DATA_OUT for GPIO_13" severity ERROR;
      
      -- GPIO_14
      WEA <= '1';
      ADDRESS <= "11111110";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11101110";
      GPIO_14 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_14 report "Invalid DATA_OUT for GPIO_14" severity ERROR;
      
      -- GPIO_15
      WEA <= '1';
      ADDRESS <= "11111111";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '1';
      ADDRESS <= "11101111";
      GPIO_15 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = GPIO_15 report "Invalid DATA_OUT for GPIO_15" severity ERROR;
      
      
      -------------------
      -- Test main memory
      -------------------
      
      -- test "000-----"
      WEA <= '1';
      ADDRESS <= "00010101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN report "Invalid memory output at 000-----" severity ERROR;
      
      -- test "001-----"
      WEA <= '1';
      ADDRESS <= "00110101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN report "Invalid memory output at 001-----" severity ERROR;
      
      -- test "010-----"
      WEA <= '1';
      ADDRESS <= "01010101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN report "Invalid memory output at 010-----" severity ERROR;
      
      -- test "011-----"
      WEA <= '1';
      ADDRESS <= "01110101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN report "Invalid memory output at 011-----" severity ERROR;
      
      -- test "100-----"
      WEA <= '1';
      ADDRESS <= "10010101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN report "Invalid memory output at 100-----" severity ERROR;
      
      -- test "101-----"
      WEA <= '1';
      ADDRESS <= "10110101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN report "Invalid memory output at 101-----" severity ERROR;
      
      -- test "110-----"
      WEA <= '1';
      ADDRESS <= "11010101";
      DATA_IN <= (others => '1');
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN report "Invalid memory output at 110-----" severity ERROR;
      
      wait;
   end process;

END;
