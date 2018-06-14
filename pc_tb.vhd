--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   11:51:16 06/14/2018
-- Module Name:   C:/Shared/hdl/processor/pc_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: pc
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY pc_tb IS
END pc_tb;
 
ARCHITECTURE behavior OF pc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pc
    PORT(
         DATA_IN : IN  std_logic_vector(7 downto 0);
         CLOCK : IN  std_logic;
         INC : IN  std_logic;
         LOAD : IN  std_logic_vector(1 downto 0);
         DATA_OUT : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal CLOCK : std_logic := '0';
   signal INC : std_logic := '0';
   signal LOAD : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal DATA_OUT : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   
   -- Expected values
   signal EXP_DATA_OUT : std_logic_vector(15 downto 0) := (others => '0');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pc PORT MAP (
          DATA_IN => DATA_IN,
          CLOCK => CLOCK,
          INC => INC,
          LOAD => LOAD,
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
      -------------------
      -- INIT : Load 0 --
      -------------------
      DATA_IN <= (others => '0');
      INC <= '0';
      EXP_DATA_OUT <= (others => '0');
      
      -- load 0 into lower order byte
      LOAD <= "10";
      wait for CLOCK_period;
      assert DATA_OUT(7 downto 0) = EXP_DATA_OUT(7 downto 0)
         report "INIT LSB load failed : Expected DATA_OUT[7:0] = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT(7 downto 0)))) & " ; Received DATA_OUT[7:0] = " &
            integer'image(to_integer(unsigned(DATA_OUT(7 downto 0))))
         severity ERROR;
      
      -- load 0 into higher order byte
      LOAD <= "11";
      wait for CLOCK_period;
      assert DATA_OUT(15 downto 8) = EXP_DATA_OUT(15 downto 8)
         report "INIT MSB load failed : Expected DATA_OUT[15:8] = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT(15 downto 8)))) & " ; Received DATA_OUT[15:8] = " &
            integer'image(to_integer(unsigned(DATA_OUT(15 downto 8))))
         severity ERROR;
      
      -- verify complete value
      LOAD <= "00";
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "INIT Final failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      ------------------------------------------
      -- INC : Increase PC until it overflows --
      ------------------------------------------
      
      INC <= '1';
      
      for b in 0 to 65536 loop
         EXP_DATA_OUT <= std_logic_vector(unsigned(EXP_DATA_OUT) + 1);
         wait for CLOCK_period;
         assert DATA_OUT = EXP_DATA_OUT
            report "INC failed at b = " &
               integer'image(b) & " : Expected DATA_OUT = " &
               integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " Received DATA_OUT = " &
               integer'image(to_integer(unsigned(DATA_OUT)))
            severity ERROR;
      end loop;
      
      -----------------------------------
      -- PWL : Piece-wise Loading Test --
      -----------------------------------
      DATA_IN <= (others => '1');
      INC <= '0';
      
      -- load lower order byte
      LOAD <= "10";
      EXP_DATA_OUT <= "0000000011111111";
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "PWL LSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- load higher order byte
      LOAD <= "11";
      EXP_DATA_OUT <= (others => '1');
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "PWL MSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      report "All tests completed" severity NOTE;

      wait;
   end process;

END;
