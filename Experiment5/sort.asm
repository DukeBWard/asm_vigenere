#
# FILE:         $File$
# AUTHOR:       Phil White, RIT 2016
# CONTRIBUTORS:
#		W. Carithers
#		Luke Ward
#
# DESCRIPTION:
#	This program is an implementation of merge sort in MIPS
#	assembly 
#
# ARGUMENTS:
#	None
#
# INPUT:
# 	The numbers to be sorted.  The user will enter a 9999 to
#	represent the end of the data
#
# OUTPUT:
#	A "before" line with the numbers in the order they were
#	entered, and an "after" line with the same numbers sorted.
#
# REVISION HISTORY:
#	Aug  08		- P. White, original version
#

#-------------------------------

#
# Numeric Constants
#

PRINT_STRING = 4
PRINT_INT = 1

#-------------------------------

#

# ********** BEGIN STUDENT CODE BLOCK 1 **********

.globl sort
.globl merge

# Name:         sort
# Description:  sorts an array of integers using the merge sort
#		algorithm
# 		Arguments Note: a1 and a2 specify the range inclusively
#
# Arguments:    a0:     a parameter block containing 3 values
#                       - the address of the array to sort
#                       - the address of the scrap array needed by merge
#                       - the address of the compare function to use
#                         when ordering data
#               a1:     the index of the first element in the range to sort
#               a2:     the index of the last element in the range to sort
# Returns:      none
#

sort:
    addi $sp, $sp, -36
	sw $ra, 32($sp)
    sw $a0, 12($sp)
    sw $a1, 8($sp)
    sw $a2, 4($sp)
    
    beq $a2, $zero, exit  # if 0 or 1 elements check
    beq $a2, $a1, exit
    slt $t0, $a2, $a1
    bne $t0, $zero, exit

    add $t0, $a1, $a2
    div $a3, $t0, 2     # a3 is mid
   
    sw $a3, 0($sp)  # save mid on stack

    move $a2, $a3   # set last to mid
    
    jal sort    # first half
    
    lw $a1, 0($sp)  # load mid into first
    addi $a1, $a1, 1    # set to mid +1 
    lw $a2, 4($sp)  # load last from stack

    jal sort    # second half

    lw $a0, 12($sp)     # pass of params to merge
    lw $a1, 8($sp)
    lw $a2, 4($sp)
    lw $a3, 0($sp)
    
    jal merge

exit:
    
	lw $ra, 32($sp)
    lw $a0, 12($sp)
    lw $a1, 8($sp)
    lw $a2, 4($sp)
    lw $a3, 0($sp)
    addi $sp, $sp, 36
    jr $ra


# ********** END STUDENT CODE BLOCK 1 **********

#
# End of Merge sort routine.
#
