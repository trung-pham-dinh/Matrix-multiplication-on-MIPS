.data	
intergerArray: .word 3,6,4,7,8
size: .word 5
fout:   .asciiz "testout12.txt"      # filename for output
.text
# allocate memory for 3 chars + \n, no need to worry about \0
li $v0, 9
li $a0, 21  # allocate  bytes 
syscall
move $s0, $v0
la $a2,intergerArray
lw $t6,size

addi $s0, $s0, 0    # point to the start of the buffer
move $s1, $s0

addi $t1,$0,1#counter
loop:
bgt $t1,$t6,exit
lw $t4,0($a2)
addi $t4,$t4,48 #number to ascii
sb $t4,0($s0)
addi $s0, $s0, 1
addi $a2, $a2,4
addi $t1,$t1,1
j loop
exit:

addi $s0, $s0, -5

# Open (for writing) a file that does not exist
li   $v0, 13       # system call for open file
la   $a0, fout     # output file name
li   $a1, 1       # Open for writing (flags are 0: read, 1: write)
li   $a2, 0        # mode is ignored
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

# Write to file just opened
li   $v0, 15       # system call for write to file
move $a0, $s6      # file descriptor 
move $a1, $s0      # address of buffer from which to write
li   $a2, 5        # hardcoded buffer length
syscall            # write to file

# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file

