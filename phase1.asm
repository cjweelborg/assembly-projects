section .data
   inputPrompt db 'Enter a number: '
   lenInputPrompt equ $-inputPrompt

section .bss
   input resb 10
   lenInput equ $-input

section .text
   global _start

_start:

   ;Print the inputPrompt
   mov edx, lenInputPrompt
   mov ecx, inputPrompt
   mov ebx, 1
   mov eax, 4
   int 0x80

   ;Read in input
   mov edx, lenInput
   mov ecx, input
   mov ebx, 0
   mov eax, 3
   int 0x80

   ;Convert to binary
   


_exit: 
    mov     ebx, 0               ;the process return status code we wish to return 
    mov     eax, 1               ;system call number (sys_exit) 
    int     0x80                ;call kernel 
