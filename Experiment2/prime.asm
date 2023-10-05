# FILE:         $File$
# AUTHOR:       P. White
# CONTRIBUTORS: M. Reek
# 		Luke Ward
#
# DESCRIPTION:
#  	This is a simple program to find the prime numbers between 3 - 101
#	inclusive.  This is done by using the simple algorithm where a 
#	number 'n' is prime if no number between 2 and n-1 divides evenly 
#	into 'n'
#
# ARGUMENTS:
#       None
#
# INPUT:
#	none
#
# OUTPUT:
#	the prime numbers printed 1 to a line
#
# REVISION HISTORY:
#       Dec  03         - P. White, created program
#       Mar  04         - M. Reek, added named constants
#

#
# CONSTANT DECLARATIONS
#
PRINT_INT	= 1		# code for syscall to print integer
PRINT_STRING	= 4		# code for syscall to print a string
MIN		= 3		# minimum value to check
MAX		= 102		# max value to check

#
# DATA DECLARATIONS
#
	.data
newline:
	.asciiz "\n"
#
# MAIN PROGRAM
#
	.text
	.align	2
	.globl	main
main:
        addi    $sp,$sp,-8  	# space for return address/doubleword aligned
        sw      $ra, 0($sp)     # store the ra on the stack

	jal	find_primes

        #
        # Now exit the program.
	#
        lw      $ra, 0($sp)	# clean up stack
        addi    $sp,$sp,8
        jr      $ra

#
# Name:		find_primes 
#
# Description:	find the prime numbers between 3 and 101 inclusive.
# Coding Notes:	This function must call is_prime to determine if a
#		number is prime, and based on the return value of 
#		is_prime, call print_number to print that prime 
# Arguments:	none
# Returns:	nothing
#

find_primes:
        addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
        sw      $ra, 32($sp)    # store the ra & s reg's on the stack
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

# ######################################
# ##### BEGIN STUDENT CODE BLOCK 1 #####

        li $s0, MAX
        li $s1, MIN
loop:   
        beq $s1, $s0, exit      # beginning of loop to check for primes
        move $a0, $s1

        jal is_prime
       
if:     
        bne $v0, $zero, else    # if not prime, print nothing
        addi $s1, $s1, 1        # increment counter

        j loop
else:   
        move $a0, $s1           # if prime, print prime number
        addi $s1, $s1, 1        # increment counter
        jal print_number
        j loop
        
        

exit:
        

# ###### END STUDENT CODE BLOCK 1 ######
# ######################################


        lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
        lw      $s7, 28($sp)
        lw      $s6, 24($sp)
        lw      $s5, 20($sp)
        lw      $s4, 16($sp)
        lw      $s3, 12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp,$sp,40      # clean up stack
	jr	$ra

#
# Name:		is_prime 
#
# Description:	checks to see if the num passed in is prime
# Arguments:  	a0	The number to test to see if prime
# Returns: 	v0	a value of 1 if the number in a0 is prime
#			a value of 0 otherwise
#

is_prime:
        addi    $sp,$sp,-40    	# allocate stackframe (doubleword aligned)
        sw      $ra, 32($sp)    # store the ra & s reg's on the stack
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

# ######################################
# ##### BEGIN STUDENT CODE BLOCK 2 #####

        move $s3, $a0
        li $s1, 1
        li $s2, 2
        slt $t4, $s3, $s1
        beq $s3, $s1, prime_false       # if less than 1, false
        beq $s3, $s1, prime_false       # if equal to 1, false
        beq $s3, $s2, prime_true        # if equal to 2, false

loop_prime:                             # loop through numbers until reaches target number
        beq $s2, $s3, prime_true        # if number gets incremented to input without having a 0 remainder, prime
        div $s3, $s2
        mfhi $s4
        beq $s4, $zero, prime_false     # if remainder is zero, not prime
        addi $s2, $s2, 1
        j loop_prime

prime_true:
        li $v0, 1
        j exit_prime

prime_false:
        li $v0, 0
        j exit_prime

exit_prime:

# ###### END STUDENT CODE BLOCK 2 ######
# ######################################

        lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
        lw      $s7, 28($sp)
        lw      $s6, 24($sp)
        lw      $s5, 20($sp)
        lw      $s4, 16($sp)
        lw      $s3, 12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp,$sp,40      # clean up the stack
	jr	$ra

#
# Name;		print_number 
#
# Description:	This routine reads a number then a newline to stdout
# Arguments:	a0,the number to print
# Returns:	nothing
#
print_number:

        li 	$v0,PRINT_INT
        syscall			#print a0

        la	$a0, newline
        li      $v0,PRINT_STRING
        syscall			#print a newline

        jr      $ra
