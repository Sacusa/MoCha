----------------------------------------------------------------------------------
-- Company:  NIIT University
-- Engineer: Sudhanshu Gupta
-- 
-- Create Date:    10:40:08 09/01/2017 
-- Module Name:    processor - Behavioral 
-- Project Name:   processor
-- Target Devices: Numato MIMAS V2 
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processor is
    Port ( RESET_IN : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           MEM_OUT  : in  STD_LOGIC_VECTOR (7 downto 0);
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           MEM_WEA  : out STD_LOGIC_VECTOR (0 downto 0);
           MEM_ADDR : out STD_LOGIC_VECTOR (7 downto 0);
           MEM_IN   : out STD_LOGIC_VECTOR (7 downto 0));
end processor;

architecture Behavioral of processor is

   -- import ALU
   component alu
    Port ( A_IN   : in  STD_LOGIC_VECTOR (7 downto 0);
           B_IN   : in  STD_LOGIC_VECTOR (7 downto 0);
           S_IN   : in  STD_LOGIC_VECTOR (2 downto 0);
           CYI    : in  STD_LOGIC;
           Y_OUT  : out STD_LOGIC_VECTOR (7 downto 0);
           FLAG_Z : out STD_LOGIC;
           FLAG_C : out STD_LOGIC;
           FLAG_S : out STD_LOGIC;
           FLAG_P : out STD_LOGIC);
   end component;
   
   -- import control unit
   component control_unit
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           FLAGS    : in  STD_LOGIC_VECTOR (7 downto 0);
           RESET    : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (27 downto 0));
   end component;
   
   -- import complementer/shifter module
   component cs
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           SCS      : in  STD_LOGIC_VECTOR (1 downto 0);
           CARRY_IN : in  STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           FLAG_Z   : out STD_LOGIC;
           FLAG_C   : out STD_LOGIC;
           FLAG_S   : out STD_LOGIC;
           FLAG_P   : out STD_LOGIC);
   end component;
   
   -- import flag register
   component flag_register
    Port ( FLAG_Z   : in  STD_LOGIC;
           FLAG_C   : in  STD_LOGIC;
           FLAG_S   : in  STD_LOGIC;
           FLAG_P   : in  STD_LOGIC;
           LOAD     : in  STD_LOGIC;
           CLOCK    : in  STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0));
   end component;
   
   -- import program counter
   component pc
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           CLOCK    : in  STD_LOGIC;
           INC      : in  STD_LOGIC;
           LOAD     : in  STD_LOGIC_VECTOR (1 downto 0);
           DATA_OUT : out STD_LOGIC_VECTOR (15 downto 0));
   end component;
   
   -- import 8-bit register
   component reg8
    Port ( DATA      : in  STD_LOGIC_VECTOR (7 downto 0);
           INPUT_EN  : in  STD_LOGIC;
           RESET     : in  STD_LOGIC;
           CLOCK     : in  STD_LOGIC;
           Q         : out STD_LOGIC_VECTOR (7 downto 0));
   end component;
   
   -- import register array
   component reg_array
    port ( clka  : in  STD_LOGIC;
           ena   : in  STD_LOGIC;
           wea   : in  STD_LOGIC_VECTOR (0 DOWNTO 0);
           addra : in  STD_LOGIC_VECTOR (2 DOWNTO 0);
           dina  : in  STD_LOGIC_VECTOR (7 DOWNTO 0);
           douta : out STD_LOGIC_VECTOR (7 DOWNTO 0));
   end component;
   
   -- import stack pointer module
   component sp
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           CLOCK    : in  STD_LOGIC;
           INC      : in  STD_LOGIC;
           DEC      : in  STD_LOGIC;
           LOAD     : in  STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0));
   end component;
   
   signal RESET : STD_LOGIC;
   
   -- Common bus signals
   signal COMMON_BUS_SEL : STD_LOGIC_VECTOR (5 DOWNTO 0);
   signal COMMON_BUS : STD_LOGIC_VECTOR (7 downto 0);
   
   -- Main memory signals
   signal MEM_RD : STD_LOGIC;
   
   -- Memory Register signals
   signal MR_LMR : STD_LOGIC;
   
   -- Program Counter signals
   signal PC_IPC : STD_LOGIC;
   signal PC_EPC, PC_LPC : STD_LOGIC_VECTOR (1 DOWNTO 0);
   signal PC_OUT : STD_LOGIC_VECTOR (15 DOWNTO 0);
   
   -- Stack Pointer signals
   signal SP_ISP, SP_DSP, SP_ESP, SP_LSP : STD_LOGIC;
   signal SP_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
   -- Instruction Register signals
   signal IR_LIR : STD_LOGIC;
   signal IR_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
   -- Control Unit signals
   signal CU_OUT : STD_LOGIC_VECTOR (27 DOWNTO 0);
   
   -- Operand Register signals
   signal OR_ROR, OR_LOR : STD_LOGIC;
   signal OR_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
   -- ALU signals
   signal ALU_FLAG_Z, ALU_FLAG_C, ALU_FLAG_S, ALU_FLAG_P : STD_LOGIC;
   signal ALU_SAF : STD_LOGIC_VECTOR (2 DOWNTO 0);
   signal ALU_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
   -- Complementer/Shifter signals
   signal CS_SCS : STD_LOGIC_VECTOR (1 DOWNTO 0);
   signal CS_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal CS_FLAG_Z, CS_FLAG_C, CS_FLAG_S, CS_FLAG_P : STD_LOGIC;
   
   -- Accumulator Register signals
   signal AR_EAR, AR_RAR, AR_LAR : STD_LOGIC;
   signal AR_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
   -- Register Array signals
   signal RA_ERG : STD_LOGIC;
   signal RA_LRG : STD_LOGIC_VECTOR (0 DOWNTO 0);
   signal RA_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
   -- Flag Register signals
   signal FLAG_Z, FLAG_C, FLAG_S, FLAG_P, FLAG_LOAD : STD_LOGIC;
   signal FLAG_OUT : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
