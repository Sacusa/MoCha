#!/usr/bin/python
import sys
import os
import re

# list of instructions that use flags
FLAG_INST = ['JPD', 'JPP', 'JPR', 'CAD', 'CAR', 'RET']

# list of instructions that can use labels for immediate addresses
DIRECT_ADDR_INST = ['JPD', 'CAD']

# list of instructions that have two arguments
TWO_ARG_INST = ['MVI', 'ADI', 'SBI', 'XRI', 'ANI', 'ORI', 'JPD', 'JPP', 'CAD']

# dictionary of binary equivalents of op codes
OPCODE_BIN = {'NOP' : '00000', 'STP' : '00001', 'MVD' : '00010', 'MVS' : '00011', 'MVI' : '00100',
              'MVB' : '00101', 'STR' : '00110', 'LOD' : '00111', 'NOT' : '01000', 'INC' : '01001',
              'DCR' : '01010', 'ADA' : '01011', 'SBA' : '01100', 'XRA' : '01101', 'ANA' : '01110',
              'ORA' : '01111', 'ADI' : '10000', 'SBI' : '10001', 'XRI' : '10010', 'ANI' : '10011',
              'ORI' : '10100', 'JPD' : '10101', 'JPP' : '10110', 'JPR' : '10111', 'CAD' : '11000',
              'CAR' : '11001', 'RET' : '11010', 'PSH' : '11011', 'POP' : '11100', 'RRC' : '11101',
              'RLC' : '11110'}

# dictionary of binary equivalents of flag names
FLAG_BIN = {'U'  : '000', 'Z' : '001', 'NZ' : '010', 'C'  : '011',
            'NC' : '100', 'P' : '101', 'M'  : '110', 'OP' : '111'}

# dictionary containing labels and corresponding line numbers
label_line = {}

# label format regex
LABEL_REGEX = r'(.+):'

# default values for the generated binary
DEFAULT_SP = 65504
DEFAULT_PC = 4
DEFAULT_OUTPUT_FILE = 'a.out'

def main():
    '''
    Runs the assembler. Parses the commandline arguments and runs the assembler.

    Commandline arguments:
      * -coe          : Generates a coe file for Xilinx ISE.
      * -sp <value>   : Sets the initial stack pointer value. The default value is 65504.
      * -pc <value>   : Sets the initial program counter value. The default value is 4.
      * -o <filename> : Give the name for output file. The default name is 'a.out'.
    '''
    input_file = ''
    gen_coe = False
    base_sp = -1
    base_pc = -1
    output_file = ''

    if len(sys.argv) < 2:
        print_error('usage', [])
        exit(1)
    
    # extract input filename
    input_file = sys.argv[1]
    del(sys.argv[0:2])

    # make sure the input file exists
    if not os.path.isfile(input_file):
        print_error('input_file_absent', [input_file])
        exit(1)

    while sys.argv:
        if sys.argv[0] == '-coe':
            # make sure the argument isn't repeated
            if gen_coe == True:
                print_error('repeated_arg', ['-coe'])
                exit(1)
            
            gen_coe = True
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
            new_pc = int(sys.argv[1])
            if new_pc < 0 or new_pc > 65535:
                print_error('invalid_arg_value', ['-pc', sys.argv[1], '0', '65535'])
                exit(1)

            base_pc = new_pc
            del(sys.argv[:2])
        
        elif sys.argv[0] == '-o':
            # make sure the argument isn't repeated
            if output_file != '':
                print_error('repeated_arg', ['-o'])
                exit(1)
            
            # make sure a value is provided
            if len(sys.argv) < 2:
                print_error('no_arg_value', ['-o'])
                exit(1)

            output_file = sys.argv[1]
            del(sys.argv[:2])
        
        else:
            print_error('invalid_arg', [sys.argv[0]])
            exit(1)
    
    # set default values if not set by user
    if base_sp == -1:
        base_sp = DEFAULT_SP
    if base_pc == -1:
        base_pc = DEFAULT_PC
    if not output_file:
        output_file = DEFAULT_OUTPUT_FILE

    print(input_file)
    print(gen_coe)
    print(base_sp)
    print(base_pc)
    print(output_file)

def print_error(err_type, err_args):
    err_msg = ''

    if err_type == 'usage':
        err_msg = 'Usage: assembler <input asm file> <base SP value> <base PC value>'

    elif err_type == 'input_file_absent':
        err_msg = 'Error: \'' + err_args[0] + '\' does not exist.'

    elif err_type == 'repeated_arg':
        err_msg = 'Error: Repeated argument \'' + err_args[0] + '\'.'
    
    elif err_type == 'no_arg_value':
        err_msg = 'Error: No value provided for the flag \'' + err_args[0] + '\'.'
    
    elif err_type == 'invalid_arg_value':
        err_msg = 'Error: Invalid value of \'' + err_args[1] + \
                  '\' for flag \'' + err_args[0] + '\'.'
        if len(err_args) == 4:
            err_msg += ' Expected value between ' + err_args[2] + ' and ' + err_args[3] + '.'
    
    elif err_type == 'invalid_arg':
        err_msg = 'Error: Invalid argument \'' + err_args[0] + '\'.'
    
    print(err_msg)

