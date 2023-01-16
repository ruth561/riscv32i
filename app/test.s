# The size of instruction memory is 4096 bytes.
# e.g. We could implement instructions up to 1024.
# The size of data memory is also 4096 bytes.
# 
# This program will be loaded into imem at address 0.

    .text
    .global main
main:
    xor     t0, t0, t0
    xor     t1, t1, t1  
    addi    t0, t0, 0x123
    addi    t1, t1, 0x56
    add     t2, t0, t1
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
