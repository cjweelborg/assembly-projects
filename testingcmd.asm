section .data
section .bss

section .text
	global _start
	EXTERN printf
	EXTERN strlen
_start:
	;Initiate the stack
	push	ebp
	mov	ebp, esp

	push	4
	call	strlen
	add	esp, 4

	mov	ESI, EAX
	push	ESI
	call	printf
	add	esp, 4
	jmp	_quit
_quit:
	mov	EBX, 0
	mov	EAX, 1
	int	0x80
