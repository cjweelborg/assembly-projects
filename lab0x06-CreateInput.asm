section .data
    hack db '13',0x0A,'12345678909876543212',0x15,0x06,0x4f,0x48

extern printf
extern puts
extern stdout
extern fflush
global _start

section .text

_start:
	push hack
	call printf
	add esp, 4

	push dword [stdout]
	call fflush
	add esp,4

_exit:
	mov ebx, 0
	mov eax, 1
	int 0x80
