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
    xor     t2, t2, t2
    xor     a0, a0, a0
    bgt     t6, zero, main
    addi    t0, t0, 0x123
    addi    t1, t1, 0x246
    addi    t2, t2, 0x369
    sw      t0, 0(zero)
    sw      t1, 4(zero)
    sw      t2, 8(zero)
    nop     
    nop    
    nop    
    nop    
    nop    
