section .text

    GLOBAL _start

    EXTERN _PrintNumber

_start:

   mov eax, 1000
   call _PrintNumber

   mov eax, 50
   call _PrintNumber

_exit:
   mov   ebx, 0
   mov   eax, 1
   int   0x80  
