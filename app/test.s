# The size of instruction memory is 4096 bytes.
# e.g. We could implement instructions up to 1024.
# The size of data memory is also 4096 bytes.
# 
# This program will be loaded into imem at address 0.

    .text
    .global main
main:
    xor     t0, t0, t0
    addi    t0, t0, 50
    xor     t1, t1, t1
.L1:
    add     t1, t1, t0
    addi    t0, t0, -1
    bgt     t0, zero, .L1

    sw      t1, 0(zero)
.L2:
    nop
    beq     zero, zero, .L2
    nop
    nop
    nop
    nop
    nop
    nop
    nop
