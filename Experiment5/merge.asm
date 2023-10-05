#
# FILE:         $File$
# AUTHOR:       Phil White, RIT 2016
#               
# CONTRIBUTORS:
#		Luke Ward
#
# DESCRIPTION:
#	This file contains the merge function of mergesort
#

#-------------------------------

#
# Numeric Constants
#

PRINT_STRING = 4
PRINT_INT = 1


#***** BEGIN STUDENT CODE BLOCK 2 ***************************

.globl merge
.globl sort

#
# Name:         merge
# Description:  takes two individually sorted areas of an array and
#		merges them into a single sorted area
#
#		The two areas are defined between (inclusive)
#		area1:	low   - mid
#		area2:	mid+1 - high
#
#		Note that the area will be contiguous in the array
#
# Arguments:    a0:     a parameter block containing 3 values
#			- the address of the array to sort
#			- the address of the scrap array needed by merge
#			- the address of the compare function to use
#			  when ordering data
#               a1:     the index of the first element of the area
#               a2:     the index of the last element of the area
#               a3:     the index of the middle element of the area
# Returns:      none
# Destroys:     t0,t1
#
merge:

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


    lw $t0, 0($a0)  # address of array to sort
    move $s4, $t0

    lw $s7, 4($a0)  # address of scrap array

    lw $s6, 8($a0)  # address of comp func

    move $s5, $s7   # scrap array pointers ADDRESS

    move $s0, $a1   # beginning array INDEX
    mul $t7, $a1, 4 
    add $s0, $t7, $s4   # beginning array ADDRESS
  
    move $s1, $a3   # beginning of 2nd array (midpoint) INDEX
    mul $t7, $a3, 4
    add $s1, $t7, $s4   # beginning 2nd array ADDRESS

    addi $s1, $s1, 4    
    move $s2, $s1   # static midpoint+1
    
    move $s3, $a2   # last element in area INDEX
    mul $t7, $a2, 4
    add $s3, $t7, $s4   # last element ADDRESS
    addi $s3, $s3, 4

    move $s4, $s0   # fetched the start index static
    
loop:

    beq $s0, $s2, area1_empty   # check if first half is empty
    beq $s1, $s3, area2_empty   # check if second half is empty

    lw $a0, 0($s0)
    lw $a1, 0($s1)

    jalr $s6    # compare func call
    
    beq $v0, $zero, a1_is_smaller
    j a0_is_smaller

a1_is_smaller:

    lw $t0, 0($s1)  # puts item from s1 into scrap
    sw $t0, 0($s5)
    
    addi $s1, $s1, 4
    addi $s5, $s5, 4
    j loop

a0_is_smaller:

    lw $t1, 0($s0)  # puts item from s0 into scrap
    sw $t1, 0($s5)
    
    addi $s0, $s0, 4    # bump pointers
    addi $s5, $s5, 4
    j loop
 
area1_empty:

    beq $s1, $s3, exit_scrap    # check if area2 is emptied
    
    lw $t3, 0($s1)
    sw $t3, 0($s5)

    addi $s1, $s1, 4    # bump pointers
    addi $s5, $s5, 4
    j area1_empty

area2_empty:
    
    beq $s0, $s2, exit_scrap    # check if area1 is emptied
    
    lw $t3, 0($s0)
    sw $t3, 0($s5)

    addi $s0, $s0, 4    # bump pointers
    addi $s5, $s5, 4
    j area2_empty

exit_scrap:

    beq $s4, $s3, exit_merge    # once iterated through, leave

    lw $t2, 0($s7)
    sw $t2, 0($s4)
    addi $s7, $s7, 4    # bump pointers
    addi $s4, $s4, 4

    j exit_scrap

exit_merge:

    lw $ra, 48($sp)    # restore the ra & s reg's from the stack 
    lw $s7, 28($sp)
    lw $s6, 24($sp)
    lw $s5, 20($sp)
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp,$sp,56      # clean up stack
    jr $ra

# ********** END STUDENT CODE BLOCK 2 **********

#
# End of Merge routine.
#
