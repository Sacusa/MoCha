#!/usr/bin/python3
import math
import os
import re
import string
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

# constants
BOOTLOADER_SIZE = 4

# default values for the generated binary
DEFAULT_SP = 65504
DEFAULT_PC = 202
DEFAULT_OUTPUT_FILE = 'a.out'

def main():
    '''
    Parses the commandline arguments and runs the assembler.

    Commandline arguments:
      * -f <type>     : Generates a file of filetype 'type'.
      *                 Possible types are 'coe', 'hex' and 'bin' (default)
      * -sp <value>   : Sets the initial stack pointer value. The default value is 65504.
      * -pc <value>   : Sets the initial program counter value. The default value is 202.
      * -o <filename> : Sets the name for output file. The default name is 'a.out'.
      * -boot         : Prepends bootstrap code to the binary.
      * -h            : Print help/usage menu.
    '''
    input_file = ''
    gen_coe = False
    gen_hex = False
    gen_bin = False
    base_sp = -1
    base_pc = -1
    output_file = ''
    add_boot = False

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
        if sys.argv[0] == '-f':
            # make sure the argument isn't repeated
            if gen_coe or gen_hex or gen_bin:
                print_error('repeated_arg', ['-f'])
                exit(1)

            if len(sys.argv) < 2:
                print_error('no_arg_value', ['-f'])
                exit(1)
            
            # extract the type
            if   sys.argv[1] == 'coe': gen_coe = True
            elif sys.argv[1] == 'hex': gen_hex = True
            elif sys.argv[1] == 'bin': gen_bin = True
            else:
                print_error('invalid_arg_value', ['-f', sys.argv[1]])
                exit(1)
            
            del(sys.argv[:2])

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
            base_sp = int(sys.argv[1])
            if base_sp < 0 or base_sp > 65535:
                print_error('invalid_arg_value', ['-sp', sys.argv[1], '0', '65535'])
                exit(1)

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
                print_error('invalid_arg_value',
                             ['-pc', sys.argv[1], str(BOOTLOADER_SIZE), '65535'])
                exit(1)
            base_pc = int(sys.argv[1])
            if base_pc < BOOTLOADER_SIZE or base_pc > 65535:
                print_error('invalid_arg_value',
                            ['-pc', sys.argv[1], str(BOOTLOADER_SIZE), '65535'])
                exit(1)

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
        
        elif sys.argv[0] == '-boot':
            # make sure the argument isn't repeated
            if add_boot:
                print_error('repeated_arg', ['-boot'])
                exit(1)
            
            add_boot = True
            del(sys.argv[0])

        elif sys.argv[0] == '-h':
            print_error('usage', [])
            exit(0)

        else:
            print_error('invalid_arg', [sys.argv[0]])
            exit(1)

    # print warning if -sp is not given with -boot
    if base_sp != -1 and not add_boot:
        print_error('sp_true_boot_false', [])

    # set default values if not set by user
    if not gen_coe and not gen_hex:
        gen_bin = True
    if base_sp == -1:
        base_sp = DEFAULT_SP
    if base_pc == -1:
        if add_boot:
            base_pc = BOOTLOADER_SIZE
        else:
            base_pc = DEFAULT_PC
    if not output_file:
        # if an absolute path is given in input filename, remove input filename from it
        # and append default output filename to it
        sep_index = input_file.find('/')
        if sep_index != -1:
            sep_index = len(input_file) - input_file[::-1].find('/')
            output_file = input_file[:sep_index]
        output_file += DEFAULT_OUTPUT_FILE
    else:
        # if an absolute path is not given in output filename,
        # prepend input file path (if exists) to it
        if output_file.find('/') == -1:
            sep_index = input_file.find('/')
            if sep_index != -1:
                sep_index = len(input_file) - input_file[::-1].find('/')
                output_file = input_file[:sep_index] + output_file

    assemble(input_file, base_sp, base_pc, gen_coe, gen_hex, gen_bin, output_file, add_boot)

