_printLoop:
   dec ecx

   mov ebx, ecx
   imul ebx, 4
   add ebx, list

   ;printf("%d",&list[i]
   push dword [ebx]

   push intFmt
   call printf
   add esp, 8

   dec ecx
   cmp ecx, 0
   je _wrapup
   jmp _printLoop

_wrapup:
   mov ebx, 0
   mov eax, 1
   int 0x80
