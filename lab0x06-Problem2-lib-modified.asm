section .data

section .text

global sumAtoB
sumAtoB:
	push	ebp
	mov	ebp, esp
	sub	esp, 16
	mov	eax, DWORD [ebp+8]
	mov	ebx, DWORD [ebp-8]
	mov	ecx, DWORD [ebp-4]
	mov	ebx, eax
	mov	ecx, 0
	jmp	L2
L3:
	mov	eax, ebx
	add	ecx, eax
	add	ebx, 1
L2:
	mov	eax, ebx
	cmp	eax, DWORD [ebp+12]
	jle	L3
	mov	eax, ecx
	leave
	ret
