	.file	"lab0x06-Problem2-lib-original.c"
	.intel_syntax noprefix
	.text
	.globl	sumAtoB
	.type	sumAtoB, @function
sumAtoB:
	push	ebp
	mov	ebp, esp
	sub	esp, 16
	mov	eax, DWORD PTR [ebp+8]
	mov	DWORD PTR [ebp-8], eax
	mov	DWORD PTR [ebp-4], 0
	jmp	.L2
.L3:
	mov	eax, DWORD PTR [ebp-8]
	add	DWORD PTR [ebp-4], eax
	add	DWORD PTR [ebp-8], 1
.L2:
	mov	eax, DWORD PTR [ebp-8]
	cmp	eax, DWORD PTR [ebp+12]
	jle	.L3
	mov	eax, DWORD PTR [ebp-4]
	leave
	ret
	.size	sumAtoB, .-sumAtoB
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
