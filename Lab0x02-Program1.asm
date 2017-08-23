section .bss 
    readBuf    resb 1000 
    reverseBuf resb 1000 
    bufSize equ 1000 
  
    saveCount  resb 4 
     
section .data 
    prompt  db "Hello, please type something in",0x0A 
    promptLen equ $ - prompt 
    
    newLine db 0x0A
    newLineLen equ $ - newLine 
     
section .text 
    global _start 
     
_start: 
    mov  edx, 33       ;  
    mov  ecx, prompt   ;  
    mov  ebx, 1        ;  
    mov  eax, 0x04     ; sys_write (why am I using hex for this? I dunno, looks cool... 
    int  0x80 

    jmp _skipLine

_nextLine: 

    mov  edx, newLineLen;  
    mov  ecx, newLine  ;  
    mov  ebx, 1        ;  
    mov  eax, 0x04     ; sys_write (why am I using hex for this? I dunno, looks cool... 
    int  0x80 
_skipLine:

    mov  edx, bufSize  ; max number of bytes to read 
    mov  ecx, readBuf  ; address of buffer to store bytes from input 
    mov  ebx, 0        ; stdin file descriptor 
    mov  eax, 0x03     ; sys_call read 
    int  0x80          ; generate interrupt to trigger kernal system call 
     
    mov [saveCount], eax       ; save the count of byte into esi 
     
    ; maybe we should check for failure here (return value negative??) 
     
    ;now let's just echo the text back out... 
    mov  edx, eax      ;  
    mov  ecx, readBuf  ;  
    mov  ebx, 1        ;  
    mov  eax, 0x04     ; sys_write (why am I using hex for this? I dunno, looks cool... 
    int  0x80 
 
    mov edx, readBuf  ; pointer into original readBuf, the will step backwards 
                      ; should start at last byte 
    mov ecx, [saveCount]  ; get our save count of bytes 
    add edx, ecx 
    sub edx, 2        ; pointer to last character typed (excluding newline) 
     
    mov ecx, reverseBuf  ; first byte of reverseBuf 
 
    mov eax, [saveCount]  ; get the count again (not the most efficient way to do this) 
    sub eax, 1            ; sub 1 for the newline 
 
_ReverseLoop:     
    mov byte BL, [edx]  ; move byte from readBuf into BL 
    mov byte [ecx], BL  ; move it out to the reverse buffer 
     
    dec edx     ; step backwards through read buffer 
    inc ecx     ; step forwards through reverse buffer 
      
    dec eax     ; count down 
 
                ; alternative: we could compare edx to readBuf 
    jnz _ReverseLoop    
     
    ;now let's just echo the text back out... 
    mov  edx, [saveCount] ;  
    mov  ecx, reverseBuf  ;  
    mov  ebx, 1           ;  
    mov  eax, 0x04        ; sys_write (why am I using hex for this? I dunno, looks cool... 
    int  0x80     
 
     
    ; now let's see if we can reverse the text... 
    jmp _nextLine
     
    ; exit cleanly 
    _exit: 
    mov     ebx,0               ;first syscall argument: exit code 
    mov     eax,1               ;system call number (sys_exit) 
    int     0x80                ;call kernel
