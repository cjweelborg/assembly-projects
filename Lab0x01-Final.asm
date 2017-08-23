; Lab0x01 Final Solution 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
section .data 
 
   overflowMsg db "Overflow - Exiting.",0x0A 
   lenOverflowMsg  equ $ - overflowMsg 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
section .bss 
 
   ; input and output buffer (note: we could use one buffer for both) 
   readBuffer resb 1000        ; buffer for ascii text we read using sys_read 
   writeBuffer resb 100        ; buffer for ascii text output 
    
   ; global signed integer variables (note: nothing makes these "signed int" except how we use them) 
   Seed0 resb 4                ; 4 byte storage for converted binary seed0 
   Seed1 resb 4                ; 4 byte storage for converted binary seed1 
   fibSteps resb 4             ; 4 byte storage for converted binary number of steps 
 
   fibCurrent resb 4           ; 4 byte storage for "current" fibonacci number 
   fibPrevious resb 4          ; 4 byte storage for "previous" fibonacci number 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
section .text                   
 
    GLOBAL _PrintNumber
    GLOBAL _PromptAndReadNumber
    GLOBAL _Ascii_To_SignedInt
    GLOBAL _SignedInt_To_Ascii

_exit: 
    mov     ebx,0               ;first syscall argument: exit code 
    mov     eax,1               ;system call number (sys_exit) 
    int     0x80                ;call kernel 
 
_overflow: 
    ; setup & call a sys_write for overflow message 
    mov edx, lenOverflowMsg 
    mov ecx, overflowMsg 
    mov ebx, 1 
    mov eax, 4 
    int 0x80 
    ; then exit 
    jmp _exit 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     
