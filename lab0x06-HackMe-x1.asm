section .data
    globalMagic dd 1882206274    ; note: dd -- 4 byte word (unsigned integer)

    userIds dd 0xBEEF, 13, 42, 99, 0xFACE 
    nUsers equ $ - userIds 
    userMagic dd 0x55673e77,  0x31302531,  0x5439214c,  0x6a1a2925,  0x250c3449,
    
    userIdPrompt db "<<<*>>>",0x0A,"Enter User ID: ",0x00
    userIdScanFmt db "%d",0x00
    userNotFoundMsg db "That user does not exist in our records.  Are you some kind of Hacker?  Not a very good one...",0x0A,0x00
    getKeyPrompt db "Enter validation key (16 characters): ",0x00
    getKeyFmt db "%s",0x00
    authFailMsg db "Null Zone Access:  Denied.",0x0A,"Invalid Key. You call yourself a hacker? You'll have to do better than that!",0x0A,"...@@@Downloading Countermeasures@@@....",0x0A,"Your system will self-destuct in 3...",0x0A,"2...",0x0A,"1...",0x0A,0x00
    welcomeToNullZone db "Null Zone Access:  Granted.",0x0A,"Welcome, Agent %d",0x0A,"We've been expecting you...",0x0A,0x00
    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss
    enteredUserId resb 4
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global _start
extern printf
extern scanf

section .text

_start:
   
    ; ask for user ID
    push userIdPrompt
    call printf
    add esp, 4
    
    ; read user ID
    push enteredUserId
    push userIdScanFmt
    call scanf
    add esp, 8
    
    ; find the user's modulated key    
    mov ecx, 0
  _findUserIdLoop:
    mov edx, [enteredUserId]
    cmp edx, [userIds+4*ecx]
    je  _userIdFound
    inc ecx
    cmp ecx, nUsers
    je  _userNotFound
    jmp _findUserIdLoop
    
  _userIdFound:    
    push dword [enteredUserId]
    push dword [userMagic + 4*ecx]
    push dword [globalMagic]
    call _authenticate    
    add esp, 8
    jmp _exit
    
  _userNotFound:
    push userNotFoundMsg
    call printf
    add esp, 4
    
_exit:
    mov     eax, 1    ;sys_exit
    xor     ebx, ebx
    int     80H    

_authenticate:
    push ebp
    mov ebp, esp
    
    ; make space on stack for local variables:
    ; [ebp-4]  -- reserved
    ; [ebp-8]  -- modulated key we will compare against (we be globalMagic XOR userMagic)
    ; [ebp-28] -- plain text key entered by user
    sub esp, 28
    
    ; get derive modulated key from magic numbers
    mov eax, [ebp+8]  ; first magic number (should be the global magic number)
    xor eax, [ebp+12] ; second magic number (should be the user-specific magic number)
    mov [ebp-8], eax  ; saved derived modulated key to local variable
    
    ; prompt the user for 16 caharcter key
    push getKeyPrompt
    call printf
    add esp, 4
    
    ; read the key entered by user
    mov esi, ebp
    sub esi, 28
    push esi     ; pointer to the buffer space we just made on the stack
    push getKeyFmt
    call scanf
    add esp, 8
    
    ; modulate the plain text key 
    push dword [ebp+8]   ; globalMagic   -- NOTE: Parameters not in same order for _modulate as for _authenticate
    push dword [ebp+16]  ; user ID --       so the offsets will be different
    mov eax, ebp
    sub eax, 28    ; 
    push eax       ; pointer the the key code buffer on the stack
    call _modulate ; modulate the keycode, return value in EAX will be the modulated plain text key
    add esp, 12

    ; check modulated plain text key against the derived modulated key
    mov edx, [ebp-8 ] ; the modulated key that was derived from userMagic and globalMagic
    cmp edx, eax      ; comparing the derived modulated key for the userID with the modulated key that was just entered
                      ; ***** THIS IS WHERE IT IS DECIDED WHETHER TO GRANT ACCESS *****



    je _validKey
    jmp _invalidKey
    
  _validKey:
    push dword [ebp+16]; user Id
    push dword [ebp+8] ; magic
    call _NullZone
    add esp, 8
    mov eax, 1  ; return value -- sucess
    jmp _wrapupAuthenticate
    
  _invalidKey:
    push authFailMsg
    call printf
    add esp, 4
    mov eax, 0 ; return value -- failure
    
  _wrapupAuthenticate:
    add esp, 28 ; restore local variable space from stack
    pop ebp     ; restore caller's frame pointer
    ret
    

_modulate:
    push ebp,
    mov ebp, esp
    
    mov edx, [ebp+8]     ; pointer to key code 
    mov eax, [ebp+16]    ; magic     -- notice the different offset vs. the offset in _authenticate, because different ordering
    xor eax, [ebp+12]    ; salted with the userId 
    mov ecx, 16          ; keys are always exactly 16 bytes
  _modLoop:
    dec ecx
    xor byte al, [edx]
    rol eax, 5            ; shift/rotate left(coutnerclockwise) bits of EAX by 5 bit positions
    inc edx
    cmp ecx, 0
    jz _modwrap
    jmp _modLoop
  _modwrap:
    and eax, 0x7F7F7F7F   ; bitwise logical "AND"     

    pop ebp
    ret                   ; the requisite modulation is in EAX, so return
    
    
_NullZone:
    push ebp
    mov ebp,esp
    
    push dword [ebp+12]  ; and now, here in _NullZone, the userID is in EBP+12...
    push welcomeToNullZone
    call printf    
    add  esp, 8
    
    pop ebp
    ret
    
    
    
    
    
    
    

