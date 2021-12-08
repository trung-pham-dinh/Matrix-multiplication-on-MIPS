.data
	fout: .asciiz "A.txt"
.text
	li $a0, 12 # number of elements
	li $a1, 1 # element size
	jal malloc
	bne $v0, $0, invalid
	move $s0, $v1
invalid:
	li $v0, 10
	syscall
	
#************************************************
# function malloc
# number of elements, element size
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
