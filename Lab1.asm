section .data                   ;section declaration 
 
   prompt1 db 'Enter the first seed: '
   lenPrompt1 equ $-prompt1

   prompt2 db 'Enter the second seed: '
   lenPrompt2 equ $-prompt2

section .bss 
   num1 resb 15
   lenNum1 equ $-num1
   num2 resb 10
   lenNum2 equ $-num2

   outbuf resb 4 
   printBuffer resb 20  ; bugger to store ascii text decimal number to be printed 
 
section .text 
   global _start 
 
   seed0 equ 0
   seed1 equ 1
  
_start:

_getInput:

   ;Print the prompt for num1
   mov edx, lenPrompt1
   mov ecx, prompt1
   mov ebx, 1
   mov eax, 4
   int 0x80

   ;Read in num1
   mov edx, lenNum1
   mov ecx, num1
   mov ebx, 0
   mov eax, 3
   int 0x80

   mov ecx, num1
   mov edx, lenNum1
   mov byte bl, [ecx]  
   sub bl, 0x30
   dec edx
_prev:
   cmp edx, 0
   jne _convertloop
   jmp _afterloop

_convertloop:
   imul ebx, 10
   mov byte al, [ecx+1]  
   sub al, 0x30
   add bl, al
   dec edx
   jmp _prev

_afterloop:
   mov esi, ebx

   ;Print the prompt for num2
   mov edx, lenPrompt2
   mov ecx, prompt2
   mov ebx, 1
   mov eax, 4
   int 0x80

   ;Read in num2
   mov edx, lenNum2
   mov ecx, num2
   mov ebx, 0
   mov eax, 3
   int 0x80

   mov byte bl, [ecx]  
   sub bl, 0x30 
   
   mov edi, ebx
    
   ;print out esi 
    call _printEsi 
 
     
   ;print out edi 
    call _printEdi 
   

   
_fibloop:    
    
    add esi,edi      ; put sum into eax 
    jo _exit_cleanly 
     
    ;print out esi 
    call _printEsi    
    
    add edi, esi   
    jo _exit_cleanly 
      
    ;print edi 
    call _printEdi  
      
    ; ** ?? Why does this work? 
    jmp _fibloop      
 
_exit_cleanly: 
    mov   ebx,0 
    mov   eax,1 
    int   0x80 
 
; define a couple "wrapper" routines for printing esi or eai 
_printEsi: 
    mov eax,esi 
    call _printnum 
    ret 
     
_printEdi: 
    mov eax,edi 
    call _printnum 
    ret  
     
_printnum: 
    ; lets print the number as plain decimal text to the stdout... 
     
    ; first setup & call the conversion routine 
    mov ebx,printBuffer   ; the wrappers took care of putting esi or edi into eax 
                          ; but _PosInToDecStr also needs pointer to buffer to store text 
    call _PosIntToDecStr 
     
    ; now print the text it with a system call 
    mov edx, ecx   ; the converter leaves the byte count in ecx, 
                   ; but sys_write needs it in edx 
    mov ecx, ebx   ; likewise we need to put the pointer in the right place for sys_write 
    mov ebx, 1     ; file descriptor for stdout 
    mov eax, 4     ; the code for the sys_write call 
    int 0x80       ; interrupt with code 0x80 to generate a system call 
     
    ; just for fun lets still print the binary, but to stderr!!! 
    ; and then learn a bit more about i/o redirection in Linux/bash shell 
   ; mov   edx,4     ; length of text 
   ; mov   ecx,outbuf     ; pointer to start of message 
   ; mov   ebx,1       ; file descriptor for stdout 
   ; mov   eax,4       ; 4 is code for the  sys_write 
   ; int   0x80        ; interrup to generate a system call 
     
    ret 
 
_PosIntToDecStr: 
    ; convert an unsigned 32bit integer in eax to a string of decimal digits 
    ; the string will be stored in buffer pointed to by ebx 
    ; ecx will store the count of decimal digits 
 
    ; eax -- the integer (an unsigned integer) 
    ; ebx -- pointer to string buffer (assumed to be at least 12 bytes!!) 
    ; ecx -- counter of decimal digits 
    ; esi -- store our divisor: 10   
 
    ; note because we work backwards from low to high digit we fill in from 
    ; the 12 byte in buffer and return pointer to first character of the 
    ; decimal version, which likely will not be the first byte of the buffer 
    ; calling code needs to keep track of it's original buffer pointer 
 
    asciiZero equ 0x30          ; define symbol for ascii code of zero 
                                 ; moved it here so if we copy/paste it goes together 
 
 
    add ebx,11           ; point to 12th byte of buffer (we will fill the digits in "backwards") 
 
    mov byte [ebx],0x0a  ; lets put a newline character here to make printing easier 
                         ; now we are not guaranteeing a valid string 
                         ; maybe we should really just let the calling code deal 
                         ; with whether it wants a newline or null or both or neither 
                         ; it really should not be the job of this subroutine! 
                          
                          
    mov ecx, 1         ; ecx will count our digits, make sure it starts at zero 
                       ; starting at 1 to include the newline character 
_PosIntToDecStr_Loop: 
    dec ebx           ; decrement ebx to point to byte position of last decimal digit 
 
    ; is there an improvement to efficiency we can make here, related to this instruction?  why or why not? 
    mov ebp,10        ; we will be dividing by 10, keep it here… 
                      ; using ebp to store divisor, to avoid collision with esi&edi used by fibonacci program 
 
    mov edx,0x0000    ; the dividend is edx:eax, so we put 0's in high bits in edx 
    div ebp           ; will calculate eax / ebp 
                      ;    quotient --> eax 
                      ;    remainder --> edx 
 
    add edx,asciiZero ; add ascii code of '0' to remainder(which is put in edx by div command) 
                      ; conveniently, this gives ascii code of the digit,  
                      ;    because the ascii codes of digits are in order 0x30...0x39 
    mov [ebx], dl     ; store the digit into its position in the buffer 
 
    inc ecx           ; increment our digit counter 
 
    ;can these two instructions be simplified to one instruction? why or why not? 
    cmp eax, 0                   ; check if eax is zero... 
    jne _PosIntToDecStr_Loop     ; if it was NOT a zero, the loop back for next digit 
 
    ret               ; return -- note that ebx now points to first (most significant) digit of decimal string 
