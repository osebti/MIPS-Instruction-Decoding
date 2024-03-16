#---------------------------------------------------------------
# Assignment:           2
# Due Date:             February 4, 2022
# Name:                 Othman Sebti
# Unix ID:              osebti
# Lecture Section:      B1
# Instructor:           Karim Ali
# Lab Section:          (Tuesday, Thursday)
# Teaching Assistant:   Danil Tiganov
#---------------------------------------------------------------


#---------------------------------------------------------------



.data

# This data section contains all relevant values to be used during execution of the program
# Such as opcodes, instruction strings and so forth.

b1: .asciiz "bgez "
b2: .asciiz "bgezal "
b3: .asciiz "bltz "
b4: .asciiz "bltzal "
b5: .asciiz "beq "
b6: .asciiz "bne "
b7: .asciiz "blez "
b8: .asciiz "bgtz "

hexchars: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'


opcode1: .word 1
opcode2: .word 4
opcode3: .word 5
opcode4: .word 6
opcode5: .word 7

InstructionCode: .word 0x1109000b
address: .word 0x00400100

dollar: .asciiz "$"
offset_start: .asciiz "0x"
space: .space 5
String: .space 30 # space to be used for the print instruction
comma_space: .asciiz ", "


#---------------------------------------------------------------


# The program obtains an address containing an assembly instruction.
# It subsequently loads the binary representation of the instruction.
# Finally, the full instruction is parsed and printed out by the program.


# Register usage:
# $s0 = address of instruction 
# $t0 = 32 bit-instruction
# $t1 = opcode
# $t2 = s-register 
# $t3 = t-register 
# $t4 = offset
# $t5-$t7 store temporary values for calculations and other purposes


.text 

disassembleBranch: # program begins here

move $s0,$a0

Extract_op: #extract the opcode in a temp.register
lw $t0,0($a0) # loading instruction word from argument
srl $t1,$t0,26 # shifting the value to obtain an opcode to compare with those in data sec.
j Check_opcode


Extract_sreg: # s-register parsing block
sll $t2,$t0,6 # shifting s-register to the beginning 
srl $t2,$t2,27 

Print_name: # print instruction name 
beq $t1,4,B5 # check which instruction name to print depending on opcode (stored in $t1)
beq $t1,5,B6

B5: # print b5 below by using syscall 4 
la $a0,b5
li $v0,4
syscall
move $t7,$t2 # move value of $t2 in $t7 for later use
j Print_sreg

B6: # print b6 below by using syscall 4 
la $a0,b6
li $v0,4
syscall

move $t7,$t2 # move value of $t2 in $t7 for later use


Print_sreg: # print register 

la $a0,dollar # print dollar sign
li $v0,4
syscall

move $a0,$t7 # moving integer in $a0
li $v0,1 # print integer
syscall

la $a0,comma_space # print comma and space
li $v0,4
syscall




Extract_treg:
sll $t3,$t0,11 # shifting t-register to the beginning and isolating it
srl $t3,$t3,27

move $t7,$t3 # move value of $t3 in $t7 for later use
j Print_register # move to printing block





Extract_variant1: # special block for instructions with no t register

# extracting t-register 
sll $t3,$t0,11 # shifting t-register to the beginning and isolating it 
srl $t3,$t3,27

# extracting s-register 
sll $t2,$t0,6 # shifting s-register to the beginning 
srl $t2,$t2,27
move $t7,$t2 # move value of $t2 in $t7 for later use

# Printing name of instruction below 

beq $t3,1,v1 # checking variant number on t-reg since opcode is identical
beq $t3,17,v2
beqz $t3,v3
beq $t3,16,v4

v1: # print instruction name below using syscall 4
la $a0,b1
li $v0,4
syscall
j Print_register # move to printing block


v2: # print instruction name below using syscall 4
la $a0,b2
li $v0,4
syscall
j Print_register # move to printing block

v3: # print instruction name below using syscall 4
la $a0,b3
li $v0,4
syscall
j Print_register # move to printing block


v4: # print instruction name below using syscall 4
la $a0,b4
li $v0,4
syscall
j Print_register # move to printing block





