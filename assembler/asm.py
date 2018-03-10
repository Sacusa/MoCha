#!/usr/bin/python3
import math
import os
import re
import sys

# ordered tuple of all instructions
ALL_INST = ('NOP', 'STP', 'MVD', 'MVS', 'MVI', 'MVB', 'STR', 'LOD', 'NOT', 'INC', 'DCR', 'ADA',
            'SBA', 'XRA', 'ANA', 'ORA', 'ADI', 'SBI', 'XRI', 'ANI', 'ORI', 'JPD', 'JPP', 'JPR',
            'CAD', 'CAR', 'RET', 'PSH', 'POP', 'RRC', 'RLC')

# set of instructions that have immediate values
IMM_VAL_INST = {'MVI', 'ADI', 'SBI', 'XRI', 'ANI', 'ORI', 'JPD', 'JPP', 'CAD'}

# set of instructions that use flags
FLAG_INST = {'JPD', 'JPP', 'JPR', 'CAD', 'CAR', 'RET'}

# set of instructions that can use labels for addresses
LABEL_ADDR_INST = {'JPD', 'JPP', 'CAD'}

# set of instructions that use PC-relative addressing
PC_REL_ADDR_INST = {'JPP'}

# ordered tuple of all flags
ALL_FLAGS = ('U', 'Z', 'NZ', 'C', 'NC', 'P', 'M', 'OP')

# dictionary containing labels and corresponding line numbers
label_line = {}

# regular expressions for error detection
LABEL_REGEX = ''
INST_REGEX = ''
IMM_VAL_INST_REGEX = ''

# default values for the generated binary
DEFAULT_SP = 65504
DEFAULT_PC = 4
DEFAULT_OUTPUT_FILE = 'a.out'

