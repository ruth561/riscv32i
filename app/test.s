# The size of instruction memory is 4096 bytes.
# e.g. We could implement instructions up to 1024.
# The size of data memory is also 4096 bytes.
# 
# This program will be loaded into imem at address 0.

    .text
    .global main
main:
    jal     ra, .L1
    addi    t1, t1, 0x123
    nop
    nop
    nop
    nop
    nop
    nop
.L1:
    jal     t0, .main
    addi    t1, t1, 0x456
    nop
    nop
    nop
    nop
    nop