def assemble(filename, base_sp, base_pc):
    '''
    Assemble the program in filename, writing the output to '<filename>.bin'.
    Also writes bootstrap code using the integers base_sp and base_pc, which contain
    integer addresses of base values of SP and PC respectively.
    '''
    global LABEL_REGEX

    # compile regex for label
    LABEL_REGEX = re.compile(LABEL_REGEX)

    # read the input file into a buffer
    input_file = open(filename, 'r')
    input_file_buffer = input_file.readlines()
    input_file.close()

    line_number = base_pc - 1
    parsed_buffer = []

    # add NOP instructions between bootstrap code and user code
    for i in range(4, base_pc):
        parsed_buffer += ['NOP']

    # extract labels from the code
    # and add the rest of the lines into parsed_buffer
    for line in input_file_buffer:
        # remove whitespaces and newlines
        line = line.strip()
        line = line.strip("\r\n")  # CRLF for Windows line ending
        line = line.strip("\n")    # LF for *nix line ending

        # skip over empty lines or comment line
        if (len(line) == 0) or line.startswith(';'):
            continue

        # remove in-line comments
        comment_index = line.find(';')
        if comment_index != -1:
            line = line[:comment_index]
        
        line_number += 1
        if LABEL_REGEX.search(line):
            label_line[line[:-1]] = line_number
            line_number -= 1
        else:
            # additional increase in line number for two-argument instructions
            if line[:3] in TWO_ARG_INST:
                line_number += 1
            parsed_buffer += [line]

    # create output binary file and write bootstrap code
    output_file = open(filename[:-3] + 'bin', 'w')
    base_sp_bin = '{0:016b}'.format(base_sp % 65536)
    base_pc_bin = '{0:016b}'.format(base_pc % 65536)
    output_file.write(base_sp_bin[:8] + ',\n')
    output_file.write(base_sp_bin[8:] + ',\n')
    output_file.write(base_pc_bin[:8] + ',\n')
    output_file.write(base_pc_bin[8:] + ',\n')

    line_number = base_pc  # line_number now represents PC value

    for line in parsed_buffer:
        binary_inst = '; ' + str(line_number-2) + ' - ' + line + '\n'
        line_number += 1

        # additional increase in line number for two-argument instructions
        if line[:3] in TWO_ARG_INST:
            line_number += 1

        # break the instruction into tokens
        tokens = line.split()

        # initialize the binary instruction with the opcode
        binary_inst += OPCODE_BIN[tokens[0]]

        # assemble instructions with 0 arguments
        if len(tokens) == 1:
            binary_inst += '000,\n'

        # assemble instructions with atleast 1 argument
        else:
            args = get_bin_args(tokens, line_number)
            for arg in args:
                binary_inst += arg + ',\n'

        output_file.write(binary_inst)

    # all done! close the file
    output_file.close()

def get_bin_args(tokens, line_number):
    '''
    Extracts arguments from instruction tokens and returns their binary equivalent.
    The first argument is converted and returned as-is, i.e. it is not padded to 8-bits.
    The second argument is converted and sign extended to 8-bit length.
    Requires len(tokens) >= 2.
    '''
    bin_args = []

    # extract and convert the first argument
    if tokens[0] in FLAG_INST:
        bin_args += [FLAG_BIN[tokens[1]]]
    else:
        bin_args += ['{0:03b}'.format(int(tokens[1]) % 8)]

    # extract and convert the second argument, if it exists
    if len(tokens) == 3:
        arg = 0
        if is_num(tokens[2]):
            arg = int(tokens[2])
        else:
            if tokens[0] in DIRECT_ADDR_INST:
                # instructions that use direct addresses
                arg = label_line[tokens[2]]
            else:
                # instructions that use PC-relative addresses
                arg = label_line[tokens[2]] - line_number
        bin_args += ['{0:08b}'.format(arg % 256)]

    return bin_args

def is_num(num):
    '''
    Returns True if the string num consists entirely of an integer. False, otherwise.
    '''
    return all(char.isdigit() for char in num)

def str_to_bin(num):
    '''
    Convert the string num, which contains an integer, to its corresponding binary string.
    '''
    return bin(int(num))[2:]

if __name__ == '__main__':
    main()
