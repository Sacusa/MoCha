#!/usr/bin/python3

INSTRUCTION_CYCLES = [ 7,  2,  8,  8,  # NOP, STP, MVD, MVS
                      11,  8, 11, 11,  # MVI, MVB, STR, LOD
                       9,  9,  9,  9,  # NOT, INC, DCR, ADA
                       9,  9,  9,  9,  # SBA, XRA, ANA, ORA
                      13, 13, 13, 13,  # ADI, SBI, XRI, ANI
                      13, 10, 18,  8,  # ORI, JPD, JPP, JPR
                      20, 17, 14, 12,  # CAD, CAR, RET, PSH
                      11,  9,  9]      # POP, RRC, RLC

class NUP:
    '''
    NUP represents a single instance of the NUP processor. The processor can be simulated in both
    cycle-accurate and instruction-accurate modes.
    '''
    
    def __init__(self, usr_bin, mode, boot):
        '''
        Initializes an instance of NUP in 'mode' simulation accuracy with binary program from
        usr_bin.

        * usr_bin must be a list of integers, each integer representing a single byte.
        * mode must be either 'instruction' or 'cycle'.
        * boot specifies if the binary contains initial PC and SP values.
        '''
        DEFAULT_PC = 203
        DEFAULT_SP = 65504

        usr_bin_len = 0
        if boot:
            # manually compute program size
            usr_bin_len = len(usr_bin)
        else:
            # read program size from binary
            usr_bin_len = (int(usr_bin[0], 2) << 8) + int(usr_bin[1], 2)
            usr_bin = usr_bin[2:]
        
        if usr_bin_len < 4 and boot:
            raise ValueError('Size of binary must be atleast 4.')
        
        # initialize registers
        self.__pc = ((((int(usr_bin[2], 2) << 8) + int(usr_bin[3], 2)) + 1) & 65535) if boot \
                    else DEFAULT_PC
        self.__sp = ((int(usr_bin[0], 2) << 8) + int(usr_bin[1], 2)) if boot else DEFAULT_SP
        self.__mar = self.__pc - 1
        self.__br = 0
        self.__or = 0
        self.__ar = 0
        self.__gpr = [0 for i in range(8)]
        self.__fr = [1, 1, 0, 0, 1, 0, 0, 0]

        # initialize memory
        self.__mem = []
        if boot:
            # 1. insert user program
            # 2. insert 0s after user program
            self.__mem = [int(i, 2) for i in usr_bin] + \
                         [0 for i in range(usr_bin_len, 65536)]
        else:
            # 1. insert 0s before user program
            # 2. insert user program
            # 3. insert 0s after user program
            self.__mem = [0 for i in range(0, self.__mar)] + \
                         [int(i, 2) for i in usr_bin] + \
                         [0 for i in range(self.__mar + usr_bin_len, 65536)]
        self.__ir = self.__mem[self.__mar]
        
        # initialize run-time variables
        if mode not in ['instruction', 'cycle']:
            raise ValueError('Invalid simulation type \'' + mode + '\'.')
        self.__mode = mode
        self.__is_ready = True
        self.__instruction_count = 0
        self.__cycle_count = 0

        # initialize variables specific to cycle-accurate simulation
        self.__instruction_cycle = 0
        self.__current_instruction = self.__ir
    
    def run_sim(self, num = 0):
        '''
        Runs the simulator for num steps. Steps mean instructions in instruction-accurate mode
        and cycles in cycle-accurate mode.
        If num is 0, the simulation is run till the end of the program.
        '''
        if not self.__is_ready:
            # TODO : think of better error handling
            return 1
        
        if self.__mode == 'instruction':
            if num == 0:
                while self.__is_ready:
                    self.__exec_next_instruction()
                    self.__instruction_count += 1
            else:
                while self.__is_ready and (num > 0):
                    self.__exec_next_instruction()
                    self.__instruction_count += 1
                    num -= 1
        
        elif self.__mode == 'cycle':
            if num == 0:
                while self.__is_ready:
                    self.__exec_next_cycle()
                    self.__cycle_count += 1
            else:
                while self.__is_ready and (num > 0):
                    self.__exec_next_cycle()
                    self.__cycle_count += 1
                    num -= 1

    def get_regs(self):
        '''
        Returns a dictionary of the current state of the processor's registers.
        '''
        return {'mar' : self.__mar, 'pc'  : self.__pc, 'sp'  : self.__sp,  'br'  : self.__br,
                'or'  : self.__or,  'ar'  : self.__ar, 'gpr' : self.__gpr, 'ir'  : self.__ir,
                'fr'  : self.__fr}
    
    def get_mem(self):
        '''
        Returns a copy of the current state of the processor's memory.
        '''
        return self.__mem

    def __exec_next_instruction(self):
        '''
        Used in instruction-accurate mode, this method executes the next instruction. The
        processor's architectural state is updated, along with the instruction and cycle counts.
        '''
        instruction = self.__ir
        opcode = instruction >> 3
        fl_rn = instruction & 7

        self.__cycle_count += INSTRUCTION_CYCLES[opcode]

        # NOP
        if opcode == 0:
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # STP
        elif opcode == 1:
            self.__is_ready = False
        
        # MVD
        elif opcode == 2:
            self.__gpr[fl_rn] = self.__ar
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # MVS
        elif opcode == 3:
            self.__ar = self.__gpr[fl_rn]
            self.__update_fr(0)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # MVI
        elif opcode == 4:
            self.__gpr[fl_rn] = self.__mem[self.__pc]
            self.__mar = self.__pc + 1
            self.__ir = self.__mem[self.__mar]
            self.__pc += 2

        # MVB
        elif opcode == 5:
            self.__br = self.__gpr[fl_rn]
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # STR
        elif opcode == 6:
            self.__mem[(self.__br << 8) + self.__ar] = self.__gpr[fl_rn]
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # LOD
        elif opcode == 7:
            self.__gpr[fl_rn] = self.__mem[(self.__br << 8) + self.__ar]
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # NOT
        elif opcode == 8:
            self.__ar = self.__gpr[fl_rn] ^ 255
            self.__gpr[fl_rn] = self.__ar
            self.__update_fr(0)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # INC
        elif opcode == 9:
            sum = self.__gpr[fl_rn] + 1
            carry = 1 if sum > 255 else 0
            self.__ar = sum & 255
            self.__gpr[fl_rn] = self.__ar
            self.__update_fr(carry)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # DCR
        elif opcode == 10:
            self.__ar = (self.__gpr[fl_rn] - 1) & 255
            self.__gpr[fl_rn] = self.__ar
            self.__update_fr(0)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # ADA
        elif opcode == 11:
            self.__or = self.__gpr[fl_rn]
            sum = self.__ar + self.__or + self.__fr[3]
            carry = 1 if sum > 255 else 0
            self.__ar = sum & 255
            self.__update_fr(carry)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # SBA
        elif opcode == 12:
            self.__or = self.__gpr[fl_rn]
            self.__ar = (self.__ar - self.__or - self.__fr[3]) & 255
            self.__update_fr(0)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1

        # XRA
        elif opcode == 13:
            self.__or = self.__gpr[fl_rn]
            self.__ar = (self.__ar ^ self.__or) & 255
            self.__update_fr(0)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # ANA
        elif opcode == 14:
            self.__or = self.__gpr[fl_rn]
            self.__ar = (self.__ar & self.__or) & 255
            self.__update_fr(0)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # ORA
        elif opcode == 15:
            self.__or = self.__gpr[fl_rn]
            self.__ar = (self.__ar | self.__or) & 255
            self.__update_fr(0)
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # ADI
        elif opcode == 16:
            self.__or = self.__mem[self.__pc]
            sum = self.__gpr[fl_rn] + self.__or + self.__fr[3]
            carry = 1 if sum > 255 else 0
            self.__ar = sum & 255
            self.__gpr[fl_rn] = self.__ar
            self.__update_fr(carry)
            self.__mar = self.__pc + 1
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # SBI
        elif opcode == 17:
            self.__or = self.__mem[self.__pc]
            self.__ar = (self.__gpr[fl_rn] - self.__or - self.__fr[3]) & 255
            self.__gpr[fl_rn] = self.__ar
            self.__update_fr(0)
            self.__mar = self.__pc + 1
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # XRI
        elif opcode == 18:
            self.__or = self.__mem[self.__pc]
            self.__ar = (self.__gpr[fl_rn] ^ self.__or) & 255
            self.__gpr[fl_rn] = self.__ar
            self.__update_fr(0)
            self.__mar = self.__pc + 1
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # ANI
        elif opcode == 19:
            self.__or = self.__mem[self.__pc]
            self.__ar = (self.__gpr[fl_rn] & self.__or) & 255
            self.__gpr[fl_rn] = self.__ar
            self.__update_fr(0)
            self.__mar = self.__pc + 1
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # ORI
        elif opcode == 20:
            self.__or = self.__mem[self.__pc]
            self.__ar = (self.__gpr[fl_rn] | self.__or) & 255
            self.__gpr[fl_rn] = self.__ar
            self.__update_fr(0)
            self.__mar = self.__pc + 1
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # JPD
        elif opcode == 21:
            if self.__fr[fl_rn] == 1:
                self.__mar = self.__mem[self.__pc]
            else:
                self.__mar = self.__pc + 1
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # JPP
        elif opcode == 22:
            if self.__fr[fl_rn] == 1:
                self.__or = 0
                imm_value = self.__mem[self.__pc]
                if imm_value > 127:
                    imm_value = imm_value - 256
                self.__mar = self.__pc + imm_value + 1
                self.__ar = (imm_value * 2) & 255
                carry = 1 if imm_value > 127 else 0
                self.__update_fr(carry)
                self.__ar = (self.__mar >> 8) & 255
            else:
                self.__mar = self.__pc + 1
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # JPR
        elif opcode == 23:
            if self.__fr[fl_rn] == 1:
                self.__mar = self.__ar
            else:
                self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # CAD
        elif opcode == 24:
            if self.__fr[fl_rn] == 1:
                self.__sp -= 1
                self.__mem[self.__sp] = (self.__pc + 1) & 255
                sum = (self.__pc & 255) + 1
                carry = 1 if sum > 255 else 0
                self.__ar = sum & 255
                self.__update_fr(carry)
                self.__sp -= 1
                self.__mem[self.__sp] = (self.__pc + 1) >> 8
                self.__ar = 0
                self.__or = 0
                self.__mar = self.__mem[self.__pc]
            else:
                self.__mar = self.__pc + 1

            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # CAR
        elif opcode == 25:
            if self.__fr[fl_rn] == 1:
                self.__sp -= 1
                self.__mem[self.__sp] = (self.__pc + 1) & 255
                self.__sp -= 1
                self.__mem[self.__sp] = (self.__pc + 1) >> 8
                self.__mar = self.__ar
                self.__ar = 0
            else:
                self.__mar = self.__pc

            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # RET
        elif opcode == 26:
            if self.__fr[fl_rn] == 1:
                self.__mar = self.__mem[self.__sp] << 8
                self.__sp += 1
                self.__mar += self.__mem[self.__sp]
                self.__sp += 1
            else:
                self.__mar = self.__pc

            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # PSH
        elif opcode == 27:
            self.__sp -= 1
            self.__mem[self.__sp] = self.__gpr[fl_rn]
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # POP
        elif opcode == 28:
            self.__gpr[fl_rn] = self.__mem[self.__sp]
            self.__sp += 1
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # RRC
        elif opcode == 29:
            self.__ar = self.__gpr[fl_rn] >> 1
            self.__update_fr(self.__gpr[fl_rn] & 1)
            self.__gpr[fl_rn] = self.__ar
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        # RLC
        elif opcode == 30:
            self.__ar = self.__gpr[fl_rn] << 1
            self.__update_fr((self.__gpr[fl_rn] >> 7) & 1)
            self.__gpr[fl_rn] = self.__ar
            self.__mar = self.__pc
            self.__ir = self.__mem[self.__mar]
            self.__pc = self.__mar + 1
        
        else:
            raise ValueError('Invalid instruction: ' + str(instruction))

    def __exec_next_cycle(self):
        '''
        Used in cycle-accurate mode, this method executes the next cycle. The processor's
        architectural state is updated, along with the instruction and cycle counts.
        __current_instruction is updated at the very last cycle of an instruction, even though
        the instruction register is updated earlier on.
        '''
        opcode = self.__current_instruction >> 3
        fl_rn = self.__current_instruction & 7

        # NOP
        if opcode == 0:
            self.__load_next_instruction(self.__instruction_cycle)
        
        # STP
        elif opcode == 1:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
            else:
                self.__instruction_count += 1
                self.__is_ready = False

        # MVD
        elif opcode == 2:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 1)
        
        # MVS
        elif opcode == 3:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__ar = self.__gpr[fl_rn]
                self.__update_fr(0)
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 1)
        
        # MVI
        elif opcode == 4:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + (self.__pc & 255)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = self.__pc
            
            elif self.__instruction_cycle == 2:  # Cycle 3
                self.__instruction_cycle += 1
            
            elif self.__instruction_cycle == 3:  # Cycle 4
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__mem[self.__mar]
                self.__pc += 1
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 4)
        
        # MVB
        elif opcode == 5:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__br = self.__gpr[fl_rn]
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 1)
        
        # STR
        elif opcode == 6:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + self.__ar
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 255) + (self.__br << 8)
            
            elif self.__instruction_cycle == 2:  # Cycle 3
                self.__instruction_cycle += 1
            
            elif self.__instruction_cycle == 3:  # Cycle 4
                self.__instruction_cycle += 1
                self.__mem[self.__mar] = self.__gpr[fl_rn]
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 4)
        
        # LOD
        elif opcode == 7:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + self.__ar
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 255) + (self.__br << 8)
            
            elif self.__instruction_cycle == 2:  # Cycle 3
                self.__instruction_cycle += 1
            
            elif self.__instruction_cycle == 3:  # Cycle 4
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__mem[self.__mar]
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 4)
        
        # NOT
        elif opcode == 8:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__ar = self.__gpr[fl_rn] ^ 255
                self.__update_fr(0)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # INC
        elif opcode == 9:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                sum = self.__gpr[fl_rn] + 1
                carry = 1 if sum > 255 else 0
                self.__ar = sum & 255
                self.__update_fr(carry)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # DCR
        elif opcode == 10:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__ar = (self.__gpr[fl_rn] - 1) & 255
                self.__update_fr(0)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # ADA
        elif opcode == 11:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__or = self.__gpr[fl_rn]
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                sum = self.__ar + self.__or + self.__fr[3]
                carry = 1 if sum > 255 else 0
                self.__ar = sum & 255
                self.__update_fr(carry)
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # SBA
        elif opcode == 12:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__or = self.__gpr[fl_rn]
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__ar = (self.__ar - self.__or - self.__fr[3]) & 255
                self.__update_fr(0)
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # XRA
        elif opcode == 13:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__or = self.__gpr[fl_rn]
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__ar = (self.__ar ^ self.__or) & 255
                self.__update_fr(0)
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # ANA
        elif opcode == 14:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__or = self.__gpr[fl_rn]
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__ar = (self.__ar & self.__or) & 255
                self.__update_fr(0)
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # ORA
        elif opcode == 15:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__or = self.__gpr[fl_rn]
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__ar = (self.__ar | self.__or) & 255
                self.__update_fr(0)
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # ADI
        elif opcode == 16:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + (self.__pc & 255)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = self.__pc
            
            elif self.__instruction_cycle == 2:  # Cycle 3
                self.__instruction_cycle += 1
            
            elif self.__instruction_cycle == 3:  # Cycle 4
                self.__instruction_cycle += 1
                self.__or = self.__mem[self.__mar]
                self.__pc += 1
            
            elif self.__instruction_cycle == 4:  # Cycle 5
                self.__instruction_cycle += 1
                sum = self.__gpr[fl_rn] + self.__or + self.__fr[3]
                carry = 1 if sum > 255 else 0
                self.__ar = sum & 255
                self.__update_fr(carry)
            
            elif self.__instruction_cycle == 5:  # Cycle 6
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 6)
        
        # SBI
        elif opcode == 17:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + (self.__pc & 255)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = self.__pc
            
            elif self.__instruction_cycle == 2:  # Cycle 3
                self.__instruction_cycle += 1
            
            elif self.__instruction_cycle == 3:  # Cycle 4
                self.__instruction_cycle += 1
                self.__or = self.__mem[self.__mar]
                self.__pc += 1
            
            elif self.__instruction_cycle == 4:  # Cycle 5
                self.__instruction_cycle += 1
                self.__ar = (self.__gpr[fl_rn] - self.__or - self.__fr[3]) & 255
                self.__update_fr(0)
            
            elif self.__instruction_cycle == 5:  # Cycle 6
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 6)
        
        # XRI
        elif opcode == 18:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + (self.__pc & 255)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = self.__pc
            
            elif self.__instruction_cycle == 2:  # Cycle 3
                self.__instruction_cycle += 1
            
            elif self.__instruction_cycle == 3:  # Cycle 4
                self.__instruction_cycle += 1
                self.__or = self.__mem[self.__mar]
                self.__pc += 1
            
            elif self.__instruction_cycle == 4:  # Cycle 5
                self.__instruction_cycle += 1
                self.__ar = (self.__gpr[fl_rn] ^ self.__or) & 255
                self.__update_fr(0)
            
            elif self.__instruction_cycle == 5:  # Cycle 6
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 6)
        
        # ANI
        elif opcode == 19:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + (self.__pc & 255)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = self.__pc
            
            elif self.__instruction_cycle == 2:  # Cycle 3
                self.__instruction_cycle += 1
            
            elif self.__instruction_cycle == 3:  # Cycle 4
                self.__instruction_cycle += 1
                self.__or = self.__mem[self.__mar]
                self.__pc += 1
            
            elif self.__instruction_cycle == 4:  # Cycle 5
                self.__instruction_cycle += 1
                self.__ar = (self.__gpr[fl_rn] & self.__or) & 255
                self.__update_fr(0)
            
            elif self.__instruction_cycle == 5:  # Cycle 6
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 6)
        
        # ORI
        elif opcode == 20:
            if self.__instruction_cycle == 0:    # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + (self.__pc & 255)
            
            elif self.__instruction_cycle == 1:  # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = self.__pc
            
            elif self.__instruction_cycle == 2:  # Cycle 3
                self.__instruction_cycle += 1
            
            elif self.__instruction_cycle == 3:  # Cycle 4
                self.__instruction_cycle += 1
                self.__or = self.__mem[self.__mar]
                self.__pc += 1
            
            elif self.__instruction_cycle == 4:  # Cycle 5
                self.__instruction_cycle += 1
                self.__ar = (self.__gpr[fl_rn] | self.__or) & 255
                self.__update_fr(0)
            
            elif self.__instruction_cycle == 5:  # Cycle 6
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 6)
        
        # JPD
        elif opcode == 21:
            if self.__fr[fl_rn] == 1:
                if self.__instruction_cycle == 0:    # Cycle 1
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__pc & 255)
                
                elif self.__instruction_cycle == 1:  # Cycle 2
                    self.__instruction_cycle += 1
                    self.__mar = self.__pc
                
                elif self.__instruction_cycle == 3:  # Cycle 4
                    self.__instruction_cycle += 1
                    ram_out = self.__mem[self.__mar] & 255
                    self.__pc = (self.__pc & 65280) + ram_out
                    self.__mar = (self.__mar & 65280) + ram_out
                    self.__ar = 0
                
                elif self.__instruction_cycle == 4:  # Cycle 5
                    self.__instruction_cycle += 1
                    self.__pc &= 255
                    self.__mar &= 255
                
                elif self.__instruction_cycle == 5:  # Cycle 6
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                elif self.__instruction_cycle == 6:  # Cycle 7
                    self.__instruction_cycle += 1
                    self.__ir = self.__mem[self.__mar]
                
                elif self.__instruction_cycle == 9:  # Cycle 10
                    self.__current_instruction = self.__ir
                    self.__instruction_cycle = 0
                    self.__instruction_count += 1
                
                else:
                    self.__instruction_cycle += 1
            
            else:
                if self.__instruction_cycle == 0:    # Cycle 1
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                else:
                    self.__load_next_instruction(self.__instruction_cycle - 1)

        # JPP
        elif opcode == 22:
            if self.__fr[fl_rn] == 1:
                if self.__instruction_cycle == 0:    # Cycle 1
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__pc & 255)
                
                elif self.__instruction_cycle == 1:  # Cycle 2
                    self.__instruction_cycle += 1
                    self.__mar = self.__pc
                
                elif self.__instruction_cycle == 2:  # Cycle 3
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                elif self.__instruction_cycle == 3:  # Cycle 4
                    self.__instruction_cycle += 1
                    self.__or = self.__mem[self.__mar]
                
                elif self.__instruction_cycle == 4:  # Cycle 5
                    self.__instruction_cycle += 1
                    sum = (self.__pc & 255) + self.__or + self.__fr[3]
                    carry = 1 if sum > 255 else 0
                    self.__ar = sum & 255
                    self.__update_fr(carry)
                
                elif self.__instruction_cycle == 5:  # Cycle 6
                    self.__instruction_cycle += 1
                    self.__pc = (self.__pc & 65280) + self.__ar
                    self.__or = 0
                
                elif self.__instruction_cycle == 6:  # Cycle 7
                    self.__instruction_cycle += 1
                    self.__ar = (self.__pc & 65280) + self.__or + self.__fr[3]
                
                elif self.__instruction_cycle == 7:  # Cycle 8
                    self.__instruction_cycle += 1
                    self.__pc = (self.__ar << 8) + (self.__pc & 255)
                
                elif self.__instruction_cycle == 8:  # Cycle 9
                    self.__instruction_cycle += 1
                    self.__or = self.__mem[self.__mar]
                
                elif self.__instruction_cycle == 9:  # Cycle 10
                    self.__instruction_cycle += 1
                    sum = self.__mem[self.__mar] + self.__or + self.__fr[3]
                    carry = 1 if sum > 255 else 0
                    self.__ar = sum & 255
                    self.__update_fr(carry)
                
                elif self.__instruction_cycle == 10:  # Cycle 11
                    self.__instruction_cycle += 1
                    self.__or = 0
                    self.__mar = (self.__mar & 65280) + (self.__pc & 255)
                
                elif self.__instruction_cycle == 11:  # Cycle 12
                    self.__instruction_cycle += 1
                    self.__ar = (((self.__pc >> 8) & 255) - self.__or) & 255
                
                elif self.__instruction_cycle == 12:  # Cycle 13
                    self.__instruction_cycle += 1
                    self.__pc = (self.__ar << 8) + (self.__pc & 255)
                    self.__mar = (self.__ar << 8) + (self.__mar & 255)
                
                elif self.__instruction_cycle == 13:  # Cycle 14
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                elif self.__instruction_cycle == 14:  # Cycle 15
                    self.__instruction_cycle += 1
                    self.__ir = self.__mem[self.__mar]
                
                elif self.__instruction_cycle == 17:  # Cycle 18
                    self.__current_instruction = self.__ir
                    self.__instruction_cycle = 0
                    self.__instruction_count += 1
                
                else:
                    self.__instruction_cycle += 1
            
            else:
                if self.__instruction_cycle == 0:    # Cycle 1
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                else:
                    self.__load_next_instruction(self.__instruction_cycle - 1)
        
        # JPR
        elif opcode == 23:
            if self.__fr[fl_rn] == 1:
                if self.__instruction_cycle == 0:    # Cycle 1
                    self.__instruction_cycle += 1
                    self.__pc = (self.__pc & 65280) + self.__ar
                    self.__mar = (self.__mar & 65280) + self.__ar
                
                elif self.__instruction_cycle == 1:  # Cycle 2
                    self.__instruction_cycle += 1
                    self.__ar = 0
                
                elif self.__instruction_cycle == 2:  # Cycle 3
                    self.__instruction_cycle += 1
                    self.__pc &= 255
                    self.__mar &= 255

                elif self.__instruction_cycle == 3:  # Cycle 4
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                elif self.__instruction_cycle == 4:  # Cycle 5
                    self.__instruction_cycle += 1
                    self.__ir = self.__mem[self.__mar]
                
                elif self.__instruction_cycle == 7:  # Cycle 8
                    self.__current_instruction = self.__ir
                    self.__instruction_cycle = 0
                    self.__instruction_count += 1
                
                else:
                    self.__instruction_cycle += 1
            
            else:
                self.__load_next_instruction(self.__instruction_cycle)
        
        # CAD
        elif opcode == 24:
            if self.__fr[fl_rn] == 1:
                if self.__instruction_cycle == 0:     # Cycle 1
                    self.__instruction_cycle += 1
                    self.__sp -= 1
                    sum = (self.__pc & 255) + 1
                    carry = 1 if sum > 255 else 0
                    self.__ar = sum & 255
                    self.__update_fr(carry)

                elif self.__instruction_cycle == 1:   # Cycle 2
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__sp & 255)
                
                elif self.__instruction_cycle == 2:   # Cycle 3
                    self.__instruction_cycle += 1
                    self.__mar = self.__sp
                
                elif self.__instruction_cycle == 4:   # Cycle 5
                    self.__instruction_cycle += 1
                    self.__mem[self.__mar] = self.__ar
                    self.__or = 0

                elif self.__instruction_cycle == 5:   # Cycle 6
                    self.__instruction_cycle += 1
                    self.__sp -= 1
                    self.__ar = ((self.__pc >> 8) & 255) + self.__fr[3]
                
                elif self.__instruction_cycle == 6:   # Cycle 7
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__sp & 255)
                
                elif self.__instruction_cycle == 7:   # Cycle 8
                    self.__instruction_cycle += 1
                    self.__mar = self.__sp
                
                elif self.__instruction_cycle == 9:   # Cycle 10
                    self.__instruction_cycle += 1
                    self.__mem[self.__mar] = self.__ar
                
                elif self.__instruction_cycle == 10:  # Cycle 11
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__pc & 255)
                
                elif self.__instruction_cycle == 11:  # Cycle 12
                    self.__instruction_cycle += 1
                    self.__mar = self.__pc
                
                elif self.__instruction_cycle == 13:  # Cycle 14
                    self.__instruction_cycle += 1
                    ram_out = self.__mem[self.__mar]
                    self.__pc = (self.__pc & 65280) + ram_out
                    self.__mar = (self.__mar & 65280) + ram_out
                    self.__ar = 0
                
                elif self.__instruction_cycle == 14:  # Cycle 15
                    self.__instruction_cycle += 1
                    self.__pc &= 255
                    self.__mar &= 255

                elif self.__instruction_cycle == 15:  # Cycle 16
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                elif self.__instruction_cycle == 16:  # Cycle 17
                    self.__instruction_cycle += 1
                    self.__ir = self.__mem[self.__mar]
                
                elif self.__instruction_cycle == 19:  # Cycle 20
                    self.__current_instruction = self.__ir
                    self.__instruction_cycle = 0
                    self.__instruction_count += 1
                
                else:
                    self.__instruction_cycle += 1
            
            else:
                if self.__instruction_cycle == 0:    # Cycle 1
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                else:
                    self.__load_next_instruction(self.__instruction_cycle - 1)
        
        # CAR
        elif opcode == 25:
            if self.__fr[fl_rn] == 1:
                if self.__instruction_cycle == 0:     # Cycle 1
                    self.__instruction_cycle += 1
                    self.__sp -= 1
                
                elif self.__instruction_cycle == 1:   # Cycle 2
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__sp & 255)
                
                elif self.__instruction_cycle == 2:   # Cycle 3
                    self.__instruction_cycle += 1
                    self.__mar = self.__sp
                
                elif self.__instruction_cycle == 4:   # Cycle 5
                    self.__instruction_cycle += 1
                    self.__mem[self.__mar] = self.__pc & 255
                    self.__sp -= 1
                
                elif self.__instruction_cycle == 5:   # Cycle 6
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__sp & 255)
                
                elif self.__instruction_cycle == 6:   # Cycle 7
                    self.__instruction_cycle += 1
                    self.__mar = self.__sp
                
                elif self.__instruction_cycle == 8:   # Cycle 9
                    self.__instruction_cycle += 1
                    self.__mem[self.__mar] = (self.__pc >> 8) & 255
                
                elif self.__instruction_cycle == 9:   # Cycle 10
                    self.__instruction_cycle += 1
                    self.__pc = (self.__pc & 65280) + self.__ar
                    self.__mar = (self.__mar & 65280) + self.__ar
                
                elif self.__instruction_cycle == 10:  # Cycle 11
                    self.__instruction_cycle += 1
                    self.__ar = 0
                
                elif self.__instruction_cycle == 11:  # Cycle 12
                    self.__instruction_cycle += 1
                    self.__pc &= 255
                    self.__mar &= 255
                
                elif self.__instruction_cycle == 12:  # Cycle 13
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                elif self.__instruction_cycle == 13:  # Cycle 14
                    self.__instruction_cycle += 1
                    self.__ir = self.__mem[self.__mar]
                
                elif self.__instruction_cycle == 16:  # Cycle 17
                    self.__current_instruction = self.__ir
                    self.__instruction_cycle = 0
                    self.__instruction_count += 1
                
                else:
                    self.__instruction_cycle += 1
            
            else:
                self.__load_next_instruction(self.__instruction_cycle)
        
        # RET
        elif opcode == 26:
            if self.__fr[fl_rn] == 1:
                if self.__instruction_cycle == 0:     # Cycle 1
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__sp & 255)
                
                elif self.__instruction_cycle == 1:   # Cycle 2
                    self.__instruction_cycle += 1
                    self.__mar = self.__sp
                
                elif self.__instruction_cycle == 2:   # Cycle 3
                    self.__instruction_cycle += 1
                    self.__sp += 1
                
                elif self.__instruction_cycle == 3:   # Cycle 4
                    self.__instruction_cycle += 1
                    self.__pc = (self.__mem[self.__mar] << 8) + (self.__pc & 255)
                
                elif self.__instruction_cycle == 4:   # Cycle 5
                    self.__instruction_cycle += 1
                    self.__mar = (self.__mar & 65280) + (self.__sp & 255)
                
                elif self.__instruction_cycle == 5:   # Cycle 6
                    self.__instruction_cycle += 1
                    self.__mar = self.__sp
                
                elif self.__instruction_cycle == 6:   # Cycle 7
                    self.__instruction_cycle += 1
                    self.__sp += 1
                
                elif self.__instruction_cycle == 7:   # Cycle 8
                    self.__instruction_cycle += 1
                    ram_out = self.__mem[self.__mar]
                    self.__pc = (self.__pc & 65280) + ram_out
                    self.__mar = (self.__mar & 65280) + ram_out
                
                elif self.__instruction_cycle == 8:   # Cycle 9
                    self.__instruction_cycle += 1
                    self.__mar = self.__pc
                
                elif self.__instruction_cycle == 9:   # Cycle 10
                    self.__instruction_cycle += 1
                    self.__pc += 1
                
                elif self.__instruction_cycle == 10:  # Cycle 11
                    self.__instruction_cycle += 1
                    self.__ir = self.__mem[self.__mar]
                
                elif self.__instruction_cycle == 13:  # Cycle 14
                    self.__current_instruction = self.__ir
                    self.__instruction_cycle = 0
                    self.__instruction_count += 1
                
                else:
                    self.__instruction_cycle += 1
            
            else:
                self.__load_next_instruction(self.__instruction_cycle)
        
        # PSH
        elif opcode == 27:
            if self.__instruction_cycle == 0:     # Cycle 1
                self.__instruction_cycle += 1
                self.__sp -= 1
            
            elif self.__instruction_cycle == 1:   # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + (self.__sp & 255)
            
            elif self.__instruction_cycle == 2:   # Cycle 3
                self.__instruction_cycle += 1
                self.__mar = self.__sp
            
            elif self.__instruction_cycle == 4:   # Cycle 5
                self.__instruction_cycle += 1
                self.__mem[self.__mar] = self.__gpr[fl_rn]
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 5)
        
        # POP
        elif opcode == 28:
            if self.__instruction_cycle == 0:     # Cycle 1
                self.__instruction_cycle += 1
                self.__mar = (self.__mar & 65280) + (self.__sp & 255)
            
            elif self.__instruction_cycle == 1:   # Cycle 2
                self.__instruction_cycle += 1
                self.__mar = self.__sp
            
            elif self.__instruction_cycle == 2:   # Cycle 3
                self.__instruction_cycle += 1
                self.__sp += 1
            
            elif self.__instruction_cycle == 3:   # Cycle 4
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__mem[self.__mar]
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 4)
        
        # RRC
        elif opcode == 29:
            if self.__instruction_cycle == 0:     # Cycle 1
                self.__instruction_cycle += 1
                carry = self.__gpr[fl_rn] & 1
                self.__ar = self.__gpr[fl_rn] >> 1
                self.__update_fr(carry)
            
            elif self.__instruction_cycle == 1:   # Cycle 2
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)
        
        # RLC
        elif opcode == 30:
            if self.__instruction_cycle == 0:     # Cycle 1
                self.__instruction_cycle += 1
                carry = (self.__gpr[fl_rn] >> 7) & 1
                self.__ar = self.__gpr[fl_rn] << 1
                self.__update_fr(carry)
            
            elif self.__instruction_cycle == 1:   # Cycle 2
                self.__instruction_cycle += 1
                self.__gpr[fl_rn] = self.__ar
            
            else:
                self.__load_next_instruction(self.__instruction_cycle - 2)

    def __load_next_instruction(self, cycle):
        if cycle == 0:
            self.__instruction_cycle += 1
            self.__mar = (self.__mar & 65280) + (self.__pc & 255)
        
        elif cycle == 1:
            self.__instruction_cycle += 1
            self.__mar = self.__pc
        
        elif cycle == 2:
            self.__instruction_cycle += 1
            self.__pc += 1
        
        elif cycle == 3:
            self.__instruction_cycle += 1
            self.__ir = self.__mem[self.__mar]
        
        elif cycle == 6:
            self.__current_instruction = self.__ir
            self.__instruction_cycle = 0
            self.__instruction_count += 1
        
        else:
            self.__instruction_cycle += 1

    def __update_fr(self, flag_c):
        # flags Z and NZ
        self.__fr[1] = 1 if self.__ar == 0 else 0
        self.__fr[2] = self.__fr[1] ^ 1

        # flag NC
        self.__fr[3] = flag_c
        self.__fr[4] = flag_c ^ 1

        # flags P and M
        self.__fr[5] = 1 if self.__ar > 0 and self.__ar < 128 else 0
        self.__fr[6] = 1 if self.__ar > 127 else 0

        # flag OP
        self.__fr[7] = sum([(self.__ar & (2**i)) >> i for i in range(7,-1,-1)]) % 2
    
    def __str__(self):
        return 'Instruction count : ' + str(self.__instruction_count) + '\n' + \
               'Cycle count       : ' + str(self.__cycle_count) + '\n\n' + \
               '  MAR    : ' + '{0:04x}'.format(self.__mar    % 65536) + '\n' + \
               '  PC     : ' + '{0:04x}'.format(self.__pc     % 65536) + '\n' + \
               '  SP     : ' + '{0:04x}'.format(self.__sp     % 65536) + '\n' + \
               '  BR     : ' + '{0:02x}'.format(self.__br     % 256)   + '\n' + \
               '  OR     : ' + '{0:02x}'.format(self.__or     % 256)   + '\n' + \
               '  AR     : ' + '{0:02x}'.format(self.__ar     % 256)   + '\n' + \
               '  GPR(0) : ' + '{0:02x}'.format(self.__gpr[0] % 256)   + '\n' + \
               '  GPR(1) : ' + '{0:02x}'.format(self.__gpr[1] % 256)   + '\n' + \
               '  GPR(2) : ' + '{0:02x}'.format(self.__gpr[2] % 256)   + '\n' + \
               '  GPR(3) : ' + '{0:02x}'.format(self.__gpr[3] % 256)   + '\n' + \
               '  GPR(4) : ' + '{0:02x}'.format(self.__gpr[4] % 256)   + '\n' + \
               '  GPR(5) : ' + '{0:02x}'.format(self.__gpr[5] % 256)   + '\n' + \
               '  GPR(6) : ' + '{0:02x}'.format(self.__gpr[6] % 256)   + '\n' + \
               '  GPR(7) : ' + '{0:02x}'.format(self.__gpr[7] % 256)   + '\n' + \
               '  IR     : ' + '{0:02x}'.format(self.__ir % 256)       + '\n' + \
               '  FR(U)  : ' + str(self.__fr[0]) + '\n' + \
               '  FR(Z)  : ' + str(self.__fr[1]) + '\n' + \
               '  FR(NZ) : ' + str(self.__fr[2]) + '\n' + \
               '  FR(C)  : ' + str(self.__fr[3]) + '\n' + \
               '  FR(NC) : ' + str(self.__fr[4]) + '\n' + \
               '  FR(P)  : ' + str(self.__fr[5]) + '\n' + \
               '  FR(M)  : ' + str(self.__fr[6]) + '\n' + \
               '  FR(OP) : ' + str(self.__fr[7]) + '\n'