def main():
    '''
    Parses the commandline arguments and runs the assembler.

    Commandline arguments:
      * -coe          : Generates a coe file for Xilinx ISE.
      * -hex          : Generates a binary file in Intel hex (I8HEX) format.
      * -sp <value>   : Sets the initial stack pointer value. The default value is 65504.
      * -pc <value>   : Sets the initial program counter value. The default value is 4.
      * -o <filename> : Give the name for output file. The default name is 'a.out'.
      * -h            : Print help/usage menu.
    '''
    input_file = ''
    gen_coe = False
    gen_hex = False
    base_sp = -1
    base_pc = -1
    output_file = ''

    if len(sys.argv) < 2:
        print_error('usage', [])
        exit(1)
    
    # check if the argument is '-h'
    if sys.argv[1] == '-h':
        print_error('usage', [])
        exit(0)
    
    # extract input filename
    input_file = sys.argv[1]
    del(sys.argv[:2])

    # make sure the input file exists
    if not os.path.isfile(input_file):
        print_error('input_file_absent', [input_file])
        exit(1)

    while sys.argv:
        if sys.argv[0] == '-coe':
            # make sure the argument isn't repeated
            if gen_coe:
                print_error('repeated_arg', ['-coe'])
                exit(1)
            
            # make sure gen_hex is false
            if gen_hex:
                print_error('coe_hex_together', [])
                exit(1)
            
            gen_coe = True
            del(sys.argv[0])
        
        elif sys.argv[0] == '-hex':
            # make sure the argument isn't repeated
            if gen_hex:
                print_error('repeated_arg', ['-h'])
                exit(1)
            
            # make sure gen_coe is false
            if gen_coe:
                print_error('coe_hex_together', [])
                exit(1)
            
            gen_hex = True
            del(sys.argv[0])
        
        elif sys.argv[0] == '-sp':
            # make sure the argument isn't repeated
            if base_sp != -1:
                print_error('repeated_arg', ['-sp'])
                exit(1)
            
            # make sure a value is provided
            if len(sys.argv) < 2:
                print_error('no_arg_value', ['-sp'])
                exit(1)
            
            # make sure the supplied value is valid
            if not is_num(sys.argv[1]):
                print_error('invalid_arg_value', ['-sp', sys.argv[1], '0', '65535'])
                exit(1)
            new_sp = int(sys.argv[1])
            if new_sp < 0 or new_sp > 65535:
                print_error('invalid_arg_value', ['-sp', sys.argv[1], '0', '65535'])
                exit(1)

            base_sp = new_sp
            del(sys.argv[:2])
        
        elif sys.argv[0] == '-pc':
            # make sure the argument isn't repeated
            if base_pc != -1:
                print_error('repeated_arg', ['-pc'])
                exit(1)
            
            # make sure a value is provided
            if len(sys.argv) < 2:
                print_error('no_arg_value', ['-pc'])
                exit(1)

            # make sure the supplied value is valid
            if not is_num(sys.argv[1]):
                print_error('invalid_arg_value', ['-pc', sys.argv[1], '4', '65535'])
                exit(1)
            new_pc = int(sys.argv[1])
            if new_pc < 4 or new_pc > 65535:
                print_error('invalid_arg_value', ['-pc', sys.argv[1], '4', '65535'])
                exit(1)

            base_pc = new_pc
            del(sys.argv[:2])

        elif sys.argv[0] == '-o':
            # make sure the argument isn't repeated
            if output_file:
                print_error('repeated_arg', ['-o'])
                exit(1)

            # make sure a value is provided
            if len(sys.argv) < 2:
                print_error('no_arg_value', ['-o'])
                exit(1)

            output_file = sys.argv[1]
            del(sys.argv[:2])
        
        elif sys.argv[0] == '-h':
            print_error('usage', [])
            exit(0)

        else:
            print_error('invalid_arg', [sys.argv[0]])
            exit(1)

    # set default values if not set by user
    if base_sp == -1:
        base_sp = DEFAULT_SP
    if base_pc == -1:
        base_pc = DEFAULT_PC
    if not output_file:
        # if an absolute path is given, remove input filename from it
        sep_index = input_file.find('/')
        if sep_index != -1:
            sep_index = len(input_file) - input_file[::-1].find('/')
            output_file = input_file[:sep_index]
        
        output_file += DEFAULT_OUTPUT_FILE

    assemble(input_file, base_sp, base_pc, gen_coe, gen_hex, output_file)

