--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   15:19:55 09/19/2017
-- Module Name:   C:/Shared/hdl/processor/sp_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: sp
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY sp_tb IS
END sp_tb;
 
ARCHITECTURE behavior OF sp_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sp
    PORT(
         DATA_IN : IN  std_logic_vector(7 downto 0);
         CLOCK : IN  std_logic;
         INC : IN  std_logic;
         DEC : IN  std_logic;
         LOAD : IN  std_logic_vector(1 downto 0);
         DATA_OUT : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal CLOCK : std_logic := '0';
   signal INC : std_logic := '0';
   signal DEC : std_logic := '0';
   signal LOAD : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal DATA_OUT : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   
   -- Expected values
   signal EXP_DATA_OUT : std_logic_vector(15 downto 0) := (others => '0');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sp PORT MAP (
          DATA_IN => DATA_IN,
          CLOCK => CLOCK,
          INC => INC,
          DEC => DEC,
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
      
      --------------------
      -- RESET : Load 0 --
      --------------------
      DATA_IN <= (others => '0');
      INC <= '0';
      DEC <= '0';
      EXP_DATA_OUT <= (others => '0');
      
      -- load into LSB
      LOAD <= "10";
      wait for CLOCK_period;
      assert DATA_OUT(7 downto 0) = EXP_DATA_OUT(7 downto 0)
         report "RESET LSB load failed : Expected DATA_OUT[7:0] = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT(7 downto 0)))) & " ; Received DATA_OUT[7:0] = " &
            integer'image(to_integer(unsigned(DATA_OUT(7 downto 0))))
         severity ERROR;
      
      -- load into MSB
      LOAD <= "11";
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "RESET MSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- verify the entire output after 10 cycles
      LOAD <= "00";
      wait for CLOCK_period*10;
      assert DATA_OUT = EXP_DATA_OUT
         report "RESET final check failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      ----------------------------------
      -- INC: Increment till overflow --
      ----------------------------------
      INC <= '1';
      DEC <= '0';
      LOAD <= "00";
      EXP_DATA_OUT <= (others => '0');
      
      for b in 0 to 65535 loop
         EXP_DATA_OUT <= std_logic_vector(unsigned(EXP_DATA_OUT) + 1);
         wait for CLOCK_period;
         assert DATA_OUT = EXP_DATA_OUT
            report "INC failed at b = " &
               integer'image(b) & " : Expected DATA_OUT = " &
               integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " Received DATA_OUT = " &
               integer'image(to_integer(unsigned(DATA_OUT)))
            severity ERROR;
      end loop;
      
      ----------------------------------
      -- DEC: Decrement till overflow --
      ----------------------------------
      INC <= '0';
      DEC <= '1';
      LOAD <= "00";
      EXP_DATA_OUT <= (others => '0');
      
      for b in 0 to 65535 loop
         EXP_DATA_OUT <= std_logic_vector(unsigned(EXP_DATA_OUT) - 1);
         wait for CLOCK_period;
         assert DATA_OUT = EXP_DATA_OUT
            report "DEC failed at b = " &
               integer'image(b) & " : Expected DATA_OUT = " &
               integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " Received DATA_OUT = " &
               integer'image(to_integer(unsigned(DATA_OUT)))
            severity ERROR;
      end loop;
      
      -----------------------
      -- LOAD: Load 0xffff --
      -----------------------
      DATA_IN <= (others => '1');
      INC <= '0';
      DEC <= '0';
      
      -- load into MSB
      LOAD <= "11";
      EXP_DATA_OUT <= "1111111100000000";
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0xffff) MSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- load into LSB
      LOAD <= "10";
      EXP_DATA_OUT <= (others => '1');
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0xffff) LSB load failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- verify the entire output after 10 cycles
      LOAD <= "00";
      wait for CLOCK_period;
      assert DATA_OUT = EXP_DATA_OUT
         report "LOAD(0xffff) final check failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(EXP_DATA_OUT))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      report "All tests completed" severity NOTE;
      wait;
   end process;

END;
