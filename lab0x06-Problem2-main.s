	.file	"lab0x06-Problem2-main.c"
	.intel_syntax noprefix
	.section	.rodata
	.align 4
.LC2:
	.string	"Number of Calls to sumAtoB: %d, m=%d, n=%d, Result=%d,  Total time spent in sumAtoB: %Lf\n"
	.text
	.globl	main
	.type	main, @function
main:
	lea	ecx, [esp+4]
	and	esp, -16
	push	DWORD PTR [ecx-4]
	push	ebp
	mov	ebp, esp
	push	ecx
	sub	esp, 84
	fldz
	fstp	TBYTE PTR [ebp-40]
	mov	DWORD PTR [ebp-60], 0
	jmp	.L2
.L4:
	mov	eax, DWORD PTR [ebp-60]
	sub	eax, 32000
	mov	DWORD PTR [ebp-56], eax
	call	clock
	mov	DWORD PTR [ebp-52], eax
	sub	esp, 8
	push	DWORD PTR [ebp-60]
	push	DWORD PTR [ebp-56]
	call	sumAtoB
	add	esp, 16
	mov	DWORD PTR [ebp-48], eax
	call	clock
	mov	DWORD PTR [ebp-44], eax
	mov	eax, DWORD PTR [ebp-44]
	sub	eax, DWORD PTR [ebp-52]
	mov	DWORD PTR [ebp-76], eax
	fild	DWORD PTR [ebp-76]
	fld	TBYTE PTR .LC1
	fdivp	st(1), st
	fstp	TBYTE PTR [ebp-24]
	fld	TBYTE PTR [ebp-40]
	fld	TBYTE PTR [ebp-24]
	faddp	st(1), st
	fstp	TBYTE PTR [ebp-40]
	mov	ecx, DWORD PTR [ebp-60]
	mov	edx, 274877907
	mov	eax, ecx
	imul	edx
	sar	edx, 7
	mov	eax, ecx
	sar	eax, 31
	sub	edx, eax
	mov	eax, edx
	imul	eax, eax, 2000
	sub	ecx, eax
	mov	eax, ecx
	test	eax, eax
	jne	.L3
	push	DWORD PTR [ebp-32]
	push	DWORD PTR [ebp-36]
	push	DWORD PTR [ebp-40]
	push	DWORD PTR [ebp-48]
	push	DWORD PTR [ebp-60]
	push	DWORD PTR [ebp-56]
	push	DWORD PTR [ebp-60]
	push	OFFSET FLAT:.LC2
	call	printf
	add	esp, 32
.L3:
	add	DWORD PTR [ebp-60], 1
.L2:
	cmp	DWORD PTR [ebp-60], 64000
	jle	.L4
	nop
	mov	ecx, DWORD PTR [ebp-4]
	leave
	lea	esp, [ecx-4]
	ret
	.size	main, .-main
	.section	.rodata
	.align 16
.LC1:
	.long	0
	.long	-198967296
	.long	16402
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
