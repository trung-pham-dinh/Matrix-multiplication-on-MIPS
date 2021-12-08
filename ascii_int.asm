.data
	number: .asciiz "-3425324"
.text
	la $a0, number
	jal ascii_int
	
	li $v0, 10
	syscall
	
#************************************************
# function ascii_int
# arg: base address
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