def assemble(input_file_name, base_sp, base_pc, gen_coe, gen_hex, output_file_name):
    '''
    Assemble the program in 'input_file_name', writing the output to 'output_file_name'.

    Arguments:
      * input_file_name: string representing the path of input assembly file
      * base_sp: integer addresses of base value of SP
      * base_pc: integer addresses of base value of PC
      * gen_coe: if true, the output file is formatted in Xilinx coe format
      * gen_hex: if true, the output file is formatted in Intel I8HEX format
      * output_file_name: string representing the path of output binary file
    
    Returns: None
    '''
    # compile all the regular expressions
    init_regex()

    # parse input file
    parsed_buffer = parse_input_file(input_file_name, base_pc)
    output_file_buffer = ''

    # add file info for coe files
    if gen_coe:
        output_file_buffer = 'memory_initialization_radix=2;\nmemory_initialization_vector=\n'

    # prepare bootstrap code
    bootstrap_code = [base_sp >> 8, base_sp & 0xff, base_pc >> 8, base_pc & 0xff]

    # write bootstrap code to output buffer
    pc_value = -1
    for line in bootstrap_code:
        pc_value += 1

        if gen_hex:
            output_file_buffer += to_hex(pc_value, 0, line)
        else:
            output_file_buffer += '{0:08b}'.format(line)

        if gen_coe:  # append comma for coe files
            output_file_buffer += ','

        output_file_buffer += '\n'

    pc_value = DEFAULT_PC - 1
    nop_buffer_complete = base_pc == DEFAULT_PC  # true if the buffer NOPs between bootstrap and
                                                 # user code have been inserted

    for line in parsed_buffer:
        pc_value += 1

        # check if the buffer NOPs have all been inserted
        if not nop_buffer_complete:
            if line != 'NOP':
                nop_buffer_complete = True

        # add instructions as comments for coe files, except for buffer NOPs
        if gen_coe and nop_buffer_complete:
            output_file_buffer += '; [' + str(pc_value) + '] ' + line + '\n'

        # break the instruction into tokens
        tokens = [token.strip() for token in line.split()]

        # the decimal equivalent of the instruction is stored in line_dec and
        # the binary equivalent is stored in line_bin
        line_dec = ALL_INST.index(tokens[0]) << 3
        line_bin = ''
        
        if len(tokens) == 1:
            if gen_hex:
                line_bin = to_hex(pc_value, 0, line_dec)
            else:
                line_bin = '{0:08b}'.format(line_dec)
        else:
            args = get_args(tokens, pc_value)

            # write register/flag number
            line_dec += args[0]
            if gen_hex:
                line_bin = to_hex(pc_value, 0, line_dec)
            else:
                line_bin = '{0:08b}'.format(line_dec)
            
            # write immediate value, if exists
            if len(tokens) == 3:
                pc_value += 1
                if gen_coe:  # append comma for coe files
                    line_bin += ','
                if gen_hex:
                    line_bin += '\n' + to_hex(pc_value, 0, args[1])
                else:
                    line_bin += '\n' + '{0:08b}'.format(args[1])
        
        if gen_coe:  # append comma for coe files
            line_bin += ','
        
        output_file_buffer += line_bin + '\n'

    # add end of file for Intel hex
    if gen_hex:
        output_file_buffer += to_hex(0, 1, 0) + '\n'
    
    # write the buffer into output file
    output_file = open(output_file_name, 'w')
    output_file.write(output_file_buffer)
    output_file.close()

def parse_input_file(filename, base_pc):
    '''
    Parses the file 'filename'.
    
    * Comments and whitespaces are ignored and removed.
    * Syntatical errors, if any, are reported. Parsing stops if an error is encountered.
    * Labels are extracted and corresponding addresses are stored in the dictionary 'label_line'.

    Arguments:
      * filename: path to assemnly file.
      * base_pc: starting PC address of the user code.
    
    Returns: a list of strings representing the parsed user code.
    '''
    # read the input file into a buffer
    input_file = open(filename, 'r')
    input_file_buffer = input_file.readlines()
    input_file.close()

    line_number = 0         # this represents physical line number in file
    pc_value = base_pc - 1  # this represents the current PC value
    parsed_buffer = []

    # add NOP instructions between bootstrap code and user code
    for i in range(DEFAULT_PC, base_pc):
        parsed_buffer += ['NOP']

    for line in input_file_buffer:
        line_number += 1

        # remove whitespaces and newlines
        line = line.strip()

        # skip over empty lines or comment line
        if (len(line) == 0) or line.startswith(';'):
            continue

        # remove in-line comments
        comment_index = line.find(';')
        if comment_index != -1:
            line = line[:comment_index]

        if is_label(line):
            label_line[line[:-1]] = pc_value + 1
        elif is_valid_inst(line):
            parsed_buffer += [line]
            pc_value += 1

            # additional increase in line number for two-argument instructions
            if is_imm_val_inst(line):
                pc_value += 1
        else:
            print_error('invalid_inst', [filename, str(line_number), line])
            exit(1)
    
    return parsed_buffer

