.data #data values / prompts
test1: .asciiz "test1"
test2: .asciiz "test2"
ptsPrompt: .asciiz "Total Points: "
astsPrompt: .asciiz "Total Assists: "
minsPrompt: .asciiz "Total Minutes: "
done: .asciiz "DONE"
namePrompt: .asciiz "Player Name: "
firstTime: .word 0
firstNode:  .word 0
prevNode: .word 0
nln: .asciiz "\n"
space: .asciiz " "
addr: .word 0
word: .word 0
swapped: .word 0

#main code
.text
.globl main
.align 2

main: #mem alloc

prompt:
# prompt for info UNTIL "DONE"
# Save information into a linked list implemented in MIPS
li $v0, 9 #Mem allocation
li $a0, 100
syscall

move $s5, $v0 #move the newly allocated memory address to $s5

li $v0, 4 #prompt for name
la $a0, namePrompt
syscall

li $v0, 8 #store name in $a0, which is the memory location from $s5
la $a0, 8($s5)
li $a1, 100
syscall

move $t8, $a0
move $s4, $t8
move $s3, $t8
la $t9, done

j trim

strcmp:
lb      $t1,($s4)                   # get next char from input string
lb      $t2,($t9)                   # get next char from "DONE"

beq     $t2,$0, cmpCheck             # at end? yes, jump (strings equal)
bne     $t1,$t2, cmpnotDone         # are they different? if yes, it's not DONE

addi    $s4,$s4,1                   # point to next char in input string
addi    $t9,$t9,1                   # point to next char in DONE
j       strcmp

next:

j sort

next2:

lw   $s0, firstNode          # get an address pointer to the first node
beqz  $s0, exit          #  if the pointer is null, exit

j print

exit:

li $v0, 10 #end
syscall


sort: # Sort the linked lists with bubblesort

#check to see if the next node is null, if so, quit sort
lw $t1, firstNode     #get first node address, put in t1
lw $t2, 0($t1)       #get next node of head's address
beq $t2, $0, next2 #if it's 0, you know it's empty, so quit

li $t4, 0
sw $t4, swapped #put in 0 for swapped initially (used for sortLoop)

sortLoop:
li $t4, 0
sw $t4, swapped #again, 0 for swapped
lw $t1, firstNode #load first node (head) into t1
lw $t2, 0($t1) #load head->next into t2

beq $t2, $0, sortCheck

innerLoop:

lwc1 $f1, 4($t1) # cur node's DOC
lwc1 $f2, 4($t2) # next node's DOC

#swap values if $f1 < $f2, or cur's DOC < next's DOC
c.lt.s $f1, $f2  #compare to see if $f1 < $f2
bc1t swap #swap if above condition is true

back:

#if $f1==$f2, or cur DOC == next DOC, compare alphanumerically
c.eq.s $f1, $f2
bc1t alphCmp

back2:

move $t1, $t2 #cur = cur->next
lw $t2, 0($t1) #get the current cur->next, or technically last line's cur->next->next

bnez $t2, innerLoop #If $t2 is not null (0), then loop again

sortCheck:

lw $t0, swapped #get swapped value
bne $t0, 0, sortLoop #check if swapped is 0, if it is, the list is sorted

j next2 #thus, we exit

swap: # Used in bubblesort to swap two nodes, needs to change swapped to 1

#$t1, $t2 are cur and cur->next

lwc1 $f3, 4($t1) #t1's DOC -> f3
lwc1 $f4, 4($t2) #t2's DOC -> f4

swc1 $f3, 4($t2) #f3 (t1's DOC) -> t2's DOC
swc1 $f4, 4($t1) #f4 (t2's DOC) -> t1's DOC

lw $t5, 8($t1) #t1's name -> t5
lw $t6, 8($t2) #t2's name -> t6

sw $t5, 8($t2) #t5 (t1's name) -> t2's name
sw $t6, 8($t1) #t6 (t2's name) -> t1's name


li $s5, 1 #change swapped to 1
sw $s5, swapped

j back

alphCmp: # Used to compare when nodes have same DOC (sort alphanumerically)
# needs to call swap2, and change swapped to 1

lw $t5, 8($t1) #get the strings from cur and next nodes
lw $t6, 8($t2)

