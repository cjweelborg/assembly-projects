section .data
msg1 db "Number: %d",0x0A,0x00
msg2 db "Total: %d",0x0A,0x00

section .bss
section .text
global _sumAndPrintList
EXTERN printf
_sumAndPrintList:

;Pointer to list is ESP+8
;Counter is ESP+12
push ebp
mov ebp, esp
mov ebx, [ebp+8]
mov dword edi, [ebp+12]
mov esi, 0

_loop:
mov eax, [ebx]
add esi, eax

push eax
push msg1
call printf
add esp, 8

push esi
push msg2
call printf
add esp, 8

dec edi
cmp edi, 0
je _wrapup
add ebx, 4
jmp _loop

_wrapup:
mov eax, esi
pop ebp
ret
