.text
.globl main
main:
lui $t0, 0x1122 # load 16 bit immediate value into upper half register  
ori $t0, $t0, 0x3344 # performs bitwise OR on t0 & 0x3344 and store it back
sw $t0, 8($0) # store word in $t0 at $0+8.
lb $s0, 9($0) # loads byte at memory address $0+9 to $0

li $v0, 10
syscall