#if cur->name > cur->next->name, then swap2
alphLoop:

lb $t7, ($t5)    # get character from cur node at this index
lb $s6, ($t6)    # Get character from next node at this index

beqz $t7, doneAlph
beqz $s6, doneAlph
bgt $t7, $s6, swap2

addi $t5,$t5,1      # Increment index for t5 and t6
addi $t6,$t6, 1

j alphLoop

doneAlph:

j back2

swap2: # Used in bubblesort->alphCmp to swap two nodes, needs to change swapped to 1

#$t1, $t2 are cur and cur->next
#$t5, $t6 are temp reg

lwc1 $f3, 4($t1) #t1's DOC -> f3
lwc1 $f4, 4($t2) #t2's DOC -> f4

swc1 $f3, 4($t2) #f3 (t1's DOC) -> t2's DOC
swc1 $f4, 4($t1) #f4 (t2's DOC) -> t1's DOC

lw $t5, 8($t1) #t1's name -> t5
lw $t6, 8($t2) #t2's name -> t6

sw $t5, 8($t2) #t5 (t1's name) -> t2's name
sw $t6, 8($t1) #t6 (t2's name) -> t1's name

li $s5, 1 #change swapped to 1
sw $s5, swapped

j back2

print: #loop through all the nodes and print name and DOC in succession
# this is assuming, of course, that the list is sorted already

lw $a0, 8($s0)         #  get the player name address of this node
li     $v0,4              #  print it
syscall

la    $a0, space        #  get space
li     $v0,4              #  print it
syscall

lwc1     $f12,4($s0)         #  get the DOC of this node
li     $v0,2              #  print it
syscall

la    $a0, nln        #  get new line
li     $v0,4              #  print it
syscall

lw     $s0, 0($s0)         #  get the pointer to the next node
beqz   $s0, exit          #  if the pointer is null, exit


j print

cmpnotDone:


li $v0, 4 #prompt for pts
la $a0, ptsPrompt
syscall

li $v0, 6 #store pts
syscall
mov.s $f1, $f0


li $v0, 4 #prompt for asts
la $a0, astsPrompt
syscall

li $v0, 6 #store asts
syscall
mov.s $f2, $f0

li $v0, 4 #prompt for mins
la $a0, minsPrompt
syscall

li $v0, 6 #store mins
syscall
mov.s $f3, $f0

# DOC = (pts + asts) / mins

add.s $f1, $f1, $f2 # (pts + asts)
div.s $f1, $f1, $f3 # (pts + asts) / mins -> DOC -> $f1

lw $t0, firstTime
beq $t0, $0, first
j other

first:

li $t0, 1
sw $t0, firstTime

li $v0,9   # allocate memory
li $a0, 108 # 108 bytes, 100 for string, 4 for DOC, 4 for address
syscall # the address is in $v0
move $s1, $v0 #move from $v0 to $s1

sw $s1, firstNode #copy pointer to firstNode
sw $s1, prevNode #copy pointer to prev node to be used in the other iterations
sw $t8, 8($s1) # put name into first node
swc1 $f1, 4($s1) # put DOC into first node

j prompt

other:

li $v0, 9 # allocate memory

li $a0, 108  # 108 bytes
syscall # the address is in $v0
move $s1, $v0 #move from $v0 to $s1

lw $s2, prevNode #get the previous node

sw $s1, 0($s2) #link current node to previous node

sw $t8, 8($s1) # put name into first node
swc1 $f1, 4($s1) # put DOC into first node

sw $s1, prevNode # copy pointer to prev node

j prompt

cmpCheck: #check if the word is "DONE" (second case to make sure)

beq $t1,$0, cmpDone
j cmpnotDone

cmpDone: #if it's actually done, end it

lw $s2, prevNode
sw $0, 0($s2)
j next

trim:

#la $s7, nln # get address of nln into s7
li $s7, 10
trimmain:
# keep looping (incr by 1) until reach nln character

  lb $a3, ($s3)    # Load character at index

  addi $s3,$s3,1      # Increment index
  beq $a3,$s7, trimnln   # are they equal? if so, delete it
  j trimmain

trimnln:

addi $s3,$s3, -1    # If above not true, the char is \n, go back 1
sb $0,($s3)    # Add the terminating character in its place
j strcmp #and exit
