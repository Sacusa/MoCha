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
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT alu
    PORT(
         A_IN   : IN  std_logic_vector(7 downto 0);
         B_IN   : IN  std_logic_vector(7 downto 0);
         S_IN   : IN  std_logic_vector(2 downto 0);
         CYI    : IN  std_logic;
         Y_OUT  : OUT std_logic_vector(7 downto 0);
         FLAG_Z : OUT std_logic;
         FLAG_C : OUT std_logic;
         FLAG_S : OUT std_logic;
         FLAG_P : OUT std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal B_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal S_IN : std_logic_vector(2 downto 0) := (others => '0');
   signal CYI  : std_logic := '0';

 	--Outputs
   signal Y_OUT  : std_logic_vector(7 downto 0);
   signal FLAG_Z : std_logic;
   signal FLAG_C : std_logic;
   signal FLAG_S : std_logic;
   signal FLAG_P : std_logic;
 
   constant CLOCK_period : time := 10 ns;
   
   signal EXP_Y_OUT  : std_logic_vector(7 downto 0);
   signal EXP_FLAG_Z : std_logic;
   signal EXP_FLAG_C : std_logic;
   signal EXP_FLAG_S : std_logic;
   signal EXP_FLAG_P : std_logic;
   
   -- for carry detection in sum
   signal EXP_Y_OUT_EXTENDED : std_logic_vector(8 downto 0);
 
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
      A_IN <= "11011101";
      B_IN <= "01110101";
      CYI <= '0';
      wait for CLOCK_period*10;

      -- 000 => A
      S_IN <= "000";
      EXP_Y_OUT <= A_IN;
      wait for CLOCK_period;
      if (EXP_Y_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= '0';
      EXP_FLAG_S <= EXP_Y_OUT(7);
      EXP_FLAG_P <= not(EXP_Y_OUT(0) xor EXP_Y_OUT(1) xor EXP_Y_OUT(2) xor
                        EXP_Y_OUT(3) xor EXP_Y_OUT(4) xor EXP_Y_OUT(5) xor
                        EXP_Y_OUT(6) xor EXP_Y_OUT(7));
      wait for CLOCK_period;
      
      assert Y_OUT = EXP_Y_OUT
         report integer'image(to_integer(unsigned(S_IN))) & " : Y_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_Y_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(Y_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " ; Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " ; Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " ; Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " ; Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- 001 => A + 1
      S_IN <= "001";
      EXP_Y_OUT <= (A_IN + 1);
      wait for CLOCK_period;
      if (EXP_Y_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
         EXP_FLAG_C <= '1';
      else
         EXP_FLAG_Z <= '0';
         EXP_FLAG_C <= '0';
      end if;
      EXP_FLAG_S <= EXP_Y_OUT(7);
      EXP_FLAG_P <= not(EXP_Y_OUT(0) xor EXP_Y_OUT(1) xor EXP_Y_OUT(2) xor
                        EXP_Y_OUT(3) xor EXP_Y_OUT(4) xor EXP_Y_OUT(5) xor
                        EXP_Y_OUT(6) xor EXP_Y_OUT(7));
      wait for CLOCK_period;
      
      assert Y_OUT = EXP_Y_OUT
         report integer'image(to_integer(unsigned(S_IN))) & " : Y_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_Y_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(Y_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " ; Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " ; Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " ; Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " ; Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- 010 => A - 1
      S_IN <= "010";
      EXP_Y_OUT <= (A_IN - 1);
      wait for CLOCK_period;
      if (EXP_Y_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= '0';
      EXP_FLAG_S <= EXP_Y_OUT(7);
      EXP_FLAG_P <= not(EXP_Y_OUT(0) xor EXP_Y_OUT(1) xor EXP_Y_OUT(2) xor
                        EXP_Y_OUT(3) xor EXP_Y_OUT(4) xor EXP_Y_OUT(5) xor
                        EXP_Y_OUT(6) xor EXP_Y_OUT(7));
      wait for CLOCK_period;
      
      assert Y_OUT = EXP_Y_OUT
         report integer'image(to_integer(unsigned(S_IN))) & " : Y_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_Y_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(Y_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " ; Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " ; Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " ; Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " ; Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- 011 => A or B
      S_IN <= "011";
      EXP_Y_OUT <= (A_IN or B_IN);
      wait for CLOCK_period;
      if (EXP_Y_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= '0';
      EXP_FLAG_S <= EXP_Y_OUT(7);
      EXP_FLAG_P <= not(EXP_Y_OUT(0) xor EXP_Y_OUT(1) xor EXP_Y_OUT(2) xor
                        EXP_Y_OUT(3) xor EXP_Y_OUT(4) xor EXP_Y_OUT(5) xor
                        EXP_Y_OUT(6) xor EXP_Y_OUT(7));
      wait for CLOCK_period;
      
      assert Y_OUT = EXP_Y_OUT
         report integer'image(to_integer(unsigned(S_IN))) & " : Y_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_Y_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(Y_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " ; Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " ; Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " ; Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " ; Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- 100 => A and B
      S_IN <= "100";
      EXP_Y_OUT <= (A_IN and B_IN);
      wait for CLOCK_period;
      if (EXP_Y_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= '0';
      EXP_FLAG_S <= EXP_Y_OUT(7);
      EXP_FLAG_P <= not(EXP_Y_OUT(0) xor EXP_Y_OUT(1) xor EXP_Y_OUT(2) xor
                        EXP_Y_OUT(3) xor EXP_Y_OUT(4) xor EXP_Y_OUT(5) xor
                        EXP_Y_OUT(6) xor EXP_Y_OUT(7));
      wait for CLOCK_period;
      
      assert Y_OUT = EXP_Y_OUT
         report integer'image(to_integer(unsigned(S_IN))) & " : Y_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_Y_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(Y_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " ; Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " ; Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " ; Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " ; Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- 101 => A xor B
      S_IN <= "101";
      EXP_Y_OUT <= (A_IN xor B_IN);
      wait for CLOCK_period;
      if (EXP_Y_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= '0';
      EXP_FLAG_S <= EXP_Y_OUT(7);
      EXP_FLAG_P <= not(EXP_Y_OUT(0) xor EXP_Y_OUT(1) xor EXP_Y_OUT(2) xor
                        EXP_Y_OUT(3) xor EXP_Y_OUT(4) xor EXP_Y_OUT(5) xor
                        EXP_Y_OUT(6) xor EXP_Y_OUT(7));
      wait for CLOCK_period;
      
      assert Y_OUT = EXP_Y_OUT
         report integer'image(to_integer(unsigned(S_IN))) & " : Y_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_Y_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(Y_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " ; Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " ; Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " ; Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " ; Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- 110 => A + B + CYI
      CYI <= '1';
      wait for CLOCK_period;
      S_IN <= "110";
      EXP_Y_OUT <= (A_IN + B_IN + CYI);
      EXP_Y_OUT_EXTENDED <= ('0' & A_IN) + B_IN + CYI;
      wait for CLOCK_period;
      if (EXP_Y_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= EXP_Y_OUT_EXTENDED(8);
      EXP_FLAG_S <= EXP_Y_OUT(7);
      EXP_FLAG_P <= not(EXP_Y_OUT(0) xor EXP_Y_OUT(1) xor EXP_Y_OUT(2) xor
                        EXP_Y_OUT(3) xor EXP_Y_OUT(4) xor EXP_Y_OUT(5) xor
                        EXP_Y_OUT(6) xor EXP_Y_OUT(7));
      wait for CLOCK_period;
      
      assert Y_OUT = EXP_Y_OUT
         report integer'image(to_integer(unsigned(S_IN))) & " : Y_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_Y_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(Y_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " ; Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " ; Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " ; Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " ; Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      -- 111 => A - B - CYI
      CYI <= '0';
      wait for CLOCK_period;
      S_IN <= "111";
      EXP_Y_OUT <= (A_IN - B_IN - CYI);
      wait for CLOCK_period;
      if (EXP_Y_OUT = "00000000") then
         EXP_FLAG_Z <= '1';
      else
         EXP_FLAG_Z <= '0';
      end if;
      EXP_FLAG_C <= '0';
      EXP_FLAG_S <= EXP_Y_OUT(7);
      EXP_FLAG_P <= not(EXP_Y_OUT(0) xor EXP_Y_OUT(1) xor EXP_Y_OUT(2) xor
                        EXP_Y_OUT(3) xor EXP_Y_OUT(4) xor EXP_Y_OUT(5) xor
                        EXP_Y_OUT(6) xor EXP_Y_OUT(7));
      wait for CLOCK_period;
      
      assert Y_OUT = EXP_Y_OUT
         report integer'image(to_integer(unsigned(S_IN))) & " : Y_OUT failed ; Expected = " &
            integer'image(to_integer(unsigned(EXP_Y_OUT))) & " ; Received = " &
            integer'image(to_integer(unsigned(Y_OUT)))
         severity ERROR;
      
      assert FLAG_Z = EXP_FLAG_Z
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_Z failed ; Expected = " &
            std_logic'image(EXP_FLAG_Z) & " ; Received = " &
            std_logic'image(FLAG_Z)
         severity ERROR;
      
      assert FLAG_C = EXP_FLAG_C
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_C failed ; Expected = " &
            std_logic'image(EXP_FLAG_C) & " ; Received = " &
            std_logic'image(FLAG_C)
         severity ERROR;
      
      assert FLAG_S = EXP_FLAG_S
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_S failed ; Expected = " &
            std_logic'image(EXP_FLAG_S) & " ; Received = " &
            std_logic'image(FLAG_S)
         severity ERROR;
      
      assert FLAG_P = EXP_FLAG_P
         report integer'image(to_integer(unsigned(S_IN))) & " : FLAG_P failed ; Expected = " &
            std_logic'image(EXP_FLAG_P) & " ; Received = " &
            std_logic'image(FLAG_P)
         severity ERROR;
      
      report "All Tests Completed" severity NOTE;

      wait;
   end process;

END;