Extract_variant2: # special block for instructions with no t register

sll $t2,$t0,6 # shifting s-register to the beginning and isolating it 
srl $t2,$t2,27

beq $t1,6,B7 # check which branch instruction name to print below 
beq $t1,7,B8

B7:
la $a0,b7 # print instruction name with syscall 4
li $v0,4
syscall

move $t7,$t2
j Print_register # go to print block 

B8:
la $a0,b8 #print instruction name with syscall 4
li $v0,4
syscall
move $t7,$t2 






Print_register: # print register 

la $a0,dollar # print dollar sign
li $v0,4
syscall

move $a0,$t7 # moving integer in $a0
li $v0,1 # print integer
syscall

la $a0,comma_space # print comma and space
li $v0,4
syscall




Extract_offset:

sll $t4,$t0,16 # isolating immediate and storing $t4
sra $t4,$t4,14 
add $t4,$s0,$t4 # add the PC to the offset 
addi $t4,$t4,4 # add 4 to the sum 




Print_offset: # print offset


OX: # print first two chars in offset below 
la $a0,offset_start
li $v0,4 
syscall


# the following blocks print each character one by one below

char1: 
srl $t5,$t4,28 # Isolate the charcater (bits)
la $a0,hexchars # Offset calculation

add $a0,$t5,$a0 # Add offset 
lbu $a0,0($a0)
li $v0,11 # print character
syscall

char2: 

sll $t5,$t4,4 # shifting to isolate the character from one side
srl $t5,$t5,28 #Isolate the charcater (bits)
la $a0,hexchars # Offset calculation

add $a0,$t5,$a0 # Add offset 
lbu $a0,0($a0) # load byte and print with syscall 11
li $v0,11
syscall

char3: 
sll $t5,$t4,8 # shifting to isolate the character from one side
srl $t5,$t5,28 # Isolate the charcater (bits)
la $a0,hexchars # Offset calculation

add $a0,$t5,$a0 # Add offset 
lbu $a0,0($a0) # load byte and print with syscall 11
li $v0,11
syscall


char4: 
sll $t5,$t4,12 # shifting to isolate the character from one side
srl $t5,$t5,28 #Isolate the charcater (bits)
la $a0,hexchars # Offset calculation

add $a0,$t5,$a0 # Add offset 
lbu $a0,0($a0) # load byte and print with syscall 11
li $v0,11
syscall


char5: 
sll $t5,$t4,16 # shifting to isolate the character from one side
srl $t5,$t5,28 #Isolate the charcater (bits)
la $a0,hexchars # Offset calculation

add $a0,$t5,$a0 # Add offset 
lbu $a0,0($a0) # load byte and print with syscall 11
li $v0,11
syscall


char6: 
sll $t5,$t4,20 # shifting to isolate the character from one side
srl $t5,$t5,28 #Isolate the charcater (bits)
la $a0,hexchars # Offset calculation

add $a0,$t5,$a0 # Add offset 
lbu $a0,0($a0) # load byte and print with syscall 11
li $v0,11
syscall


char7: 
sll $t5,$t4,24 # shifting to isolate the character from one side
srl $t5,$t5,28 #Isolate the charcater (bits)
la $a0,hexchars # Offset calculation

add $a0,$t5,$a0 # Add offset 
lbu $a0,0($a0) # load byte and print with syscall 11
li $v0,11
syscall


char8: 
sll $t5,$t4,28 # shifting to isolate the character from one side
srl $t5,$t5,28 #Isolate the charcater (bits)
la $a0,hexchars # Offset calculation

add $a0,$t5,$a0 # Add offset 
lbu $a0,0($a0) # load byte and print with syscall 11
li $v0,11
syscall

j Terminate # end the program 



Check_opcode:
beq $t1,1,Extract_variant1 # check whether opcode corresponds to one of the branch opcodes
beq $t1,4,Extract_sreg # these two use s registers, jump to s_reg block
beq $t1,5,Extract_sreg
beq $t1,6,Extract_variant2 # for blez
beq $t1,7,Extract_variant2 # for bgtz


Terminate: # end of program 
jr $ra






