# File:		sub_ascii_numbers.asm
# Author:	K. Reek
# Contributors:	P. White, W. Carithers
#		Luke Ward
#
# Updates:
#		3/2004	M. Reek, named constants
#		10/2007 W. Carithers, alignment
#		09/2009 W. Carithers, separate assembly
#
# Description:	sub two ASCII numbers and store the result in ASCII.
#
# Arguments:	a0: address of parameter block.  The block consists of
#		four words that contain (in this order):
#
#			address of first input string
#			address of second input string
#			address where result should be stored
#			length of the strings and result buffer
#
#		(There is actually other data after this in the
#		parameter block, but it is not relevant to this routine.)
#
# Returns:	The result of the subtraction, in the buffer specified by
#		the parameter block.
#

	.globl	sub_ascii_numbers

sub_ascii_numbers:
A_FRAMESIZE = 40

#
# Save registers ra and s0 - s7 on the stack.
#
	addi 	$sp, $sp, -A_FRAMESIZE
	sw 	$ra, -4+A_FRAMESIZE($sp)
	sw 	$s7, 28($sp)
	sw 	$s6, 24($sp)
	sw 	$s5, 20($sp)
	sw 	$s4, 16($sp)
	sw 	$s3, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)
	
# ##### BEGIN STUDENT CODE BLOCK 1 #####

	lw $s4, 12($a0)		# string length
	addi $s4, $s4, -1
	lw $s5, 0($a0)		# addr 1
	lw $s6, 4($a0)		# addr 2
	lw $s7, 8($a0)		# save addr

loop:

	move $t5, $s5
	move $t6, $s6
	move $t7, $s7
	add $t5, $s5, $s4
	add $t6, $s6, $s4
	add $t7, $s7, $s4
	lb $s1, 0($t5)	# number 1
	lb $s2, 0($t6)	# number 2
	
	addi $t1, $s1, -48	# subtract both by 48 to get non ascii
	addi $t2, $s2, -48

	slt $t8, $zero, $t0
	bne $t8, $zero, sub_one
	j not_carry

sub_one:
	
	sub $t1, $t1, $t0
	addi $t0, $t0, -1

not_carry:

	sub $t3, $t1, $t2	# subtract by eachother

	slt $t8, $t3, $zero
	bne $t8, $zero, carry
	j else

carry:

	addi $s4, $s4, -1	# go back one to do the math
	move $t5, $s5
	add $t5, $s5, $s4
	lb $s1, 0($t5)

	addi $t1, $s1, -1
	
	addi $s4, $s4, 1
	
	addi $t3, $t3, 10
	addi $t0, $t0, 1	# carry over subtraction

else:

	addi $t3, $t3, 48	# turn number to ascii

	sb $t3, 0($t7)		# save to return address 

	beq $t4, $s4, exit
	addi $s4, $s4, -1
	j loop
	
exit:

	

# ###### END STUDENT CODE BLOCK 1 ######

#
# Restore registers ra and s0 - s7 from the stack.
#
	lw 	$ra, -4+A_FRAMESIZE($sp)
	lw 	$s7, 28($sp)
	lw 	$s6, 24($sp)
	lw 	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw 	$s3, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, A_FRAMESIZE

	jr	$ra			# Return to the caller.
