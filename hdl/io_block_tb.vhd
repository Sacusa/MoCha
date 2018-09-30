--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   01:04:47 11/01/2017
-- Module Name:   C:/Shared/hdl/processor/io_block_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: io_block
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY io_block_tb IS
END io_block_tb;
 
ARCHITECTURE behavior OF io_block_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT io_block
    PORT(
         DATA_IN : IN  std_logic_vector(7 downto 0);
         DATA_LOAD : IN  std_logic;
         DIR_LOAD : IN  std_logic;
         CLOCK : IN  std_logic;
         DATA_OUT : OUT  std_logic_vector(7 downto 0);
         IO : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal DATA_LOAD : std_logic := '0';
   signal DIR_LOAD : std_logic := '0';
   signal CLOCK : std_logic := '0';

	--BiDirs
   signal IO : std_logic_vector(7 downto 0);

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: io_block PORT MAP (
          DATA_IN => DATA_IN,
          DATA_LOAD => DATA_LOAD,
          DIR_LOAD => DIR_LOAD,
          CLOCK => CLOCK,
          DATA_OUT => DATA_OUT,
          IO => IO
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
      IO <= (others => 'Z');
      wait for CLOCK_period;
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      
      -- output "00000000"
      DATA_IN <= "00000000";
      wait for CLOCK_period;
      assert IO = DATA_IN report "ERROR: Expected IO=00000000" severity ERROR;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;

      -- output "00000001"
      DATA_IN <= "00000001";
      wait for CLOCK_period;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- output "00000011"
      DATA_IN <= "00000011";
      wait for CLOCK_period;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- output "00000111"
      DATA_IN <= "00000111";
      wait for CLOCK_period;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- output "00001111"
      DATA_IN <= "00001111";
      wait for CLOCK_period;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- output "00011111"
      DATA_IN <= "00011111";
      wait for CLOCK_period;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- output "00111111"
      DATA_IN <= "00111111";
      wait for CLOCK_period;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- output "01111111"
      DATA_IN <= "01111111";
      wait for CLOCK_period;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- output "11111111"
      DATA_IN <= "11111111";
      wait for CLOCK_period;
      assert IO = DATA_IN
         report "ALL PINS OUTPUT failed : Expected IO = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -----------------
      -- All pins input
      -----------------
      DATA_IN <= (others => '0');
      DATA_LOAD <= '0';
      DIR_LOAD <= '1';
      wait for CLOCK_period;
      
      -- input "00000000"
      IO <= "00000000";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- input "00000001"
      IO <= "00000001";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- input "00000011"
      IO <= "00000011";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- input "00000111"
      IO <= "00000111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- input "00001111"
      IO <= "00001111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- input "00011111"
      IO <= "00011111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- input "00111111"
      IO <= "00111111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- input "01111111"
      IO <= "01111111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- input "11111111"
      IO <= "11111111";
      DIR_LOAD <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = IO
         report "ALL PINS INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO))) & " Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      ------------------------------------
      -- Four MSBs input, four LSBs output
      ------------------------------------
      DATA_IN <= "00001111";
      DATA_LOAD <= '0';
      DIR_LOAD <= '1';
      IO <= "0000ZZZZ";
      wait for CLOCK_period;
      
      -- write "0000" to both
      DATA_IN <= "00000000";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      IO <= "0000ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed: Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      assert IO = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed : Expected IO = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- write "0001" to both
      DATA_IN <= "00000001";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      IO <= "0001ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed: Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      assert IO = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed : Expected IO = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- write "0011" to both
      DATA_IN <= "00000011";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      IO <= "0011ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed: Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      assert IO = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed : Expected IO = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- write "0111" to both
      DATA_IN <= "00000111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      IO <= "0111ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed: Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      assert IO = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed : Expected IO = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      -- write "1111" to both
      DATA_IN <= "00001111";
      DATA_LOAD <= '1';
      DIR_LOAD <= '0';
      IO <= "1111ZZZZ";
      wait for CLOCK_period;
      assert DATA_OUT = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed: Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      assert IO = IO(7 downto 4) & DATA_IN(3 downto 0)
         report "MIXED IO failed : Expected IO = " &
            integer'image(to_integer(unsigned(IO(7 downto 4) & DATA_IN(3 downto 0)))) & " ; Received IO = " &
            integer'image(to_integer(unsigned(IO)))
         severity ERROR;
      
      report "All Tests Completed" severity NOTE;

      wait;
   end process;

END;
