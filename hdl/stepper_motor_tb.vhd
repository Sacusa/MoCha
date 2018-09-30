--------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
--
-- Create Date:   16:47:57 01/12/2018
-- Module Name:   C:/Shared/hdl/processor/stepper_motor_tb.vhd
-- Project Name:  processor
-- Target Device: Numato MIMAS V2
-- 
-- VHDL Test Bench Created by ISE for module: stepper_motor
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY stepper_motor_tb IS
END stepper_motor_tb;
 
ARCHITECTURE behavior OF stepper_motor_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT stepper_motor
    PORT(
         SPEED : IN  std_logic_vector(4 downto 0);
         STEPS : IN  std_logic_vector(7 downto 0);
         DIR : IN  std_logic;
         ENABLE : IN  std_logic;
         LD_SPEED : IN  std_logic;
         LD_STEPS : IN  std_logic;
         LD_DIR : IN  std_logic;
         LD_ENABLE : IN  std_logic;
         CLOCK : IN  std_logic;
         MOTOR : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal SPEED : std_logic_vector(4 downto 0) := (others => '0');
   signal STEPS : std_logic_vector(7 downto 0) := (others => '0');
   signal DIR : std_logic := '0';
   signal ENABLE : std_logic := '0';
   signal LD_SPEED : std_logic := '0';
   signal LD_STEPS : std_logic := '0';
   signal LD_DIR : std_logic := '0';
   signal LD_ENABLE : std_logic := '0';
   signal CLOCK : std_logic := '0';

 	--Outputs
   signal MOTOR : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 1 ns;
   
   -- Array of motor values
   type STEPPER_MOTOR_VAL is array (0 to 3) of std_logic_vector(3 downto 0);
   signal MOTOR_VAL : STEPPER_MOTOR_VAL;
   signal MOTOR_VAL_SEL : std_logic_vector(1 downto 0) := "00";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: stepper_motor PORT MAP (
          SPEED => SPEED,
          STEPS => STEPS,
          DIR => DIR,
          ENABLE => ENABLE,
          LD_SPEED => LD_SPEED,
          LD_STEPS => LD_STEPS,
          LD_DIR => LD_DIR,
          LD_ENABLE => LD_ENABLE,
          CLOCK => CLOCK,
          MOTOR => MOTOR
        );

   -- Clock process definitions
   CLOCK_process :process
   begin
		CLOCK <= '0';
		wait for CLOCK_period/2;
		CLOCK <= '1';
		wait for CLOCK_period/2;
   end process;
   
   MOTOR_VAL(0) <= "0110";
   MOTOR_VAL(1) <= "0101";
   MOTOR_VAL(2) <= "1001";
   MOTOR_VAL(3) <= "1010";

   -- Stimulus process
   stim_proc: process
   
      variable WAIT_period : integer;
   
   begin		
      -- hold reset state for 10 cycles.
      wait for CLOCK_period*10;

      --------------------
      -- Clockwise Test --
      --------------------
      
      -- iterate over speed values
      for sp in 0 to 7 loop
         WAIT_period := 2 ** (sp + 1);
         
         -- iterate over step values
         for st in 1 to 63 loop
         
            -- disable the motor
            ENABLE <= '0';
            LD_ENABLE <= '1';
            wait for CLOCK_period;
            LD_ENABLE <= '0';
            
            -- load values
            SPEED <= std_logic_vector(to_unsigned(sp, 5));
            STEPS <= std_logic_vector(to_unsigned(st, 8));
            DIR <= '0';
            LD_SPEED <= '1';
            LD_STEPS <= '1';
            LD_DIR <= '1';
            wait for CLOCK_period;
            SPEED <= (others => '0');
            STEPS <= (others => '0');
            DIR <= '1';
            LD_SPEED <= '0';
            LD_STEPS <= '0';
            LD_DIR <= '0';
            MOTOR_VAL_SEL <= "01";
            
            -- enable the motor
            ENABLE <= '1';
            LD_ENABLE <= '1';
            wait for CLOCK_period;
            LD_ENABLE <= '0';
            wait for CLOCK_period;
            
            -- cycle 0 needs manual checking due to short cycle time
            assert MOTOR = "0110"
               report "CW(SP=" &
                  integer'image(sp) & ", ST=" &
                  integer'image(st) & ") Cycle 0 : Expected 0110"
               severity ERROR;
            wait for CLOCK_period * (WAIT_period - 1);
            
            -- check the remaining values
            for c in 1 to st loop
               MOTOR_VAL_SEL <= std_logic_vector(unsigned(MOTOR_VAL_SEL) + 1);
               
               assert MOTOR = MOTOR_VAL(to_integer(unsigned(MOTOR_VAL_SEL)))
                  report "CW(SP=" &
                     integer'image(sp) & ", ST=" &
                     integer'image(st) & ") Cycle " &
                     integer'image(c) & " : Expected " &
                     integer'image(to_integer(unsigned(MOTOR_VAL(to_integer(unsigned(MOTOR_VAL_SEL))))))
                  severity ERROR;
               wait for CLOCK_period * WAIT_period;
            end loop;
            
            -- report completion
            report "CW(SP=" &
               integer'image(sp) & ", ST=" &
               integer'image(st) & ") Completed"
            severity NOTE;
         end loop;
      end loop;
         
      -------------------------
      -- Anti-Clockwise Test --
      -------------------------
      
      -- iterate over speed values
      for sp in 0 to 7 loop
         WAIT_period := 2 ** (sp + 1);
         
         -- iterate over step values
         for st in 1 to 63 loop
         
            -- disable the motor
            ENABLE <= '0';
            LD_ENABLE <= '1';
            wait for CLOCK_period;
            LD_ENABLE <= '0';
            
            -- load values
            SPEED <= std_logic_vector(to_unsigned(sp, 5));
            STEPS <= std_logic_vector(to_unsigned(st, 8));
            DIR <= '1';
            LD_SPEED <= '1';
            LD_STEPS <= '1';
            LD_DIR <= '1';
            wait for CLOCK_period;
            SPEED <= (others => '0');
            STEPS <= (others => '0');
            DIR <= '0';
            LD_SPEED <= '0';
            LD_STEPS <= '0';
            LD_DIR <= '0';
            MOTOR_VAL_SEL <= "11";
            
            -- enable the motor
            ENABLE <= '1';
            LD_ENABLE <= '1';
            wait for CLOCK_period;
            LD_ENABLE <= '0';
            wait for CLOCK_period;
            
            -- cycle 0 needs manual checking due to short cycle time
            assert MOTOR = "0110"
               report "ACW(SP=" &
                  integer'image(sp) & ", ST=" &
                  integer'image(st) & ") Cycle 0 : Expected 0110"
               severity ERROR;
            wait for CLOCK_period * (WAIT_period - 1);
            
            -- check the remaining values
            for c in 1 to st loop
               MOTOR_VAL_SEL <= std_logic_vector(unsigned(MOTOR_VAL_SEL) - 1);
               
               assert MOTOR = MOTOR_VAL(to_integer(unsigned(MOTOR_VAL_SEL)))
                  report "ACW(SP=" &
                     integer'image(sp) & ", ST=" &
                     integer'image(st) & ") Cycle " &
                     integer'image(c) & " : Expected " &
                     integer'image(to_integer(unsigned(MOTOR_VAL(to_integer(unsigned(MOTOR_VAL_SEL))))))
                  severity ERROR;
               wait for CLOCK_period * WAIT_period;
            end loop;
            
            -- report completion
            report "ACW(SP=" &
               integer'image(sp) & ", ST=" &
               integer'image(st) & ") Completed"
            severity NOTE;
         end loop;
      end loop;
      
      report "All Tests Completed" severity NOTE;

      wait;
   end process;

END;
