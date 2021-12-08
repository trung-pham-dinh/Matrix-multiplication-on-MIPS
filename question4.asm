.data
	mat2_3: .word 1,2,3,4,5,6
	mat3_4: .word 1,2,3,4,5,6,7,8,9,10,11,1
	mat_result: .word 0,0,0,0,0,0,0,0
.text
	la $a0, mat2_3
	la $a1, mat3_4
	la $a2, mat_result
	
	add $sp, $sp, -16
	li $a3, 2
	sw $a3, 0($sp)
	li $a3, 3
	sw $a3, 4($sp)
	li $a3, 3
	sw $a3, 8($sp)
	li $a3, 4
	sw $a3, 12($sp)
	
	jal mat_mul
	li $v0, 10
	syscall
	

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