def get_args(tokens, pc_value):
    '''
    Parses the instruction tokens and extracts the arguments.
    
    Arguments:
      * tokens: list of strings representing the tokenized instruction. Size > 1.
      * pc_value: decimal value representing the PC value for this instruction.
    
    Returns: instruction arguments as decimal numbers in a list.
    '''
    # extract and convert the first argument
    args = [ALL_FLAGS.index(tokens[1]) if tokens[0] in FLAG_INST else int(tokens[1])]
    
    # extract and convert the second argument, if it exists
    if len(tokens) == 3:
        arg = 0
        if is_num(tokens[2]):
            arg = int(tokens[2])
        else:
            if tokens[0] in PC_REL_ADDR_INST:
                # instructions that use PC-relative addresses
                arg = label_line[tokens[2]] - pc_value - 2
            elif tokens[0] in LABEL_ADDR_INST:
                # instructions that use direct addresses
                arg = label_line[tokens[2]]
            else:
                # fatal error
                print_error('invalid_imm_value', [tokens[0]])
                exit(1)
                
        args.append(arg % 256)
    
    return args

def to_hex(address, record_type, data):
    '''
    Converts the data into Intel I8HEX format according to 'address' and 'record_type'.

    Arguments:
      * address: address offset of the data record.
      * record_type: the type of data record. Must be 0 or 1. For EOF records, data and address
                     are ignored.
      * data: the data record to encode.
    
    Returns: a string representing the data in Intel I8HEX format.
    '''
    byte_count = 0
    checksum = 0
    hex_value = ':'

    # Data record
    if record_type == 0:
        byte_count = math.ceil(len(hex(data)[2:])/2)
        hex_value += '{0:02x}'.format(byte_count) + \
                     '{0:04x}'.format(address) + \
                     '00' + \
                     hex(data)[2:].rjust(byte_count*2, '0')

        # calculate checksum
        for val in [byte_count, address, data]:
            while val:
                checksum += (val & 0xff)
                val >>= 8
            checksum &= 0xff
        checksum = '{0:02x}'.format((~checksum + 1) & 0xff)
        hex_value += checksum + ' '

    # End Of File record
    elif record_type == 1:
        hex_value = ':00000001ff'

    else:
        print_error('invalid_hex_record_type', [record_type])
        exit(1)

    return hex_value

def init_regex():
    '''
    Compile regular expressions. The compiled regular expressions are stored back into the global
    string objects.

    Arguments: None
    Returns: None
    '''
    global LABEL_REGEX
    global INST_REGEX
    global IMM_VAL_INST_REGEX

    # prepare and compile regex for labels
    LABEL_REGEX = re.compile('[a-zA-Z](.*):')

    # prepare regex for all single byte instructions, except that cannot use flags
    INST_REGEX = r'\s*((('
    for opcode in (set(ALL_INST) - IMM_VAL_INST - FLAG_INST - {'STP'}):
        INST_REGEX += r'(' + opcode + r')|'
    INST_REGEX = INST_REGEX[:-1] + r')\s+[0-7])|(STP)|(('

    # prepare regex for single byte instructions that can use flags
    for opcode in (FLAG_INST - IMM_VAL_INST):
        INST_REGEX += r'(' + opcode + r')|'
    INST_REGEX = INST_REGEX[:-1] + r')\s+(('
    for flag in ALL_FLAGS:
        INST_REGEX += r'(' + flag + r')|'
    INST_REGEX = INST_REGEX[:-1] + r')|[0-7]))|(('
    
    # prepare regex for all double byte instructions, except that can use flags or labels
    IMM_VAL_INST_REGEX = '\s*((('
    for opcode in (IMM_VAL_INST - FLAG_INST - LABEL_ADDR_INST):
        IMM_VAL_INST_REGEX += r'(' + opcode + r')|'
    IMM_VAL_INST_REGEX = IMM_VAL_INST_REGEX[:-1] + r')\s+[0-7]\s+\d+)|(('

    # prepare regex for double byte instructions that can use labels
    # NOTE: such instructions also already use flags
    for opcode in LABEL_ADDR_INST:
        IMM_VAL_INST_REGEX += r'(' + opcode + r')|'
    IMM_VAL_INST_REGEX = IMM_VAL_INST_REGEX[:-1] + r')\s+(('
    for flag in ALL_FLAGS:
        IMM_VAL_INST_REGEX += r'(' + flag + r')|'
    IMM_VAL_INST_REGEX = IMM_VAL_INST_REGEX[:-1] + r')|[0-7])\s+((\d+)|([a-zA-Z]\w*))))\s*'

    INST_REGEX += IMM_VAL_INST_REGEX[6:]

    # compile regex for instructions
    INST_REGEX = re.compile(INST_REGEX)
    IMM_VAL_INST_REGEX = re.compile(IMM_VAL_INST_REGEX)

