section .data
   msg1 db "Enter a character to search for",0x0A
   len1 equ $ - msg1
   msg2 db "Enter a replacement character",0x0A
   len2 equ $ - msg2
   msg3 db "Enter lines of text (enter a blank line to stop getting input)",0x0A
   len3 equ $ - msg3
section .bss
   searchCharacter resb 30
   replaceCharacter resb 30
   textLines resb 1000
   
section .text
   global _start
   extern _replaceChar

_start:
   ; Ask user to enter a character to search for
   mov EDX, len1
   mov ECX, msg1
   mov EBX, 1
   mov EAX, 0x04   ; sys_write
   int 0x80

   ; get search character
   mov EDX, 30
   mov ECX, searchCharacter
   mov EBX, 1
   mov EAX, 0x03   ; sys_read
   int 0x80

   ; Ask user for replacement character
   mov EDX, len2
   mov ECX, msg2
   mov EBX, 1
   mov EAX, 0x04   ; sys_write
   int 0x80

   ; get replace character
   mov EDX, 30
   mov ECX, replaceCharacter
   mov EBX, 1
   mov EAX, 0x03   ; sys_read
   int 0x80

   ; Ask user to enter lines of text
   mov EDX, len3
   mov ECX, msg3
   mov EBX, 1
   mov EAX, 0x04   ; sys_write
   int 0x80

_nextLine:
   ; get lines of text
   mov EDX, 1000
   mov ECX, textLines
   mov EBX, 1
   mov EAX, 0x03   ; sys_read
   int 0x80

   mov ESI, EAX    ; save byte count of the line

   mov EBX, textLines
   mov byte CH, [EBX]
   cmp CH, 0x0A
   je _exit

   ; cdecl stack
   ; push parameter 4 (replaceCharacter) onto the stack
   mov EAX, replaceCharacter
   push EAX
   ; push param 3 (searchCharacter) onto the stack
   mov EAX, searchCharacter
   push EAX
   ; push param 2 (length) onto the stack
   push ESI
   ; push param 1 (pointer to beginning of ascii bytes) onto the stack
   mov EAX, textLines
   push EAX

   ;call the replaceChar library funcion
   call _replaceChar

   mov EDX, 1000
   mov ECX, textLines
   mov EBX, 1
   mov EAX, 0x04   ; sys_write
   int 0x80

   mov EBX, textLines
   mov byte CH, [EBX]
   cmp CH, 0x0A
   jne _nextLine

_exit:
   mov EBX, 0
   mov EAX, 1
   int 0x80
