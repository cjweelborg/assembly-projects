section .data                           ;Data segment
   userMsg db 'Enter some text: ' ;Ask the user to enter a number
   lenUserMsg equ $-userMsg             ;The length of the message
   dispMsg db 'Printed backwards: '
   lenDispMsg equ $-dispMsg                 

section .bss           ;Uninitialized data
   input resb 100
   lenInput equ $-input
   
	
section .text          ;Code Segment
   global _start
	
_start:                ;User prompt
   mov eax, 4
   mov ebx, 1
   mov ecx, userMsg
   mov edx, lenUserMsg
   int 80h

   ;Read and store the user input
   mov eax, 3
   mov ebx, 0
   mov ecx, input
   mov edx, 100          ;5 bytes (numeric, 1 for sign) of that information
   int 80h

   ;Reverse the user input
   ;Setup for reverse loop
   mov ecx, lenInput
   mov eax, input
   mov esi, eax
   add eax, ecx
   mov edi, eax
   dec edi
   shr ecx, 1
   jz _output
   ;Reverse loop

_reverseLoop:
   mov al, [esi] ; load characters
   mov bl, [edi]
   mov [esi], bl ; and swap
   mov [edi], al
   inc esi       ; adjust pointers
   dec edi
   dec ecx       ; and loop
   jnz _reverseLoop

_output:	
   ;Output the message 'Printed backwards: '
   mov edx, lenDispMsg
   mov ecx, dispMsg
   mov ebx, 1
   mov eax, 4
   int 80h  

   ;Output the text entered
   mov eax, 4
   mov ebx, 1
   mov ecx, input
   mov edx, 100
   int 80h  
    
   ; Exit code
   mov eax, 1
   mov ebx, 0
   int 80h
