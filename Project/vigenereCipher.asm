# File: vigenere_cipher.asm
# Author:   Luke Ward
#
# Constants for system calls
#
PRINT_INT       = 1             # code for syscall to print integer
PRINT_STRING    = 4             # code for syscall to print a string
READ_INT        = 5             # code for syscall to read an integer
READ_STRING     = 8             # code for syscall to read a string

#
# Data areas
#
    .data
    .align 2

buf_e_or_d: .space 3    # e or d
    .align 2    
buf_len: .space 4       # length of alphabet

buf_alpha: .space 82    # alphabet itself
 
buf_key: .space 82      # key for cipher
 
buf_msg: .space 82      # message
		
error_invalid_size:
    .asciiz "Invalid Alphabet Size Inputted\n"
error_invalid_flag:
    .asciiz "Invalid Flag Inputted\n"

space:	
	.asciiz	" "
pound:	
	.asciiz	"#"
dollar:	
	.asciiz	"$"
newline:
	.asciiz	"\n"
letter_e:
    .asciiz "e\n"
letter_d:
    .asciiz "d\n"

#
# TEXT AREAS
# 

    .text
    .align 2

    .globl main

#
# MAIN HERE
#
main:
    addi	$sp,$sp,-12	# allocate space for the return address
	sw	$ra,8($sp)	# store the ra on the stack
	sw	$s7,4($sp)	# store the ra on the stack
	sw	$s6,0($sp)	# store the ra on the stack

    la $a0, buf_e_or_d
    li $a1, 3
    li $v0, 8
    syscall

    la $t0, buf_e_or_d
    lb $t9, 0($t0)
    li $t3, 101
    li $t4, 100
    bne $t9, $t3, not_e        # check if flag is e or d
    j good_flag

not_e:      
    
    bne $t9, $t4,invalid_flag

good_flag:

    li $v0, 5
    syscall

    la $t0, buf_len
    sb $v0, 0($t0)
    lb $t3, 0($t0)
    slt $t1, $t3, $zero         # if len <= 0
    bne $t1, $zero, invalid_size
    
    li $t2, 80
    slt $t1, $t2, $t3
    bne $t1, $zero, invalid_size # if len is > 80

    la $a0, buf_alpha            # alphabet input
    li $a1, 82
    li $v0, 8
    syscall

    la $a0, buf_key              # key input
    li $a1, 82
    li $v0, 8
    syscall

    la $a0, buf_msg              # message input
    li $a1, 82
    li $v0, 8
    syscall

    la $t0, buf_e_or_d           # check if e or d
    lb $t0, 0($t0)
    li $t3, 101
    li $t4, 100
    
    la $a0, buf_len
    la $a1, buf_alpha
    la $a2, buf_key
    la $a3, buf_msg
    beq $t0, $t4, decrypt
    beq $t0, $t3, encrypt

exit:
    lw	$ra,8($sp)	
	lw	$s7,4($sp)	
	lw	$s6,0($sp)	
    addi $sp, $sp, 12
    jr $ra

invalid_size:
    la $a0, error_invalid_size
    li $v0,4 
    syscall

    la $a0, newline
    li $v0, 4
    syscall
    j exit

invalid_flag:
    la $a0, error_invalid_flag
    li $v0,4 
    syscall

    la $a0, newline
    li $v0, 4
    syscall
    j exit


.globl encrypt
#
# Name:     encrypt
# Arguments: a0: buf_len (alphabet size)
#            a1: buf_alpha (alphabet)
#            a2: buf_key (key to use)
#            a3: buf_msg (message to perform action on)
encrypt:
    addi $sp,$sp,-56     # allocate stack frame (on doubleword boundary)
    sw $ra, 48($sp)    # store the ra & s reg's on the stack
    sw $s7, 28($sp)
    sw $s6, 24($sp)
    sw $s5, 20($sp)
    sw $s4, 16($sp)
    sw $s3, 12($sp)
    sw $s2, 8($sp)
    sw $s1, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a2           # pointer to buf_key
    move $s1, $a3           # pointer buf_msg
    move $s2, $a2           # base of buf_key
    move $s3, $a3           # base of buf_msg
    # move $s4, $a0         # buf_len
    lb $s4, 0($a0)
    move $s5, $a1           # buf_alpha
    addi $s7, $zero, 0x0000000a

encrypt_loop:
    lb $t0, 0($s0)          # load first from key
    # addi $t1, $zero, 0x0000000a
    beq $t0, $s7, reset_key
    j key_else
reset_key:
    move $s0, $s2
    lb $t0, 0($s0)          # load first from key
key_else:
    move $a1, $s4
    move $a2, $s5
    move $a3, $t0
    jal get_index
    move $t2, $v0           # index of key char from alpha
   
    
    lb $t1, 0($s1)          # load first from msg
    beq $t1, $zero, exit_encrypt
    beq $t1, $s7, exit_encrypt_newline
    move $a1, $s4
    move $a2, $s5
    move $a3, $t1
    jal get_index
    move $t3, $v0           # index of message char from alpha 
    move $t4, $v1
    bne $t4, $zero, skip_nf
    
    add $t4, $t3, $t2
    rem $t6, $t4, $s4       # mod by alphabet size

    move $a1, $s4
    move $a2, $s5
    move $a3, $t6
    jal get_char
    move $t5, $v0           # converted character
    j else_f

skip_nf:
    sb $t3, 0($s1)
    addi $s0, $s0, 1
    addi $s1, $s1, 1

    j encrypt_loop
else_f:
    sb $t5, 0($s1)
    addi $s0, $s0, 1
    addi $s1, $s1, 1

    j encrypt_loop

    # a0 and a1 should NOT change 
exit_encrypt_newline:
    li $t1, 0
    sb $t1, 0($s1)

exit_encrypt:

    la $a0, letter_d
    li $v0, 4
    syscall

    la $t0, buf_len
    lb $a0, 0($t0)
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    la $a0, buf_alpha
    li $v0, 4
    syscall

    la $a0, buf_key
    li $v0, 4
    syscall

    la $a0, buf_msg
    li $v0, 4
    syscall

    la $a0, newline
    li $v0, 4
    syscall
   
    lw $ra, 48($sp)         # restore the ra & s reg's from the stack 
    lw $s7, 28($sp)
    lw $s6, 24($sp)
    lw $s5, 20($sp)
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp,$sp,56         # clean up stack
    jr $ra

.globl decrypt
#
# Name:     decrypt
# Arguments: a0: buf_len (alphabet size)
#            a1: buf_alpha (alphabet)
#            a2: buf_key (key to use)
#            a3: buf_msg (message to perform action on)
decrypt:
    addi $sp,$sp,-56        # allocate stack frame (on doubleword boundary)
    sw $ra, 48($sp)         # store the ra & s reg's on the stack
    sw $s7, 28($sp)
    sw $s6, 24($sp)
    sw $s5, 20($sp)
    sw $s4, 16($sp)
    sw $s3, 12($sp)
    sw $s2, 8($sp)
    sw $s1, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a2           # pointer to buf_key
    move $s1, $a3           # pointer buf_msg
    move $s2, $a2           # base of buf_key
    move $s3, $a3           # base of buf_msg
    # move $s4, $a0         # buf_len
    lb $s4, 0($a0)
    move $s5, $a1           # buf_alpha
    addi $s7, $zero, 0x0000000a

decrypt_loop:
    lb $t0, 0($s0)          # load first from key
    # addi $t1, $zero, 0x0000000a
    beq $t0, $s7, reset_key_decrypt
    j key_else_decrypt
reset_key_decrypt:
    move $s0, $s2
    lb $t0, 0($s0)          # load first from key
key_else_decrypt:
    move $a1, $s4
    move $a2, $s5
    move $a3, $t0
    jal get_index
    move $t2, $v0           # index of key char from alpha
    
    lb $t1, 0($s1)          # load first from msg
    beq $t1, $zero, exit_decrypt
    beq $t1, $s7, exit_decrypt_newline
    move $a1, $s4
    move $a2, $s5
    move $a3, $t1
    jal get_index
    
    move $t3, $v0           # index of message char from alpha 
    move $t4, $v1
    bne $t4, $zero, skip_nf_decrypt
    
    sub $t4, $t3, $t2
    slt $t0, $t4, $zero
    bne $t0, $zero, wrap
    j wrap_else

wrap:
    add $t4, $t4, $s4

wrap_else:

    rem $t6, $t4, $s4       # mod by alphabet size

    move $a1, $s4
    move $a2, $s5
    move $a3, $t6
    jal get_char
    move $t5, $v0           # converted character
    
    j else_f_decrypt

skip_nf_decrypt:            # not found (don't actually think this is necessary)

    sb $t3, 0($s1)
    addi $s0, $s0, 1
    addi $s1, $s1, 1

    j decrypt_loop
else_f_decrypt:
 
    sb $t5, 0($s1)
    addi $s0, $s0, 1
    addi $s1, $s1, 1

    j decrypt_loop

exit_decrypt_newline:
    li $t1, 0
    sb $t1, 0($s1)

exit_decrypt:

    la $a0, letter_e
    li $v0, 4
    syscall

    la $t0, buf_len
    lb $a0, 0($t0)
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    la $a0, buf_alpha
    li $v0, 4
    syscall

    la $a0, buf_key
    li $v0, 4
    syscall

    la $a0, buf_msg
    li $v0, 4
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    lw $ra, 48($sp)         # restore the ra & s reg's from the stack 
    lw $s7, 28($sp)
    lw $s6, 24($sp)
    lw $s5, 20($sp)
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp,$sp,56         # clean up stack
    jr $ra


#
# Name: get_index
# Arguments: $a1: buf_len
#            $a2: buf_alpha 
#            $a3: character in ascii that you want
# Returns: $v0: index
#          $v1: if not found, returns the character

get_index:
    li $t1, 0
    li $v1, 0
index_loop:
    lb $t0, 0($a2)
    beq $t0, $a3, exit_index
    beq $t1, $a1, exit_index_nf
    addi $t1, $t1, 1
    addi $a2, $a2, 1
    j index_loop
exit_index:             # if found, returns index
    move $v0, $t1
    jr $ra
exit_index_nf:          # if not found, returns the character in ascii
    move $v0, $a3
    li $v1, 1           # not found flag
    jr $ra
#
# Name: get_char
# Arguments: $a1: buf_len
#            $a2: buf_alpha 
#            $a3: index that you want
# Returns: $v0: char
# 

get_char:
    li $t5, 0
char_loop:
    lb $t0, 0($a2)
    beq $t5, $a3, exit_char     # returns when index is found
    addi $t5, $t5, 1
    addi $a2, $a2, 1
    j char_loop
exit_char:
    move $v0, $t0
    jr $ra


