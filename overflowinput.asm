section .data
    user db '13',0x0A
    hack db '12345678901234567890',0xF7,0x00

extern printf
global _start
extern printf

_start:
	push hack
	call printf
	add esp, 4
	push user
	call printf
	add esp, 4

_exit:
	mov ebx, 0
	mov eax, 1
	int 0x80
