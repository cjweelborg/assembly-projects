section .data
   msg1 db "Please enter 2 lines of text...",0x0A
   len1 equ $ - msg1
   msg2 db "Here are your 2 lines in lexical order...",0x0A
   len2 equ $ - msg2
section .bss
   A resb 1000   ;buffers for lines of text entered by the user
   B resb 1000

section .text
   global _start
   extern lexicalComp
_start:
   ; ask user for two lines (could just be words), compare & print them in order
   mov EDX, len1
   mov ECX, msg1
   mov EBX, 1
   mov EAX, 0x04   ; sys_write
   int 0x80

   ; get line A
   mov EDX, 1000
   mov ECX, A
   mov EBX, 1
   mov EAX, 0x03   ; sys_read
   int 0x80

   mov ESI, EAX   ; save byte count of first line

   ; get line B
   mov EDX, 1000
   mov ECX, B
   mov EBX, 1
   mov EAX, 0x03   ; sys_read
   int 0x80

   ; now let's call the lexicalComp function
   push EAX   ; pushes byte count of 2nd line
   mov EAX, B
   push EAX   ; pushes pointer to 2nd buffer
   push ESI   ; push byte count to 1st line
   mov EAX, A
   push EAX   ;push pointer to first buffer

   call lexicalComp
