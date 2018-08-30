.text
.globl main
.align 2

main:

li $v0, 4 #prompt for n
la $a0, promptforN
syscall

li $v0, 5 #store n in v0 then t1
syscall
move $t1, $v0

#$t1 = num
li $s0, 1
li $s3, 3
li $s5, 0
#$s3 = 3 (for the modulus)
#$s0 = 1 = i
#$s5 = 0 for condition

func: #looping method where everything happens

ble $t1, $0, end  # if num <= 0 then end
div $s0, $s3 # divide the i by 3 to see the remainder

mfhi $t0 #move the remainder to t0
beq $t0, $s5, print  # if the remainder is 0 then print

func2:
addi  $s0, $s0, 1      # i++

j func

print:

li $v0, 1 #print the next number
move $a0, $s0
syscall

li $v0, 4 #print new line
la $a0, nln
syscall

subu $t1, $t1, 1    #  num--

j func2


end:

li $v0,10 #loads the service that exits
syscall


.data #initial prompt
promptforN: .asciiz "Enter n:"
nln: .asciiz "\n"
