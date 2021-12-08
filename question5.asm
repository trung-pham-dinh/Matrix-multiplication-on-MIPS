.data
	rowA: .word 0
	colA: .word 0
	rowB: .word 0
	colB: .word 0
	
	space: .asciiz " "
	endline: .asciiz "\n"
	
	inputRA: .asciiz "Input row of  multiplier: "
	inputCA: .asciiz "Input col of multiplier: "
	inputRB: .asciiz "Input row of multiplicand: "
	inputCB: .asciiz "Input col of multiplicand: "
	
	fileA: .asciiz "A.txt"
	fileB: .asciiz "B.txt"
	fileResult: .asciiz "result.txt"
.text
	# get dimensions
	li $v0, 4
	la $a0, inputRA
	syscall
	li $v0, 5
	syscall
	move $s1, $v0
	
	li $v0, 4
	la $a0, inputCA
	syscall
	li $v0, 5
	syscall
	move $s2, $v0
	
	li $v0, 4
	la $a0, inputRB
	syscall
	li $v0, 5
	syscall
	move $s4, $v0
	
	li $v0, 4
	la $a0, inputCB
	syscall
	li $v0, 5
	syscall
	move $s5, $v0
	# $s1 = row A, $s2 = col A, $s4 = row B, $s5 = col B



	# allocate for multiplier
	mul $a0, $s1, $s2 # number of elements
	li $a1, 4 # size of 1 element
	jal malloc
	beq $v0, $0, validSizeA
	move $s7, $v0
	j endProg
validSizeA:
	move $s0, $v1 # space for A

	# allocate for multiplicand
	mul $a0, $s4, $s5 # number of elements
	li $a1, 4 # size of 1 element
	jal malloc
	beq $v0, $0, validSizeB
	move $s7, $v0
	j endProg
validSizeB:
	move $s3, $v1 # space for B
	
	# allocate for result
	mul $a0, $s1, $s5 # number of elements rwoA*colB
	li $a1, 4 # size of 1 element
	jal malloc
	beq $v0, $0, validSizeResult
	move $s7, $v0
	j endProg
validSizeResult:
	move $s6, $v1 # space for result
	
	# s0 = addr A, s1 = rowA, s2 = colA;   s3 = addr B, s4 = rowB, s5 = colB
	# s6 = addr result
	
	
	#random generate for A
	li $a1, 10 #Here you set $a1 to the max bound.
    	li $v0, 42  #generates the random number.
    	mul $t0, $s1, $s2 #indexing
beginRandA:
	beq $t0, $0, endRandA
    	syscall # generate random value
    	# store to matrix
   	addi $t1, $t0, -1
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $a0, 0($t1)
	#decrease index
	addi $t0, $t0, -1
	j beginRandA
endRandA:
	
	#random generate for B
	mul $t0, $s4, $s5 #indexing
beginRandB:
	beq $t0, $0, endRandB
    	syscall # generate random value
    	# store to matrix
   	addi $t1, $t0, -1
	sll $t1, $t1, 2
	add $t1, $t1, $s3
	sw $a0, 0($t1)
	#decrease index
	addi $t0, $t0, -1
	j beginRandB
endRandB:	

	# write to file
	la $a0, fileA
	li $a1, 1
	move $a2, $s0
	mul $a3, $s1, $s2
	addi $sp, $sp, -4
	sw $s2, 0($sp)
	jal read_write
	addi $sp, $sp, 4
	
	la $a0, fileB
	li $a1, 1
	move $a2, $s3
	mul $a3, $s4, $s5
	addi $sp, $sp, -4
	sw $s5, 0($sp)
	jal read_write
	addi $sp, $sp, 4
	
	
	# matrix multiply
	move $a0, $s0
	move $a1, $s3
	move $a2, $s6
	
	add $sp, $sp, -16
	move $a3, $s1
	sw $a3, 0($sp)
	move $a3, $s2
	sw $a3, 4($sp)
	move $a3, $s4
	sw $a3, 8($sp)
	move $a3, $s5
	sw $a3, 12($sp)
	jal mat_mul
	add $sp, $sp, 16
	# check error
	beq $v0, $0, validMul
	move $s7, $v0
	j endProg
validMul:
	
	# write to file
	la $a0, fileResult
	li $a1, 1
	move $a2, $s6
	mul $a3, $s1, $s5
	addi $sp, $sp, -4
	sw $s5, 0($sp)
	jal read_write
	lw $s5, 0($sp)
	addi $sp, $sp, 4

endProg:
	beq $s7, $0, noError
	li $v0, 1
	move $a0, $s7
	syscall
noError:
	#end program
	li $v0, 10
	syscall
######################################################################



#************************************************
# function read_write
# arg: file name, function(0: read, 1: write), base address, size
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
	# 52($sp) = col
	
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
	beq $s1, $0, read

	li $t0, 0 # indexing
writing:
	move $t1, $a3 # number of elements
	beq $t0, $t1, endWriteRead
	
	sll $t1, $t0, 2
	add $t1, $t1, $s2 # base + offset
	# int_ascii call
	lw $a0, 0($t1)
	move $a1, $s3
	jal int_ascii # this function also write to file
	
	lw $t1, 52($sp)
	addi $t0, $t0, 1
	div $t0, $t1
    	mfhi $t1 # (index+1) % col 
    	addi $t0, $t0, -1 # must reserve for loop indexing
    	
    	beq $t1, $0, noRemain
	# print space character " "
	la $a1, space 
	j exitRemain
noRemain:
	# print space character "\n"
	la $a1, endline 
