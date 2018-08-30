
.data #data values
promptforN: .asciiz "Enter n for f(n) = 3*f(n-2)+f(n-1)+1: "
promptResult: .asciiz "Returned: "
returned: .word 0

#main code
.text
.globl main
.align 2

main:

li $v0, 4 #prompt for n
la $a0, promptforN
syscall

li $v0, 5 #store n in v0 then t0
syscall
move $t0, $v0 #register t0 <-- n

#perform recursion
jal rec

end:
#v0 holds return value, stores in returned
move $a1, $v0

li $v0, 4 #end prompt
la $a0, promptResult
syscall

move $a0, $a1 #return the answer
li $v0, 1
syscall

li $v0,10 #loads the service that exits
syscall

#Variables:
#t0 -- current num
#s0 -- middle step
#v0 -- returned

stack: #purely for stack management
addi $sp, $sp, -20 #shift stack pointer

sw $ra, 0($sp) #store ra in stack and stack management
sw $t0, 4($sp)
sw $s0, 8($sp)
sw $s1, 12($sp)
sw $s2, 16($sp)

#just setting up two registers for 0 and 1
li $s1, 0
li $s2, 1

#recursive method where everything happens starts here
base:
#at the very beginning, Base case for n=0 (2) and n=1 (3) of 3*f(n-2)+f(n-1)+1
beq $t0, $s1, basezero
beq $t0, $s2, baseone

first:
#get the f(n-1)
sub $t0, $t0, 1
jal base

addi $s0, $v0, 0 #store middle step to be used to combine at the very end

second:
sub $t0, $t0, 1
jal base

mul $v0, $v0, 3 #get the 3*f(n-2) step
add $v0, $v0, $s0 #combine 3*f(n-2) and f(n-1)
addi $v0, 1 #combine  3*f(n-2) + f(n-1) with 1 to get final result
j recexit

recexit:

lw $ra, 0($sp) #load ra from stack and stack management
lw $t0, 4($sp)
lw $s0, 8($sp)
lw $s1, 12($sp)
lw $s2, 16($sp)
addi $sp, $sp, 20 #shift stack pointer back
jr $ra #jump back and return to main

basezero:
addi $v0, $0, 2
jr $ra

baseone:
addi $v0, $0, 3
jr $ra
