.section .text.init
.global _start
_start:
    j do_reset

do_reset:
    li x1, 0
    li x2, 0
    li x3, 0
    li x4, 0
    li x5, 0
    li x6, 0
    li x7, 0
    li x8, 0
    li x9, 0
    li x12, 0
    li x13, 0
    li x14, 0
    li x15, 0
    li x16, 0
    li x17, 0
    li x18, 0
    li x19, 0
    li x20, 0
    li x21, 0
    li x22, 0
    li x23, 0
    li x24, 0
    li x25, 0
    li x26, 0
    li x27, 0
    li x28, 0
    li x29, 0
    li x30, 0
    li x31, 0
    j hard_init_first
1:  wfi
    j 1b

hard_init_first:
    la sp, _stack_top 
    j main
1:  wfi
    j 1b

.data
    .global tohost
    .global fromhost
    tohost:      .dword  0
    fromhost:    .dword  0
