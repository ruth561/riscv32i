# The size of instruction memory is 4096 bytes.
# e.g. We could implement instructions up to 1024.
# The size of data memory is also 4096 bytes.
# 
# This program will be loaded into imem at address 0.

    .text
    .global main
main:
    nop
    nop
    add     a0, a0, a0
    xor     t0, t0, t0
    xor     t1, t1, t1
    addi    t0, t0, 0
    addi    t1, t1, -1
    sltiu   t2, t1, 5
    nop    
    nop    
    nop    
    nop    
    nop    
    nop    
    nop    
    nop    