def assemble(ifilename, base_sp, base_pc, gen_coe, gen_hex, gen_bin, ofilename, add_boot):
    '''
    Assemble the program in 'ifilename', writing the output to 'ofilename'.

    Arguments:
      * ifilename: string representing the path of input assembly file
      * base_sp: integer addresses of base value of SP
      * base_pc: integer addresses of base value of PC
      * gen_coe: if true, the output file is formatted in Xilinx coe format
      * gen_hex: if true, the output file is formatted in Intel I8HEX format
      * gen_bin: if true, the output file is a flat binary
      * ofilename: string representing the path of output binary file
      * add_boot: if true, initial PC and SP values are inserted at the start of the binary
    
    Returns: None
    '''
    # compile all the regular expressions
    init_regex()

    # parse input file
    parsed_buffer, program_size = parse_input_file(ifilename, base_pc, add_boot)
    output_file = None
    if gen_bin:
        output_file = open(ofilename, 'wb')
    else:
        output_file = open(ofilename, 'w')

    # add file info for coe files
    if gen_coe:
        output_file.write('memory_initialization_radix=2;\nmemory_initialization_vector=\n')

    if add_boot:
        # write bootstrap code to output buffer
        bootstrap_code = [base_sp >> 8, base_sp & 0xff, base_pc >> 8, base_pc & 0xff]
        pc_value = -1
        for line in bootstrap_code:
            pc_value += 1
            write_out(output_file, pc_value, line, gen_hex, gen_coe, gen_bin)
    
    else:
        # write program size to output buffer
        write_out(output_file, base_pc - 2, program_size >> 8, gen_hex, gen_coe, gen_bin)
        write_out(output_file, base_pc - 1, program_size & 255, gen_hex, gen_coe, gen_bin)

    # set initial pc
    if add_boot:
        pc_value = BOOTLOADER_SIZE - 1
    else:
        pc_value = base_pc - 1

    for line in parsed_buffer:
        pc_value += 1

        # add instructions as comments for coe files
        if gen_coe:
            output_file.write('; [' + str(pc_value) + '] ' + line + '\n')

        # break the instruction into tokens
        tokens = [token.strip() for token in line.split()]

        # the decimal equivalent of the instruction is stored in line_dec
        line_dec = ALL_INST.index(tokens[0]) << 3
        
        if len(tokens) == 1:
            write_out(output_file, pc_value, line_dec, gen_hex, gen_coe, gen_bin)
        else:
            args = get_args(tokens, pc_value)

            # write register/flag number
            line_dec += args[0]
            write_out(output_file, pc_value, line_dec, gen_hex, gen_coe, gen_bin)
            
            # write immediate value, if exists
            if len(tokens) == 3:
                pc_value += 1
                write_out(output_file, pc_value, args[1], gen_hex, gen_coe, gen_bin)

    # add end of file for Intel hex
    if gen_hex:
        output_file.write(to_hex(0, 1, 0) + '\n')
    
    output_file.close()

def parse_input_file(filename, base_pc, add_boot):
    '''
    Parses the file 'filename'.
    
    * Comments and whitespaces are ignored and removed.
    * Syntatical errors, if any, are reported. Parsing stops if an error is encountered.
    * Labels are extracted and corresponding addresses are stored in the dictionary 'label_line'.

    Arguments:
      * filename: path to assemnly file.
      * base_pc: starting PC address of the user code.
    
    Returns: a tuple, containing the following items:
             0: a list of strings representing the parsed user code.
             1: size of the program, in bytes
    '''
    # read the input file into a buffer
    input_file = open(filename, 'r')
    input_file_buffer = input_file.readlines()
    input_file.close()

    line_number = 0         # physical line number in file
    pc_value = base_pc - 1  # the current PC value
    program_size = 0        # size, in bytes, of the user code
    parsed_buffer = []

    # add NOP instructions between bootstrap code and user code
    if add_boot:
        for i in range(BOOTLOADER_SIZE, base_pc):
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
            program_size += 1

            # additional increase in line number and program size for two-argument instructions
            if is_imm_val_inst(line):
                pc_value += 1
                program_size += 1
        else:
            print_error('invalid_inst', [filename, str(line_number), line])
            exit(1)
    
    return (parsed_buffer, program_size)

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
        if is_val(tokens[2]):
            arg = int(tokens[2], 0)
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

