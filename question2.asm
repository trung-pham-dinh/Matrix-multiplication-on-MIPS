.data
	endline: .asciiz "\n"
	space: .asciiz " "
	
	filename: .asciiz "A.txt"
	array: .word 0,12,13,14,15,16,17,18,19,0
.text
	la $s0, filename
	li $s1, 1 # 0 -> read 1->write
	la $s2, array
	
	move $a0, $s0 # file name
	move $a1, $s1 # function (read(0) or writr(1))
	move $a2, $s2 # base address of array
	li $a3, 10 # number of elements in array
	jal read_write
	
	li $v0, 10
	syscall

#************************************************
# function read_write
# arg: file name, function, base address, number of element in array
# return: NA
read_write:
	# store to stack
	addi $sp, $sp, -52
	sw $ra, 0($sp)
	sw $a0, 4($sp) # file name
	sw $a1, 8($sp) # fucntion
	sw $a2, 12($sp) # base addr
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $s3, 28($sp)
	sw $t0, 32($sp)
	sw $t1, 36($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $a3, 48($sp) # array size
	
	move $s2, $a2 # base addr
	move $s1, $a1 # function
	move $s0, $a0 # file name
	
	# open file
	li $v0, 13 # system call for open file
	move $a0, $s0 # file name
	move $a1, $s1 # flags are 0: read, 1: write)	
	li $a2, 0 # mode is ignored
	syscall # open a file (file descriptor returned in $v0)
	move $s3, $v0 # save the file descriptor
	
	# read or write
	beq $s1, $0, read # read or write base on function arg

	li $t0, 0 # indexing
writing:
	move $t1, $a3 # number of elements
	beq $t0, $t1, endWriteRead
	
	sll $t1, $t0, 2
	add $t1, $t1, $s2 # base + offset
	# int_ascii call
	lw $a0, 0($t1) # pass element to be converted in array to the function call
	move $a1, $s3 # destination for the int_ascii convertion (file descriptor)
	jal int_ascii # this function also write to file
	
	# print space character " "
	li $v0, 15 # system call for write to file
	move $a0, $s3 # file descriptor
	la $a1, space # address of buffer from which to write
	li $a2, 1 # hardcoded buffer length
	syscall # write to file
	
	addi $t0, $t0 1 # increasing index
	j writing
read:
	#space allocation
	li $a0, 12 # maximum possible number of character for integer
	move $a1, $a3 # number of integers to be read
	jal malloc
	move $t0, $v1 # for read buffer
	
	# Read from file
	li $v0, 14 # system call for read
	move $a0, $s3# file descriptor
	move $a1, $t0 # address of buffer read	
	li $a2, 12 # maximum possible number of character for integer
	mul $a2, $a3, $a2 # hardcoded buffer length = 12*number of int to be read
	syscall # read file
	
	
	addi $t2, $t0, -1# address of the byte before ascii to converted (convenient for looping)
	li $t1, 0 # indexing
reading:
	move $t3, $a3 # number of integer to be assign to array
	beq $t1, $t3, endWriteRead
nextChar: # iterate until encounter a non digit character (' ' or '\n')
	lb $t3, 0($t2)
	slti $t3, $t3, '-' # t3 = 1 if(character < '-')
	bne $t3, $0, nonDigit
	addi $t2, $t2, 1
	j nextChar
nonDigit:
	addi $a0, $t2, 1 # address of the first digit as a arg 
	jal ascii_int
	sll $t3, $t1, 2
	add $t3, $s2, $t3
	sw $v0, 0($t3) # store to array the number we read
	
	add $t1, $t1, 1 # increase index
	add $t2, $t2, 1 # next byte to examine
	j reading
endWriteRead:
	
	# Close the file
	li $v0, 16 # system call for close file
	move $a0, $s3 # file descriptor to close
	syscall # close file
	
	lw $ra, 0($sp)
	lw $a0, 4($sp) 
	lw $a1, 8($sp) 
	lw $a2, 12($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	lw $s3, 28($sp)
	lw $t0, 32($sp)
	lw $t1, 36($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	lw $a3, 48($sp)
	addi $sp, $sp, 52
	
	jr $ra
	



#************************************************
# function int_ascii
# arg: number, file descriptor
# return: NA
int_ascii:
	addi $sp, $sp, -40
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $a1, 32($sp) # file descriptor
	sw $t5, 36($sp)
	
	# t0=num, t1=tmp, t2=index, t3 = tmp, s1 = addr space alloc, t4 = negative flag, t5 = file descript
	move $t5, $a1
	
	move $t4, $0
	slti $t4, $a0, 0 # check if negative number
	
	bne $t4, $0, negative # set flag if negative
	move $t0, $a0 # number to be converted
	j exitnegative
negative:
	sub $t0, $0, $a0 # convert to positive number
exitnegative:
	
	#space allocation
	li $a0, 12
	li $a1, 1
	jal malloc
	move $s1, $v1
	
	li $t2, 11 # indexing
loopExtract: # write to buffer from right to left
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
    	beq $t0, $0, exitExtract # put the beq here so that we can deal with the case number to be converted = 0
    	j loopExtract
exitExtract:
	beq $t4, $0, notNe
	li $t3, '-' # if negative then add the minus sign 
    	add $t1, $s1, $t2
    	sb $t3, 0($t1)
    	addi $t2, $t2, -1
notNe:	
	
	# Write to file
	li $v0, 15 # system call for write to file
	move $a0, $t5 # file descriptor
	add $s1, $s1, $t2
	addi $a1, $s1, 1 # address of buffer from which to write
	li $t3, 11
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
	lw $t5, 36($sp)
	addi $sp, $sp, 40
	
	jr $ra

#************************************************
# function ascii_int
# arg: base address of charaters
# return: converted number
ascii_int:
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	sw $t2, 24($sp)
	sw $t3, 28($sp)
	sw $t4, 32($sp)
	
	move $s0, $a0 # base
	move $s1, $0 # number
	move $t4, $0 # negative flag
	
	move $t1, $0 # byte indexing
asciiConvert:	
	add $t2, $s0, $t1 # base + offset
	lb $t0, 0($t2) # character
	
	# check character('-'<= c <= '9')
	slti $t2, $t0, '-' # t2 = 1 if(c < '-')
	li $t3, '9'
	slt $t3, $t3, $t0 # t3 = 1 if('9' < c)
	bne $t2, $0, notChar
	bne $t3, $0, notChar
	
	li $t2, '-'
	bne $t0, $t2, noNeFlag # positive char
	li $t4, 1 # negative flag
	j continue
noNeFlag: 
	li $t2, 10
	mul $s1, $s1, $t2 # shift all digits to the left, so that we can add new digit to the rightmost
	
	addi $t0, $t0, -48 # convert ascii to int (new digit)
	add $s1, $s1, $t0 # add to the result number
continue:
	addi $t1, $t1, 1 # increase index
	j asciiConvert
notChar:
	beq $t4, $0, noInvert # check if we need to negative the number
	sub $v0, $0, $s1 # v0 = -s1
	j exitInvert
noInvert:
	move $v0, $s1
exitInvert:
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	lw $t2, 24($sp)
	lw $t3, 28($sp)
	lw $t4, 32($sp)		
	addi $sp, $sp, 36
	
	jr $ra







#************************************************
# function malloc
# arg: number of elements, element size
# return: validation(-1/0), base addr
malloc:
	addi $sp, $sp, -16
	sw $ra, 0($sp) 
	sw $a0, 4($sp) # number of elements
	sw $a1, 8($sp) # element size
	sw $t0, 12($sp) # tmp
	
	li $v0, 9 # system call code for dynamic allocation
	mul $a0, $a0, $a1
	# check size
	li $t0, 2
	addi $t0, $t0, 65535 # t0 = 65537
	sltu $t0, $a0, $t0 # t0 = 1 if(a0 < 65537 && a0 > 0(result exceed 32 bit))
	bne $t0, $0, rightSize
	# pop stack
	lw $ra, 0($sp) 
	lw $a0, 4($sp) # number of elements
	lw $a1, 8($sp) # element size
	lw $t0, 12($sp)
	addi $sp, $sp, 16
	
	li $v0, -1 # invalid size
	jr $ra
rightSize:	
	syscall
	# pop stack
	lw $ra, 0($sp) 
	lw $a0, 4($sp) # number of elements
	lw $a1, 8($sp) # element size
	lw $t0, 12($sp)
	addi $sp, $sp, 16
	
	move $v1, $v0 # return base addr of allocation
	li $v0, 0 # valid size
	jr $ra

	
