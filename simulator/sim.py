#!/usr/bin/python3
from NUP import *
import binascii
import sys

def get_usage():
    '''
    Returns the command-line usage string.
    '''
    return 'Usage: sim <binary file> <mode> [-boot]\n\n' + \
           'binary file - the binary file in plaintext format containing the user program.\n' + \
           'mode        - the mode to run the simulator in. Must be either \'instruction\' or ' + \
           '\'cycle\'.\n' + \
           '-boot       - signal that the binary contains initial PC and SP values'

def load_bin_file(ifilename):
    ''' 
    Parses the binary file 'ifilename'.
    '''
    is_valid_line = lambda l : len(l.strip()) > 0
    lines = []

    with open(ifilename, "rb") as ifile:
        line = binascii.hexlify(ifile.read(1)).decode('utf-8')
        while line:
            #print('{0:08b}'.format(int(line, base=16)))
            if is_valid_line(line): lines.append('{0:08b}'.format(int(line, base=16)))
            line = binascii.hexlify(ifile.read(1)).decode('utf-8')
    
    return lines

def get_help():
    '''
    Returns NUP command usage menu string.
    '''
    return "\n" + ("-"*25) + "NUP Simulator Help" + ("-"*25) + "\n" + \
           "go             - run program to completion\n" + \
           "run n          - execute program for n instructions/cycles\n" + \
           "mdump low high - dump memory from low(inclusive) to high(exclusive)\n" + \
           "rdump          - dump the register values\n" + \
           "?              - display this help menu\n" + \
           "quit           - exit the program\n"

if __name__ == '__main__':
    if len(sys.argv) not in [3, 4]:
        print(get_usage())
        sys.exit(1)

    contains_boot = False
    if len(sys.argv) == 4:
        if sys.argv[3] == '-boot':
            contains_boot = True
        else:
            print(get_usage())
            sys.exit(1)

    bin_file = load_bin_file(sys.argv[1])
    proc = NUP(bin_file, sys.argv[2], contains_boot)

    print('NUP Simulator')
    print('\nRunning in ' + sys.argv[2] + '-accurate simulation mode.')
    print('\nRead ' + str(len(bin_file)) + ' bytes from program into memory.')

    while True:
        cmd = input('\nNUP-SIM> ').lower().split()

        if len(cmd) == 0:
            continue

        if cmd[0] == 'go':
            proc.run_sim()
        
        elif cmd[0] == 'run':
            if len(cmd) != 2:
                print(get_help())
                continue
            steps = int(cmd[1])
            proc.run_sim(steps)
        
        elif cmd[0] == 'mdump':
            if len(cmd) != 3:
                print(get_help())
                continue
            
            low = int(cmd[1])
            high = int(cmd[2])
            mem = proc.get_mem()
            
            print('\nMemory content [' + str(low) + '..' + str(high - 1) + "] :")
            print('-' * 28)
            for i in range(low, high):
                print('  ' + str(i) + ' : ' + str(mem[i]))
            print('')
        
        elif cmd[0] == 'rdump':
            print('\nCurrent register values :')
            print('-' * 28)
            print(proc)
        
        elif cmd[0] == '?':
            print(get_help())
        
        elif cmd[0] == 'quit':
            print('\nBye!\n')
            break
        
        else:
            print('\nInvalid command \'' + cmd[0] + '\'.')
            print('Enter \'?\' to see the list of commands.')