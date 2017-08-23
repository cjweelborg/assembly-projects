section .data
section .bss
    x resb 4
    y resb 4
    xy_max resb 4

section.text
     GLOBAL _start
     EXTERN something

_start:

    push EAX
    push ECX
    push EDX

    push [x]
    push [y]

    call something

    add ESP, 8

