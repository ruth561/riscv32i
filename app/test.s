# The size of instruction memory is 4096 bytes.
# e.g. We could implement instructions up to 1024.
# The size of data memory is also 4096 bytes.
# 
# This program will be loaded into imem at address 0.

    .text
    .global main
main:
    xor     t0, t0, t0
    addi    t0, t0, 0x123
    sw      t0, 0(zero)
    lw      t2,0x25(zero)
    addi    t2, t2, -0x23
    nop     
    nop     
    nop     
    nop     
    nop     
    nop     
    nop     
    nop     
    nop    
    nop 
    nop 
