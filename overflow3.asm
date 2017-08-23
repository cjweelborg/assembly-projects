section .data

     prompt db "Please enter some text: ",0x0A,0x00
     
     strFmt db " %s",0x00
     numFmt db "%d",0x0A,0x00
     something dd 0x00000A0A
     
section .bss


extern printf
extern gets  

section .text
  global _start

_start:  

  push dword [something]
  call _hackThis
  add esp, 4
  
_exit:
    mov     ebx,0               ;first syscall argument: exit code
    mov     eax,1               ;system call number (sys_exit)
    int     0x80                ;call kernel 
  
_hackThis:  
    push ebp
    mov ebp, esp
    
    sub esp, 24    ; space for local variables:
                   ;    int x; //4 bytes
                   ;    char word[20]; // 20 bytes
    
    mov ebx, [ebp+8]
    mov [ebp-4], ebx    ; copy parameter value into x
    
    push prompt
    call printf
    add esp,4
    
    mov eax, ebp
    sub eax, 24
    push eax       ; push pointer to word char array
    call gets
    add esp, 4
    
    mov eax, [ebp-4]
    add eax, 777
    
    push eax
    push numFmt
    call printf
    add esp,8
    
    mov esp,ebp
    pop ebp
    ret
    
    
    
    
    
    
  
  