begin
   
   -- Map control unit output to individual signals
   MEM_RD <= CU_OUT(27);
   MEM_WEA(0) <= CU_OUT(26);
   MR_LMR <= CU_OUT(25);
   PC_EPC <= CU_OUT(24 downto 23);
   PC_IPC <= CU_OUT(22);
   PC_LPC <= CU_OUT(21 downto 20);
   SP_ISP <= CU_OUT(19);
   SP_DSP <= CU_OUT(18);
   SP_ESP <= CU_OUT(17);
   SP_LSP <= CU_OUT(16);
   IR_LIR <= CU_OUT(15);
   FLAG_LOAD <= CU_OUT(13);
   OR_ROR <= CU_OUT(11);
   OR_LOR <= CU_OUT(10);
   ALU_SAF <= CU_OUT(9 DOWNTO 7);
   CS_SCS <= CU_OUT(6 DOWNTO 5);
   AR_EAR <= CU_OUT(4);
   AR_RAR <= CU_OUT(3);
   AR_LAR <= CU_OUT(2);
   RA_ERG <= CU_OUT(1);
   RA_LRG(0) <= CU_OUT(0);
   
   RESET <= not RESET_IN;
   DATA_OUT <= RA_OUT;
   MEM_IN <= COMMON_BUS;
   
   -- resolve contention for COMMON_BUS using one-hot encoding
   COMMON_BUS_SEL <= MEM_RD & PC_EPC & SP_ESP & AR_EAR & RA_ERG;
   with (COMMON_BUS_SEL) select
      COMMON_BUS <= MEM_OUT             when "100000"|"101000",
                    PC_OUT(7 downto 0)  when "010000",
                    PC_OUT(15 downto 8) when "011000",
                    SP_OUT              when "000100"|"001100",
                    AR_OUT              when "000010"|"001010",
                    RA_OUT              when "000001"|"001001",
                    (others => '0') when others;
   
   -- select flag register input
   with (CS_SCS) select
      FLAG_Z <= ALU_FLAG_Z when "00",
                CS_FLAG_Z  when others;
   with (CS_SCS) select
      FLAG_C <= ALU_FLAG_C when "00",
                CS_FLAG_C  when others;
   with (CS_SCS) select
      FLAG_S <= ALU_FLAG_S when "00",
                CS_FLAG_S  when others;
   with (CS_SCS) select
      FLAG_P <= ALU_FLAG_P when "00",
                CS_FLAG_P  when others;
   
   -- Memory Register
   mr_inst: reg8
      PORT MAP (
         DATA => COMMON_BUS,
         INPUT_EN => MR_LMR,
         RESET => '0',
         CLOCK => CLOCK,
         Q => MEM_ADDR
      );
   
   -- Program Counter
   pc_inst: pc
      PORT MAP (
         DATA_IN => COMMON_BUS,
         CLOCK => CLOCK,
         INC => PC_IPC,
         LOAD => PC_LPC,
         DATA_OUT => PC_OUT
      );
   
   -- Stack Pointer
   sp_inst: sp
      PORT MAP (
         DATA_IN => COMMON_BUS,
         CLOCK => CLOCK,
         INC => SP_ISP,
         DEC => SP_DSP,
         LOAD => SP_LSP,
         DATA_OUT => SP_OUT
      );
   
   -- Instruction Register
   ir_inst: reg8
      PORT MAP (
         DATA => COMMON_BUS,
         INPUT_EN => IR_LIR,
         RESET => '0',
         CLOCK => CLOCK,
         Q => IR_OUT
      );
   
   -- Control Unit
   cu_inst: control_unit
      PORT MAP (
         DATA_IN => IR_OUT,
         FLAGS => FLAG_OUT,
         RESET => RESET,
         CLOCK => CLOCK,
         DATA_OUT => CU_OUT
      );
   
   -- Operand Register
   or_inst: reg8
      PORT MAP (
         DATA => COMMON_BUS,
         INPUT_EN => OR_LOR,
         RESET => OR_ROR,
         CLOCK => CLOCK,
         Q => OR_OUT
      );
   
   -- ALU
   alu_inst: alu
      PORT MAP (
         A_IN => COMMON_BUS,
         B_IN => OR_OUT,
         S_IN => ALU_SAF,
         CYI => FLAG_OUT(3),
         Y_OUT => ALU_OUT,
         FLAG_Z => ALU_FLAG_Z,
         FLAG_C => ALU_FLAG_C,
         FLAG_S => ALU_FLAG_S,
         FLAG_P => ALU_FLAG_P
      );
   
   -- Complementer/Shifter
   cs_inst: cs
      PORT MAP (
         DATA_IN => ALU_OUT,
         SCS => CS_SCS,
         CARRY_IN => FLAG_OUT(3),
         DATA_OUT => CS_OUT,
         FLAG_Z => CS_FLAG_Z,
         FLAG_C => CS_FLAG_C,
         FLAG_S => CS_FLAG_S,
         FLAG_P => CS_FLAG_P
      );
   
   -- Accumulator
   ar_inst: reg8
      PORT MAP (
         DATA => CS_OUT,
         INPUT_EN => AR_LAR,
         RESET => AR_RAR,
         CLOCK => CLOCK,
         Q => AR_OUT
      );
   
   -- Register Array
   reg_array_inst: reg_array
      PORT MAP (
         clka => CLOCK,
         ena => '1',
         wea => RA_LRG,
         addra => IR_OUT (2 DOWNTO 0),
         dina => COMMON_BUS,
         douta => RA_OUT
      );

   -- Flag Register
   flag_reg_inst: flag_register
      PORT MAP (
         FLAG_Z => FLAG_Z,
         FLAG_C => FLAG_C,
         FLAG_S => FLAG_S,
         FLAG_P => FLAG_P,
         LOAD => FLAG_LOAD,
         CLOCK => CLOCK,
         DATA_OUT => FLAG_OUT
      );

end Behavioral;