def write_out(ofile, pc_value, dec_value, gen_hex, gen_coe, gen_bin):
    if gen_hex:
        ofile.write(to_hex(pc_value, 0, dec_value) + '\n')
    elif gen_coe:
        ofile.write('{0:08b}'.format(dec_value) + ',\n')
    elif gen_bin:
        ofile.write(bytearray([dec_value]))

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
    for opcode in (set(ALL_INST) - IMM_VAL_INST - FLAG_INST - {'NOP','STP'}):
        INST_REGEX += r'(' + opcode + r')|'
    INST_REGEX = INST_REGEX[:-1] + r')\s+[0-7])|(NOP)|(STP)|(('

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
    IMM_VAL_INST_REGEX = IMM_VAL_INST_REGEX[:-1] + r')\s+[0-7]\s+((0x[0-9a-fA-F]+)|(\d+)))|(('

    # prepare regex for double byte instructions that can use labels
    # NOTE: such instructions also already use flags
    for opcode in LABEL_ADDR_INST:
        IMM_VAL_INST_REGEX += r'(' + opcode + r')|'
    IMM_VAL_INST_REGEX = IMM_VAL_INST_REGEX[:-1] + r')\s+(('
    for flag in ALL_FLAGS:
        IMM_VAL_INST_REGEX += r'(' + flag + r')|'
    IMM_VAL_INST_REGEX = IMM_VAL_INST_REGEX[:-1] + \
                         r')|[0-7])\s+((0x[0-9a-fA-F]+)|(\d+)|([a-zA-Z](.*)))))\s*'

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

def is_val(num):
    '''
    Returns True if the string 'num' represents a decimal or hexadecimal integer. False, otherwise.
    '''
    return is_num(num) or is_hex(num)

def is_num(num):
    '''
    Returns True if the string 'num' consists entirely of an integer. False, otherwise.
    '''
    return all(char.isdigit() for char in num)

def is_hex(num):
    '''
    Returns True if the string 'num' consists entirely of a hex value starting with '0x'.
    False, otherwise.
    '''
    return num.startswith('0x') and all(char in string.hexdigits for char in num[2:])

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
        err_msg = 'Usage: asm <input file> [-f <type>] [-sp <base SP value>]' + \
                  ' [-pc <base PC value>] [-o <name>] [-boot] [-h]\n\nArguments:\n' + \
                  '  -f <type>   : Generates a file of filetype \'type\'. ' + \
                  'Possible types are \'coe\', \'hex\' and \'bin\' (default).\n' + \
                  '  -sp <value> : Set the initial stack pointer value. Default is ' + \
                  str(DEFAULT_SP) + '.\n' + \
                  '  -pc <value> : Set the initial program counter value. Default is ' + \
                  str(DEFAULT_PC) + '.\n' + \
                  '  -o <name>   : Sets the output file name. Default is \'' + \
                  DEFAULT_OUTPUT_FILE + '\'.\n' + \
                  '  -boot       : Prepends bootstrap code to the binary.\n' + \
                  '  -h          : Print this screen.\n'

    elif err_type == 'input_file_absent':
        err_msg = 'asm: error: \'' + err_args[0] + '\' does not exist.'

    elif err_type == 'repeated_arg':
        err_msg = 'asm: error: repeated argument \'' + err_args[0] + '\'.'

    elif err_type == 'no_arg_value':
        err_msg = 'asm: error: no value provided for flag \'' + err_args[0] + '\'.'
    
    elif err_type == 'invalid_arg_value':
        err_msg = 'asm: error: invalid value of \'' + err_args[1] + \
                  '\' for flag \'' + err_args[0] + '\'.'
        if len(err_args) == 4:
            err_msg += ' error: Expected value between ' + err_args[2] + \
                       ' and ' + err_args[3] + ' inclusive.'
    
    elif err_type == 'invalid_arg':
        err_msg = 'asm: error: invalid argument \'' + err_args[0] + '\'.'
    
    elif err_type == 'sp_true_boot_false':
        err_msg = 'asm: warn: provided value of SP will have no effect without ' + \
                  'the -boot flag.'
    
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
