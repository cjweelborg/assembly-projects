section .data                   ;section declaration 
 
    msg db      "Enter some text and I will count the digits...",0xa ;our dear string 
    len equ     $ - msg             ;length of our dear string 
 
section .bss                    ; .bss section for "variables" -- reserve space in memory for data that will change 
 
   readBuffer resb 1000         ; 1000 byte buffer for reads 
   rbLen equ 1000               ; length of read buffer  $ - readBuffer should also work here 
   writeBuffer  resb 1000       ; reserve a 1000 byte buffer for writes 
   wbLen equ 1000 
 
section .text                   ;section declaration 
 
                                ;we must export the entry point to the ELF linker or 
    global  _start              ;loader. They conventionally recognize _start as their 
        ;entry point. Use ld -e foo to override the default. 
 
_start: 
     
   mov     edx,rbLen         ;sys_read needs to know size of buffer (max # of characters to read) (goes in edx) 
   mov     ecx,readBuffer    ;sys_read needs address of start of buffer (goes in ecx) 
   mov     ebx,0             ;sys_read needs file descriptor -- where to read from.  0 for stdin 
   mov     eax,3             ;sys_read 
   int     0x80 
 
   ; after sys_read eax should contain count of bytes read... 
   ; we can also expect the input line to terminate with a newline 0x0A 
 
   mov eax, edx          ; use edx to count down the number of bytes 
   mov ecx, readBuffer   ; use ecx to point to the input buffer (redundant given the above code) 
   mov bh, '0'           ; keep an ascii '0' in register bh 
   mov eax, 0            ; use eax to count digits, start at zero 
 
_scanLoop: 
   mov byte bl, [ecx]    ; move a single byte located at ecx into register bl  
   sub bl, bh            ; subtract bh from bl (result goes into bl) (there was a typo here... result ends up in bh) 
   jl _xxx              ; if <0, then it was not a digit... 
                         ; note: compare (cmp) just does a subtraction & does not store result. jle, jge just looks at the flags 
   cmp bl, 10            ; compare to 10 
   jge _xxx              ; if >=10, then it was not a digit 
 
                         ; if we get here it's a digit! 
   inc eax               ; increment the counter 
 
_xxx: 
    
   inc ecx               ; increment pointer to next byte of input 
   dec edx               ; decrement countdown 
   jnz _scanLoop         ; repeat loop if countdown has not reached zero 
 
                         ; at this point, we have the count of how many numerals were in the input line 
                         ; in register eax. 
                         ; let's convert it to ascii decimal text in the writeBuffer then print it. 
 
    mov ebx, writeBuffer ; _UnsignedInt_to_Ascii needs pointer to the buffer in ebx 
                         ; it expects the number to be converted in eax, but it is already there 
    call _UnsignedInt_to_Ascii 
 
                                ;write our string to stdout 
 
    mov     edx,ecx             ;_UnsignedInt_to_Ascii left the digit count in ecx, but sys_write needs it in edx 
 
    mov     ecx,ebx             ;_UnsignedInt_to_Ascii left the address of first digit in ebx, but 
                                ; sys_write needs pointer to first byte of output in ecx 
 
    mov     ebx,1               ;first argument: file handle (stdout) 
    mov     eax,4               ;system call number (sys_write) 
    int     0x80                ;call kernel 
 
 
_exit: 
    mov     ebx,0               ;the process return status code we wish to return 
    mov     eax,1               ;system call number (sys_exit) 
    int     0x80                ;call kernel 
 
_UnsignedInt_to_Ascii: 
    ; convert an unsigned 32bit integer in eax to a string of decimal digits 
    ; the string will be stored in buffer pointed to by ebx 
    ; ecx will store the count of decimal digits 
 
    ; eax -- the integer (an unsigned integer) 
    ; ebx -- pointer to string buffer (assumed to be at least 12 bytes!!) 
    ; ecx -- counter of decimal digits 
    ; ebp -- store our divisor: 10   
 
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
_UnsignedInt_to_Ascii_Loop: 
 
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
                      ; the dl register is the least significant byte of the ecx register 
                      ; there is also dh, the second lowest byte of edx 
                      ; and dx is the lower two bytes of edx (so dx is dh:dl) 
                      ; these are literall parts of the same register, so changing dl would chance edx 
 
    inc ecx           ; increment our digit counter 
 
    ;can these two instructions be simplified to one instruction? why or why not? 
          cmp eax, 0                   ; check if eax is zero... 
    jne _UnsignedInt_to_Ascii_Loop     ; if it was NOT a zero, the loop back for next digit 
 
    ret               ; return -- note that ebx now points to first (most significant) digit of decimal string