_PrintNumber: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
    ; takes a signed int in EAX, converts it to ascii text in the writeBuffer,  
    ; then prints it followed by a newline character 
    ; 
    ; expects to receive... 
    ; 
    ; EAX -- the number to print (signed integer) 
    ; 
    ; This subroutine will uses writeBuffer as a global variable 
     
    mov ebx,writeBuffer      ; _SignedInt_To_Ascii needs pointer to buffer in ebx 
 
    ; EAX should already contain the number to convert, which is expected by _SignedInt_To_Ascii 
    call _SignedInt_To_Ascii   ; returns pointer to beginning of text form of number in ebx, and count of characters in ecx 
 
    mov edx,ebx          ; copy pointer to first digit or minus sign into another available register, edx 
    add edx,ecx          ; add the character count to the pointer to the first digit(or minus sign) 
                         ; ...so now it points ot the next byte after the last digit 
    mov byte [edx],0x0A  ; put an ascii newline character into that byte 
    inc ecx              ; increment the character count for the call to sys_write we are about to make     
     
    ; setup & call sys_write 
    mov edx, ecx 
    mov ecx, ebx 
    mov ebx, 1 
    mov eax, 4 
    int 0x80 
        
    ret 
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
_PromptAndReadNumber: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
    ; this subrouting expects to receive  
    ; 
    ; edx  -- size in bytes of the message text 
    ; ecx  -- pointer to the first byte of a prompt message 
    ; esi  -- a pointer to where to store the converted binary number in memory 
    ; 
    ; This subroutine will use the readBuffer as a "global variable" and does not need that pointer given to it in a register 
     
    ;*** write the prompt -- note: edx & ecx should already have what sys_write needs 
    mov ebx, 1               ; standard output 
    mov eax, 4               ; code for sys_write 
    int 0x80                 ; interrupt to trigger system call 
     
    ;*** read number from user 
    mov edx, 1000           ; max size of our input buffer... happens to be way more than we need... 
    mov ecx, readBuffer     ; pointer to first byte of readBuffer 
    mov ebx, 0              ; standard input 
    mov eax, 3              ; code for calling sys_read 
    int 0x80                ; interrupt to trigger system call 
     
    ;*** setup and call _Ascii_To_SignedInt 
    mov ebx, readBuffer     ; _Ascii_To_SignedInt needs pointer to first byte of text in ebx 
    dec eax                 ; _Ascii_To_SignedInt needs count of characters (digits and possible minus sign) in eax 
                            ;     we subtract 1 because the count that comes back from sys_read includes a newline 
    call _Ascii_To_SignedInt 
     
    ;*** now save the converted binary number to a location in memory 
    mov [esi], eax 
 
    ret 
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
_Ascii_To_SignedInt: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
    ; Convert ascii digits (with possible minus sign in first byte) into a binary signed integer. 
    ; No error checking is done -- assumed only a possible '-' followed only by characters '0'..'9' 
    ; 
    ; this routine expects: 
    ; 
    ; eax  -- the count of number of characters to convert (digits with possible minus sign in first byte) 
    ;         (note I am using this because it is where sys_read returns the count) 
    ; ebx  -- pointer to the first byte of buffer where the ascii version of the integer is stored 
    ; 
    ; RETURNS.... 
    ; eax  -- this is where we will return the resulting converted integer 
    ; 
    ; uses these registers: 
    ; 
    ; ebx  -- will increment this pointer from byte-to-byte of the ascii text decimal number 
    ; ecx: 
    ;      CL   -- this is where we will actualy keep the count (counting down the remaining characters to convert) 
    ;      CH   -- we will put a 1 here if starts with a '-' minus sign, 0 otherwise 
    ; edx: 
    ;      DL   -- this is where we will put each byte(each ascii digit) to do conversion 
    ;               
     
    mov CL, AL           ; keep the count in CL, because we will return the converted integer in eax 
                         ; note we will only use CL (last byte of ECX) for the count,  
                         ; since it should never be higher than 11 
                         ; we are going to use CH for the sign multiplier 
 
    mov eax, 0           ; initialize our converted number to zero -- we will use eax as an accumulator, building up our number 
 
 
  
    mov CH, 0            ; put a 0 in CH to indicate positive 
    mov dl, [ebx]        ; let's look at the first byte -- it might be a minus sign 
    cmp dl, '-'          ; compare it to the ascii minus sign, 0x2D 
    jne _ConvertDigits   ; if not a minus, skip to regular conversion of digits 
 
    mov CH, 1            ; put a 1 in CH to indicate negative 
    inc ebx              ; increment pointer to first actual digit (after minus sign) 
    dec CL               ; decrement the number of characters remaining 
     
_ConvertDigits: 
 
    mov edx, 0x00000000  ; make sure edx high bytes are zeros 
 
_Ascii_To_SignedInt_Loop: 
 
    mov dl, [ebx]        ; move the first ascii character (digit) into lowest byte of edx  (dl) 
    sub dl, 0x30         ; subtract ASCII code of '0', this will give us the value of the digit in binary, in register dl 
 
    imul eax,eax,0x0A    ; multiply eax by ten (0d10, 0x0A, 0b00001010) 
                         ; note that IMUL (signed multiply) gives us many more options for parameters 
                         ; first time through we are just multiplying the zero that starts there 
 
    jo _overflow         ; check for overflow 
 
    add eax, edx         ; add the binary value of the digit to our accumulator 
    jo _overflow         ; check for overflow 
     
    inc ebx              ; increment pointer to the next byte 
    dec CL               ; count down the number of digits remaining to convert 
    jnz _Ascii_To_SignedInt_Loop  ; repeat for next digit 
 
    cmp CH, 1            ; check if we had a negative sign 
    jne _NotNegative     ; skip if not negative 
 
    imul EAX,EAX, -1     ; multiply our final number by -1 if it is supposed to be negative 
 
 