exitRemain:
	
	li $v0, 15 # system call for write to file
	move $a0, $s3 # file descriptor
	li $a2, 1 # hardcoded buffer length
	syscall # write to file
	
	addi $t0, $t0 1
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
	mul $a2, $a3, $a2 # hardcoded buffer length
	syscall # read file
	
	addi $t2, $t0, -1# address of the byte before ascii to converted
	li $t1, 0 # indexing
reading:
	move $t3, $a3 # number of integer to be assign to array
	beq $t1, $t3, endWriteRead
nextChar:	
	lb $t3, 0($t2)
	slti $t3, $t3, '-' # t3 = 1 if(character < '-')
	bne $t3, $0, nonDigit
	addi $t2, $t2, 1
	j nextChar
nonDigit:
	addi $a0, $t2, 1
	jal ascii_int
	sll $t3, $t1, 2
	add $t3, $s2, $t3
	sw $v0, 0($t3)
	
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
	slti $t4, $a0, 0 # check if negative
	
	bne $t4, $0, negative
	move $t0, $a0 # number to be converted
	j exitnegative
negative:
	sub $t0, $0, $a0
exitnegative:
	
	#space allocation
	li $a0, 12
	li $a1, 1
	jal malloc
	move $s1, $v1
	
	li $t2, 11 # indexing
loopExtract:	
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
    	beq $t0, $0, exitExtract
    	j loopExtract
exitExtract:
	beq $t4, $0, notNe
	li $t3, 45
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
	mul $s1, $s1, $t2
	
	addi $t0, $t0, -48 # convert ascii to int
	add $s1, $s1, $t0
continue:
	addi $t1, $t1, 1
	j asciiConvert
notChar:
	beq $t4, $0, noInvert
	sub $v0, $0, $s1
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
#----------------------------------
# function: mat_mul
# arg: A,B,result matrix,  rowA, colA, rowB, colB(stack)
mat_mul:
	addi $sp, $sp, -44
	sw $ra, 0($sp)
	sw $a0, 4($sp) # A matrix
	sw $a1, 8($sp) # B matrix
	sw $a2, 12($sp) # result matrix
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	sw $t2, 24($sp)
	sw $t3, 28($sp)
	sw $t4, 32($sp)
	sw $t5, 36($sp)
	sw $s0, 40($sp)
	# 44(sp) = row A
	# 48(sp) = col A
	# 52(sp) = row B
	# 56(sp) = col B
	
	lw $t0, 44($sp)
	slt $t0, $0, $t0 # $t0 = 1 if(dimen > 0)
	beq $t0, $0, notPosDimen
	
	lw $t0, 48($sp)
	slt $t0, $0, $t0 # $t0 = 1 if(dimen > 0)
	beq $t0, $0, notPosDimen
	
	lw $t0, 52($sp)
	slt $t0, $0, $t0 # $t0 = 1 if(dimen > 0)
	beq $t0, $0, notPosDimen
	
	lw $t0, 56($sp)
	slt $t0, $0, $t0 # $t0 = 1 if(dimen > 0)
	beq $t0, $0, notPosDimen	
	j posDimen # all dimen > 0
	
notPosDimen:
	# if we come here, means at least 1 dimen <= 0
	# pop stack
	lw $t0, 16($sp)
	addi $sp, $sp, 44
	li $v0, -1 # wrong dimension
	jr $ra
posDimen:
	
	lw $t0, 48($sp)
	lw $t1, 52($sp)
	beq $t0, $t1, rightDimen # check colA = rowB
	# pop stack
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	addi $sp, $sp, 44
	li $v0, -1 # wrong dimension
	jr $ra
rightDimen:	


	move $t1, $0 # indexing for row A
beginRowA:	
	lw $t0, 44($sp) # rowA
	beq $t1, $t0, endRowA # first loop, row A
	
	move $t2, $0 #indexing for col B
beginColB:	
	lw $t0, 56($sp) # colB
	beq $t2, $t0, endColB       # second loop, col B
	
	move $s0, $0 # entry value for result
	move $t3, $0 #indexing for col A
beginColA:
	lw $t0, 48($sp) # colA
	beq $t3, $t0, endColA            # third loop, col A
	#A[r][k]
	lw $t0, 48($sp) # col A
	# index = ri*cols + ci
	mul $t0, $t1, $t0 
	add $t0, $t0, $t3
	sll $t0, $t0, 2
	add $t0, $t0, $a0
	lw $t4, 0($t0)
	
	#B[k][c]
	lw $t0, 56($sp) # col B
	# index = ri*cols + ci
	mul $t0, $t3, $t0
	add $t0, $t0, $t2
	sll $t0, $t0, 2
	add $t0, $t0, $a1
	lw $t5, 0($t0)	
	
	# result entry += A[r][k]*B[k][c]
	mul $t0, $t4, $t5
	add $s0, $s0, $t0
	
	addi $t3, $t3, 1
	j beginColA			  # end third loop
endColA:
	#result[r][c]
	lw $t0, 56($sp)# col B
	# index = ri*cols + ci
	mul $t0, $t1, $t0 # ri*cols
	add $t0, $t0, $t2 # + ci
	sll $t0, $t0, 2
	add $t0, $t0, $a2
	sw $s0, 0($t0)	
				
	addi $t2, $t2, 1
	j beginColB                # end second loop
endColB:
	
	addi $t1, $t1, 1
	j beginRowA           # end first loop
endRowA:	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp) # A matrix
	lw $a1, 8($sp) # B matrix
	lw $a2, 12($sp) # result matrix
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	lw $t2, 24($sp)
	lw $t3, 28($sp)
	lw $t4, 32($sp)
	lw $t5, 36($sp)
	lw $s0, 40($sp)
	addi $sp, $sp, 44
	
	move $v0, $0
	jr $ra
	
