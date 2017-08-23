section .bss
	outBuf resb 4

section .text
	global _start

	seed0 equ 0
	seed1 equ 1

_start:	
	mov esi, seed0
	mov edi, seed1

	;print out esi
	mov [outBuf], esi	; put the bytes in esi out to memory in location outBuf
	call _printNum
	
	;print out ebx
	mov [outBuf], edi	;put the bytes in edi out to memory at location outBuf
	call _printNum


_fibloop:
	add esi, edi		;Puts the sum into esi
	jc _exitCleanly		;Jumps on Overflow and exits the program

	; Prints esi
	mov [outBuf], esi
	call _printNum

	add edi, esi		;Puts the sum into edi
	jc _exitCleanly		;Jumps on overflow and exits the program

	; Prints edi
	mov [outBuf], edi
	call _printNum

	jmp _fibloop		;Jumps if there is no overflow

_exitCleanly:
	mov ebx, 0
	mov eax,1
	int 0x80

_printNum:
	mov edx, 4		; length of text
	mov ecx,outBuf		; pointer to start of message
	mov ebx,1		; file descriptor for stdout
	mov eax,4		; 4 is the code for the sys_write
	int 0x80		; software interrupt to do a system call
	ret

section .data

