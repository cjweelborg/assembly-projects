section .bss

section .text
     GLOBAL something

something:
    push EBP
    mov EBP, ESP


    sub ESP, 4 ;space for local variable

    ;save registers we will use
    push EBX
    push ESI
    push EDI


    mov EDX, [EBP+8]
    mov ECX, [EBP+4]

    cmp EDX, ECX
    jg _ecxGreater
    mov EAX, EDX
    jmp _return

_ecxGreater:
    mov EAX, ECX

_return:

