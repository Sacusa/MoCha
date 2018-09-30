--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   11:07:29 06/12/2018
-- Module Name:   C:/Shared/hdl/processor/memory_unit_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: memory_unit
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY memory_unit_tb IS
END memory_unit_tb;
 
ARCHITECTURE behavior OF memory_unit_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memory_unit
    PORT(
         CLOCK : IN  std_logic;
         WEA : IN  std_logic;
         ADDRESS : IN  std_logic_vector(15 downto 0);
         DATA_IN : IN  std_logic_vector(7 downto 0);
         DATA_OUT : OUT  std_logic_vector(7 downto 0);
         IO_0 : IN  std_logic_vector(7 downto 0);
         IO_1 : OUT  std_logic_vector(7 downto 0);
         IO_2 : OUT  std_logic_vector(7 downto 0);
         IO_8 : INOUT  std_logic_vector(7 downto 0);
         IO_9 : INOUT  std_logic_vector(7 downto 0);
         IO_10 : INOUT  std_logic_vector(7 downto 0);
         IO_11 : INOUT  std_logic_vector(7 downto 0);
         IO_12 : INOUT  std_logic_vector(7 downto 0);
         IO_13 : INOUT  std_logic_vector(7 downto 0);
         IO_14 : INOUT  std_logic_vector(7 downto 0);
         IO_15 : INOUT  std_logic_vector(7 downto 0);
         SM_OUT : OUT  std_logic_vector(3 downto 0);
         SPI_CLK : OUT  std_logic;
         SPI_CS : OUT  std_logic;
         SPI_DIN : IN  std_logic;
         SPI_DOUT : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK : std_logic := '0';
   signal WEA : std_logic := '0';
   signal ADDRESS : std_logic_vector(15 downto 0) := (others => '0');
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal IO_0 : std_logic_vector(7 downto 0) := (others => '0');
   signal SPI_DIN : std_logic := '0';

	--BiDirs
   signal IO_8 : std_logic_vector(7 downto 0);
   signal IO_9 : std_logic_vector(7 downto 0);
   signal IO_10 : std_logic_vector(7 downto 0);
   signal IO_11 : std_logic_vector(7 downto 0);
   signal IO_12 : std_logic_vector(7 downto 0);
   signal IO_13 : std_logic_vector(7 downto 0);
   signal IO_14 : std_logic_vector(7 downto 0);
   signal IO_15 : std_logic_vector(7 downto 0);

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);
   signal IO_1 : std_logic_vector(7 downto 0);
   signal IO_2 : std_logic_vector(7 downto 0);
   signal SM_OUT : std_logic_vector(3 downto 0);
   signal SPI_CLK : std_logic;
   signal SPI_CS : std_logic;
   signal SPI_DOUT : std_logic;

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   
   signal EXP_SM_OUT : std_logic_vector(3 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory_unit PORT MAP (
          CLOCK => CLOCK,
          WEA => WEA,
          ADDRESS => ADDRESS,
          DATA_IN => DATA_IN,
          DATA_OUT => DATA_OUT,
          IO_0 => IO_0,
          IO_1 => IO_1,
          IO_2 => IO_2,
          IO_8 => IO_8,
          IO_9 => IO_9,
          IO_10 => IO_10,
          IO_11 => IO_11,
          IO_12 => IO_12,
          IO_13 => IO_13,
          IO_14 => IO_14,
          IO_15 => IO_15,
          SM_OUT => SM_OUT,
          SPI_CLK => SPI_CLK,
          SPI_CS => SPI_CS,
          SPI_DIN => SPI_DIN,
          SPI_DOUT => SPI_DOUT
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
      ------------------------
      -- Test I/O 0 (STDIN) --
      ------------------------
      WEA <= '0';
      ADDRESS <= "11111111111" & "00000";
      DATA_IN <= (others => '-');
      
      -- write 0x00 to IO_0
      IO_0 <= (others => '0');
      wait for CLOCK_period;
      assert DATA_OUT = IO_0
         report "IO_0 TEST failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO_0))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
         
      -- write 0xff to IO_0
      IO_0 <= (others => '1');
      wait for CLOCK_period;
      assert DATA_OUT = IO_0
         report "IO_0 TEST failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO_0))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -------------------------
      -- Test I/O 1 (STDOUT) --
      -------------------------
      WEA <= '1';
      ADDRESS <= "11111111111" & "00001";
      
      -- read 0x00 from IO_1
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      assert IO_1 = DATA_IN
         report "IO_1 TEST failed : Expected IO_1 = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received IO_1 = " &
            integer'image(to_integer(unsigned(IO_1)))
         severity ERROR;
      assert DATA_OUT = DATA_IN
         report "IO_1 TEST failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
         
      -- read 0xff from IO_1
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert IO_1 = DATA_IN
         report "IO_1 TEST failed : Expected IO_1 = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received IO_1 = " &
            integer'image(to_integer(unsigned(IO_1)))
         severity ERROR;
      assert DATA_OUT = DATA_IN
         report "IO_1 TEST failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -------------------------
      -- Test I/O 2 (STDERR) --
      -------------------------
      WEA <= '1';
      ADDRESS <= "11111111111" & "00010";
      
      -- read 0x00 from IO_2
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      assert IO_2 = DATA_IN
         report "IO_2 TEST failed : Expected IO_2 = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received IO_2 = " &
            integer'image(to_integer(unsigned(IO_2)))
         severity ERROR;
      assert DATA_OUT = DATA_IN
         report "IO_2 TEST failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
         
      -- read 0xff from IO_2
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      assert IO_2 = DATA_IN
         report "IO_2 TEST failed : Expected IO_2 = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received IO_2 = " &
            integer'image(to_integer(unsigned(IO_2)))
         severity ERROR;
      assert DATA_OUT = DATA_IN
         report "IO_2 TEST failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      ---------------------------------------------------------------
      -- Test I/O 3, 4, 5, 6 and SM_OUT (stepper motor peripheral) --
      ---------------------------------------------------------------
      WEA <= '1';
      
      -- disable motor
      ADDRESS <= "11111111111" & "00110";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      
      -- run motor at speed 0 (max) for 255 steps
      ADDRESS <= "11111111111" & "00011";  -- speed
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      ADDRESS <= "11111111111" & "00100";  -- steps
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11111111111" & "00101";  -- direction
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      ADDRESS <= "11111111111" & "00110";  -- enable
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      WEA <= '0';
      
      -- check initial output
      EXP_SM_OUT <= "0110";
      wait for CLOCK_period;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(0) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 59 cycles
      EXP_SM_OUT <= "1001";
      wait for CLOCK_period * 59;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(59) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 117 cycles
      EXP_SM_OUT <= "1010";
      wait for CLOCK_period * 58;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(117) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 175 cycles
      EXP_SM_OUT <= "0110";
      wait for CLOCK_period * 58;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(175) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 233 cycles
      EXP_SM_OUT <= "0101";
      wait for CLOCK_period * 58;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(233) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 291 cycles
      EXP_SM_OUT <= "1001";
      wait for CLOCK_period * 58;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(291) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 349 cycles
      EXP_SM_OUT <= "1010";
      wait for CLOCK_period * 58;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(349) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 407 cycles
      EXP_SM_OUT <= "0110";
      wait for CLOCK_period * 58;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(407) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 465 cycles
      EXP_SM_OUT <= "0101";
      wait for CLOCK_period * 58;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(465) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      -- check output after 523 cycles
      EXP_SM_OUT <= "1010";
      wait for CLOCK_period * 58;
      assert SM_OUT = EXP_SM_OUT
         report "SM_OUT(523) TEST failed : Expected SM_OUT = " &
            integer'image(to_integer(unsigned(EXP_SM_OUT))) & " ; Received SM_OUT = " &
            integer'image(to_integer(unsigned(SM_OUT)))
         severity ERROR;
      
      ----------------------------------------------------------------------
      -- Test I/O 7, SPI_CLK, SPI_CS, SPI_DIN and SPI_DOUT (SPI register) --
      ----------------------------------------------------------------------
      WEA <= '1';
      ADDRESS <= "11111111111" & "00111";
      
      -- write 0x0 to SPI
      DATA_IN <= "1111" & "0010";
      SPI_DIN <= '0';
      wait for CLOCK_period;
      assert DATA_OUT = "00000000"
         report "SPI TEST failed : Expected DATA_OUT = " &
            integer'image(0) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      assert SPI_CLK = '0'
         report "SPI TEST failed : Expected SPI_CLK = " &
            integer'image(0) & " ; Received SPI_CLK = " &
            std_logic'image(SPI_CLK)
         severity ERROR;
      assert SPI_CS = '0'
         report "SPI TEST failed : Expected SPI_CS = " &
            integer'image(0) & " ; Received SPI_CS = " &
            std_logic'image(SPI_CS)
         severity ERROR;
      assert SPI_DOUT = '0'
         report "SPI TEST failed : Expected SPI_DOUT = " &
            integer'image(0) & " ; Received SPI_DOUT = " &
            std_logic'image(SPI_DOUT)
         severity ERROR;
         
      -- write 0xf to SPI
      DATA_IN <= "1111" & "1101";
      SPI_DIN <= '1';
      wait for CLOCK_period;
      assert DATA_OUT = "00001111"
         report "SPI TEST failed : Expected DATA_OUT = " &
            integer'image(15) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      assert SPI_CLK = '1'
         report "SPI TEST failed : Expected SPI_CLK = " &
            integer'image(1) & " ; Received SPI_CLK = " &
            std_logic'image(SPI_CLK)
         severity ERROR;
      assert SPI_CS = '1'
         report "SPI TEST failed : Expected SPI_CS = " &
            integer'image(1) & " ; Received SPI_CS = " &
            std_logic'image(SPI_CS)
         severity ERROR;
      assert SPI_DOUT = '1'
         report "SPI TEST failed : Expected SPI_DOUT = " &
            integer'image(1) & " ; Received SPI_DOUT = " &
            std_logic'image(SPI_DOUT)
         severity ERROR;
      
      ---------------------------------------------------------------------------------
      -- Sequentially set all GPIOs (I/O 8, 9, 10) to output and verify their values --
      ---------------------------------------------------------------------------------
      IO_8  <= (others => 'Z');
      IO_9  <= (others => 'Z');
      IO_10 <= (others => 'Z');
      WEA <= '1';      
      
      -- IO 8
      ADDRESS <= "11111111111" & "11000";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11111111111" & "01000";
      DATA_IN <= "10101010";
      wait for CLOCK_period;
      assert IO_8 = DATA_IN
         report "IO_8 OUTPUT failed : Expected IO_8 = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received IO_8 = " &
            integer'image(to_integer(unsigned(IO_8)))
         severity ERROR;
      
      -- IO 9
      ADDRESS <= "11111111111" & "11001";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11111111111" & "01001";
      DATA_IN <= "10101010";
      wait for CLOCK_period;
      assert IO_9 = DATA_IN
         report "IO_9 OUTPUT failed : Expected IO_9 = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received IO_9 = " &
            integer'image(to_integer(unsigned(IO_9)))
         severity ERROR;
      
      -- IO 10
      ADDRESS <= "11111111111" & "11010";
      DATA_IN <= (others => '1');
      wait for CLOCK_period;
      ADDRESS <= "11111111111" & "01010";
      DATA_IN <= "10101010";
      wait for CLOCK_period;
      assert IO_10 = DATA_IN
         report "IO_10 OUTPUT failed : Expected IO_10 = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received IO_10 = " &
            integer'image(to_integer(unsigned(IO_10)))
         severity ERROR;
      
      --------------------------------------------------------------------------------
      -- Sequentially set all GPIOs (I/O 8, 9, 10) to input and verify their values --
      --------------------------------------------------------------------------------
      
      -- IO 8
      WEA <= '1';
      ADDRESS <= "11111111111" & "11000";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11111111111" & "01000";
      IO_8 <= "01010101";
      wait for CLOCK_period;
      assert DATA_OUT = IO_8
         report "IO_8 INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO_8))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- IO 9
      WEA <= '1';
      ADDRESS <= "11111111111" & "11001";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11111111111" & "01001";
      IO_9 <= "01010101";
      wait for CLOCK_period;
      assert DATA_OUT = IO_9
         report "IO_9 INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO_9))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- IO 10
      WEA <= '1';
      ADDRESS <= "11111111111" & "11010";
      DATA_IN <= (others => '0');
      wait for CLOCK_period;
      WEA <= '0';
      ADDRESS <= "11111111111" & "01010";
      IO_10 <= "01010101";
      wait for CLOCK_period;
      assert DATA_OUT = IO_10
         report "IO_10 INPUT failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(IO_10))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      ----------------------
      -- Test main memory --
      ----------------------
      
      -- test "000-------------"
      WEA <= '1';
      ADDRESS <= "000" & "1010101010101";
      DATA_IN <= "01010101";
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN
         report "MEMORY TEST(" &
            integer'image(to_integer(unsigned(ADDRESS(15 downto 13)))) & ")failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- test "001-------------"
      WEA <= '1';
      ADDRESS <= "001" & "1010101010101";
      DATA_IN <= "10101010";
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN
         report "MEMORY TEST(" &
            integer'image(to_integer(unsigned(ADDRESS(15 downto 13)))) & ")failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- test "010-------------"
      WEA <= '1';
      ADDRESS <= "010" & "1010101010101";
      DATA_IN <= "01010101";
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN
         report "MEMORY TEST(" &
            integer'image(to_integer(unsigned(ADDRESS(15 downto 13)))) & ")failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- test "011-------------"
      WEA <= '1';
      ADDRESS <= "011" & "1010101010101";
      DATA_IN <= "10101010";
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN
         report "MEMORY TEST(" &
            integer'image(to_integer(unsigned(ADDRESS(15 downto 13)))) & ")failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- test "100-------------"
      WEA <= '1';
      ADDRESS <= "100" & "1010101010101";
      DATA_IN <= "01010101";
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN
         report "MEMORY TEST(" &
            integer'image(to_integer(unsigned(ADDRESS(15 downto 13)))) & ")failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- test "101-------------"
      WEA <= '1';
      ADDRESS <= "101" & "1010101010101";
      DATA_IN <= "10101010";
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN
         report "MEMORY TEST(" &
            integer'image(to_integer(unsigned(ADDRESS(15 downto 13)))) & ")failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- test "110-------------"
      WEA <= '1';
      ADDRESS <= "110" & "1010101010101";
      DATA_IN <= "01010101";
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN
         report "MEMORY TEST(" &
            integer'image(to_integer(unsigned(ADDRESS(15 downto 13)))) & ")failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;
      
      -- test "111-------------"
      WEA <= '1';
      ADDRESS <= "111" & "1010101010101";
      DATA_IN <= "10101010";
      wait for CLOCK_period*2;
      assert DATA_OUT = DATA_IN
         report "MEMORY TEST(" &
            integer'image(to_integer(unsigned(ADDRESS(15 downto 13)))) & ")failed : Expected DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_IN))) & " ; Received DATA_OUT = " &
            integer'image(to_integer(unsigned(DATA_OUT)))
         severity ERROR;

      report "All Tests Completed" severity NOTE;
      
      wait;
   end process;

END;