_NotNegative: 
 
    ret                  ; if we get here, we're done. The result is already in register EAX 
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
_SignedInt_To_Ascii: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
    ; convert an unsigned 32bit integer in eax to a string of decimal digits 
    ; the string will be stored in buffer pointed to by ebx 
    ; ecx will store the count of decimal digits 
 
    ; eax -- the integer (a signed integer) 
    ; ebx -- pointer to string buffer (assumed to be at least 12 bytes!!) 
    ; CL -- counter of decimal digits 
    ; CH -- store whether the number is negative so we can add '-' at the end 
 
    ; note because we work backwards from low to high digit we fill in from 
    ; the 12 byte in buffer and return pointer to first character of the 
    ; decimal version, which likely will not be the first byte of the buffer 
    ; calling code needs to keep track of it's original buffer pointer 
 
    add ebx,11       ; point to 12th byte of buffer (we will fill the digits in "backwards") 
 
    mov ecx, 0       ; clear ecx -- we will be using it's components, CL and CH 
 
    ; these two commands are unnecessary with the command above (redundant) but are here for clarity 
    mov CL, 0        ; initial digit count is zero 
    mov CH, 0        ; initially assume we have a positive number to convert 
     
    ; handle negative 
    cmp eax, 0 
    jge  _UnsignedInt_to_Ascii_Loop    ; "jump if greater or equal", so skip next command if not negative 
     
    mov CH, 1     ; put a 1 in CH to "remember" that we have a negative, so we can put in a '-' later 
    imul eax, -1  ; work with the positive (absolute) value from here on out 
          
_UnsignedInt_to_Ascii_Loop: 
 
    mov esi, 10       ; we will be dividing by 10, keep it here… 
                      ; using ebp to store divisor, to avoid collision with esi&edi used by fibonacci program 
 
    mov edx,0x00000000 ; idiv uses [edx:eax], as a 64 bit dividend, so make sure we zero out 
                       ; edx because we only want to work with 32 bit number in eax 
                       ; we need to do this every time because we use DL (part of EDX) later in the loop 
     
    idiv esi          ; this will calculate [edx:eax] / esi 
                      ;    quotient --> eax 
                      ;    remainder --> edx 
 
    add edx,0x30      ; add ascii code of '0' to remainder(which is put in edx by div command) 
                      ; conveniently, this gives ascii code of the digit,  
                      ;    because the ascii codes of digits are in order 0x30...0x39 
 
    mov [ebx], dl     ; store the digit into its position in the buffer 
                      ; the dl register is the least significant byte of the ecx register 
                      ; there is also dh, the second lowest byte of edx 
                      ; and dx is the lower two bytes of edx (so dx is dh:dl) 
                      ; these are literall parts of the same register, so changing dl would chance edx 
 
    dec ebx           ; decrement ebx to point to byte position of next decimal digit 
                      ; (right to left) 
                       
    inc CL            ; increment our digit counter (character counter, actually, because includes '-') 
 
 
    cmp eax, 0                       ; check if eax is zero... 
    jne _UnsignedInt_to_Ascii_Loop   ; if it was NOT a zero, the loop back for next digit 
 
    inc ebx           ; ebx was decremented one extra time, increment so it points to actual 
                      ; last converted digit (leftmost digit, so the "first" digit as a human reads it) 
 
    cmp CH, 1         ; check whether original number was negative 
    jne _SkipMinusSign 
 
    dec ebx          ; decrement ebx to point to where the minus sign must go (right before the leftmost digit)     
    mov DL, '-'      ; put ascii code of minus sign into DL 
    mov [ebx],DL     ; put that ascii sign at the beginning of our ascii text number 
    inc CL           ; increment the character count of our converted number 
 
_SkipMinusSign: 
 
    mov CH,0          ; even though the character count should never be higher than 11 so needs just the one byte CL 
                      ; we return the count as a full 32bit integer in ECX, so need to make sure the higher byte in CH is 0. 
                      ; It may have been set to 1 for the a minus sign, which would make ECX a much larger count than 
                      ; just what is in CL. 
 
    ret               ; return -- note that ebx now points to first (most significant) digit of decimal string