def is_label(line):
    '''
    Returns true if the string 'line' represents a valid label. False, otherwise.
    '''
    m = LABEL_REGEX.match(line)
    if m:
        return m.group() == line
    
    return False

def is_valid_inst(line):
    '''
    Returns true if the string 'line' represents a valid instruction. False, otherwise.
    '''
    m = INST_REGEX.match(line)
    if m:
        return m.group() == line
    
    return False

def is_imm_val_inst(line):
    '''
    Returns true if the string 'line' represents a valid 2B instruction. False, otherwise.
    '''
    m = IMM_VAL_INST_REGEX.match(line)
    if m:
        return m.group() == line
    
    return False

def is_num(num):
    '''
    Returns True if the string 'num' consists entirely of an integer. False, otherwise.
    '''
    return all(char.isdigit() for char in num)


def print_error(err_type, err_args):
    '''
    Prints error message according to 'err_type'. Additional arguments for every error are
    passed in the list 'err_args'.

    Arguments:
      * err_type: string representing the error type
      * err_args: list of arguments for the error
    
    Returns: None
    '''
    err_msg = ''

    if err_type == 'usage':
        err_msg = 'Usage: asm <input file> [-coe] [-hex] [-sp <base SP value>]' + \
                  ' [-pc <base PC value>] [-o <output file>] [-h]\n\nArguments:\n' + \
                  '  -coe: Generate a coe file for Xilinx ISE.\n' + \
                  '  -hex: Generate a binary file in Intel hex (I8HEX) format.\n' + \
                  '  -sp <value>: Set the initial stack pointer value. Default is 65504.\n' + \
                  '  -pc <value>: Set the initial program counter value. Default is 4.\n' + \
                  '  -h: Print this screen.\n'

    elif err_type == 'input_file_absent':
        err_msg = 'asm: \'' + err_args[0] + '\' does not exist.'

    elif err_type == 'repeated_arg':
        err_msg = 'asm: repeated argument \'' + err_args[0] + '\'.'
    
    elif err_type == 'coe_hex_together':
        err_msg = 'asm: -coe and -hex cannot be used together.'

    elif err_type == 'no_arg_value':
        err_msg = 'asm: no value provided for flag \'' + err_args[0] + '\'.'
    
    elif err_type == 'invalid_arg_value':
        err_msg = 'asm: invalid value of \'' + err_args[1] + \
                  '\' for flag \'' + err_args[0] + '\'.'
        if len(err_args) == 4:
            err_msg += ' Expected value between ' + err_args[2] + \
                       ' and ' + err_args[3] + ' inclusive.'
    
    elif err_type == 'invalid_arg':
        err_msg = 'asm: invalid argument \'' + err_args[0] + '\'.'
    
    elif err_type == 'invalid_inst':
        err_msg = err_args[0] + ':' + err_args[1] + ': error: invalid instruction \'' + \
                  err_args[2] + '\'.'
    
    elif err_type == 'invalid_hex_record_type':
        err_msg = 'asm: internal error: invalid record type \'' + err_args[0] + \
                  '\' for I8HEX format.'
    
    elif err_type == 'invalid_imm_value':
        err_msg = 'asm: internal error: encountered immediate value in instruction \'' + \
                  err_args[0] + '\', which does not use either immediate values or labels.'
    
    print(err_msg)

if __name__ == '__main__':
    main()
