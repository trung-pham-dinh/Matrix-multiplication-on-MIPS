.data
	fout: .asciiz "A.txt"
.text
	li $a0, -143
	la $a1, fout
	jal int_ascii
	
	li $v0, 10
	syscall

#************************************************
# function int_ascii
# arg: number, file name
# return: NA
int_ascii:
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $a1, 32($sp)
	
	# t0=num, t1=tmp, t2=index, t3 = tmp, s1 = addr space alloc, t4 = negative flag
	move $t4, $0
	slti $t4, $a0, 0 # check if negative
	
	bne $t4, $0, negative
	move $t0, $a0 # number to be converted
	j exitnegative
negative:
	sub $t0, $0, $a0
exitnegative:
	
	# space for write buffer
	li $v0, 9
	li $a0, 12 # max length 12
	syscall
	move $s1, $v0
	
	li $t2, 11 # indexing
loopExtract:	
	beq $t0, $0, exitExtract
	# divide $t0 by 10
	li  $t1, 10
    	div $t0, $t1
    	mflo $t0 # $t0 = $t0/10 (first digit of $t0)
    	mfhi $t3 # $t3 = $t0%10 (last digit of $t0)
    	# store
    	addi $t3, $t3, 48
    	add $t1, $s1, $t2
    	sb $t3, 0($t1)
    	addi $t2, $t2, -1
    	j loopExtract
exitExtract:
	beq $t4, $0, notNe
	li $t3, 45
    	add $t1, $s1, $t2
    	sb $t3, 0($t1)
    	addi $t2, $t2, -1
notNe:	
	# Open (for writing) a file that does not exist
	li $v0, 13 # system call for open file
	move $a0, $a1 # output file name
	li $a1, 1 # Open for writing (flags are 0: read, 1: write)	
	li $a2, 0 # mode is ignored
	syscall # open a file (file descriptor returned in $v0)
	move $t0, $v0 # save the file descriptor
	
	# Write to file just opened
	li $v0, 15 # system call for write to file
	move $a0, $t0 # file descriptor
	add $s1, $s1, $t2
	addi $a1, $s1, 1 # address of buffer from which to write
	li $t3, 12
	sub $a2, $t3, $t2 # hardcoded buffer length
	syscall # write to file
	
	# restore from stack
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	lw $t4, 28($sp)
	lw $a1, 32($sp)
	addi $sp, $sp, 36
	jr $ra
	
	
