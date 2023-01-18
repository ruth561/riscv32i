    .text
    .global     _start 
_start:
    li      sp, 0x1000
    call    main
.L1: 
    nop
    j       .L1
    nop
    nop
    nop
    nop
    nop
