--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   11:02:28 09/01/2017
-- Module Name:   C:/Shared/hdl/processor/processor_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
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
 
ENTITY processor_tb IS
END processor_tb;
 
ARCHITECTURE behavior OF processor_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT processor
    PORT(
         DATA_IN : IN  std_logic_vector(3 downto 0);
         ALU_FUN : IN  std_logic_vector(3 downto 0);
         DATA_EN : IN  std_logic;
         OP_A_EN : IN  std_logic;
         OUT_EN : IN  std_logic;
         CLOCK : IN  std_logic;
         DATA_OUT : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(3 downto 0) := (others => '0');
   signal ALU_FUN : std_logic_vector(3 downto 0) := (others => '0');
   signal DATA_EN : std_logic := '0';
   signal OP_A_EN : std_logic := '0';
   signal OUT_EN : std_logic := '0';
   signal CLOCK : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   
   signal OP_A, OP_B : std_logic_vector(3 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: processor PORT MAP (
          DATA_IN => DATA_IN,
          ALU_FUN => ALU_FUN,
          DATA_EN => DATA_EN,
          OP_A_EN => OP_A_EN,
          OUT_EN => OUT_EN,
          CLOCK => CLOCK,
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
      OP_A <= "1100";
      OP_B <= "0110";
      wait for CLOCK_period*10;

      -- Testing XOR here
      DATA_IN <= OP_A;
      DATA_EN <= '1';
      OP_A_EN <= '1';
      OUT_EN <= '0';
      wait for CLOCK_period;
      DATA_IN <= OP_B;
      ALU_FUN <= "0110";
      OP_A_EN <= '0';
      wait for CLOCK_period;
      DATA_EN <= '0';
      OUT_EN <= '1';
      wait for CLOCK_period/2;
      assert DATA_OUT = "1010" report "ERROR: at F = 0110" severity ERROR;

      wait;
   end process;

END;
