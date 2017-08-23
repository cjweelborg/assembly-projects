section .data                   ;section declaration 
 
   prompt1 db 'Enter the first seed: '
   lenPrompt1 equ $-prompt1

   prompt2 db 'Enter the second seed: '
   lenPrompt2 equ $-prompt2

section .bss 
   num1 resb 15
   lenNum1 equ $-num1
   num2 resb 10
   lenNum2 equ $-num2

   outbuf resb 4 
   printBuffer resb 20  ; bugger to store ascii text decimal number to be printed 
 
section .text 
   global _start 
  
_start:

   ;Print the prompt for num1
   mov edx, lenPrompt1
   mov ecx, prompt1
   mov ebx, 1
   mov eax, 4
   int 0x80

   ;Read in num1
   mov edx, lenNum1
   mov ecx, num1
   mov ebx, 0
   mov eax, 3
   int 0x80

mov edx, num3entered ; our string
atoi:
xor eax, eax ; zero a "result so far"
.top:
movzx ecx, byte [edx] ; get a character
inc edx ; ready for next one
cmp ecx, '0' ; valid?
jb .done
cmp ecx, '9'
ja .done
sub ecx, '0' ; "convert" character to number
imul eax, 10 ; multiply "result so far" by ten
add eax, ecx ; add in current digit
jmp .top ; until done
.done:
ret






%include "asm_io.inc"


segment .data

promptForInt1	db	"Enter integer 1:",10,0
promptForInt2	db	"Enter integer 2:",10,0
promptForInt3	db	"Enter integer 3:",10,0
promptForInt4	db	"Enter integer 4:",10,0
printInt1		db	"This is the first integer (stored in M1):",10,0
printInt2		db	"This is the second integer (stored in M2):",10,0
printInt3		db	"This is the third integer (stored in N1):",10,0
printInt4		db	"This is the fourth integer (stored in N2):",10,0
sum				db	"This is the sum of integer 1 and 2 (stored in M3):",10,0
difference		db	"This is the difference of integer 1 and 2 (stored in M4):",10,0
product			db	"This is the product of integer 3 and 4 (stored in M5):",10,0
quotient		db	"This is the quotient of integer 3 and 4 (stored in N3):",10,0
modulo			db	"This is the modulo of integer 3 and 4 (stored in N4):",10,0

M1 dw 0
M2 dw 0
M3 dw 0
M4 dw 0
M5 dw 0
M6 dw 0

N1 db 0
N2 db 0
N3 db 0
N4 db 0

segment .bss


segment .text
	global  asm_main

asm_main:
	enter	0,0		; setup routine
	pusha
	;***************CODE STARTS HERE***************************

	mov eax, promptForInt1
	call print_string
	call read_int
	mov [M1], ax		;first integer stored in M1

	mov eax, promptForInt2
	call print_string
	call read_int
	mov [M2], ax		;second integer stored in M2

	mov bx, [M1]		;copy M1 to bx
	mov cx, [M2]		;copy M2 to cx
	mov dx, [M1]		;copy M1 to dx
	add dx, cx			;add cxM1 to dxM2
	mov [M3], dx		;store sum in M3
	mov dx, [M1]		;copy M1 to dx again
	sub dx, cx			;subtract cxM2 from dxM1
	mov [M4], dx		;store difference in M4

	mov eax, promptForInt3
	call print_string
	mov eax, 0
	call read_int
	mov [N1], al		;store third integer in N1

	mov eax, promptForInt4
	call print_string
	mov eax, 0
	call read_int
	mov [N2], al		;store fourth integer in N2
	
	mov eax, 0			;clear eax
	mov al, [N1]		;copy N1 to al
	mov bl, [N2]		;copy N2 to bl
	mul bl				;multiply bl and al, output in ax
	mov [M5], ax		;store product in M5
	
	mov eax, 0			;clear eax
	mov al, [N1]		;copy N1 to al again
	div bl				;divide bl and al, output in al
	mov [N3], al		;store product in N3
	mov [N4], ah		;store mod in N4
	
	;-------print integer 1-------
	mov eax, printInt1
	call print_string
	mov eax, 0
	mov ax, [M1]
	call print_int
	call print_nl
	call print_nl
	
	;-------print integer 2-------
	mov eax, printInt2
	call print_string
	mov eax, 0
	mov ax, [M2]
	call print_int
	call print_nl
	call print_nl
	
	;-------print integer 3-------
	mov eax, printInt3
	call print_string
	mov eax, 0
	mov al, [N1]
	call print_int
	call print_nl
	call print_nl
	
	;-------print integer 4-------
	mov eax, printInt4
	call print_string
	mov eax, 0
	mov al, [N2]
	call print_int
	call print_nl
	call print_nl
	
	;-------print sum-------
	mov eax, sum
	call print_string
	mov eax, 0
	mov ax, [M3]
	call print_int
	call print_nl
	call print_nl
	
	;-------print difference-------
	mov eax, difference
	call print_string
	mov eax, 0
	mov ax, [M4]
	call print_int
	call print_nl
	call print_nl
	
	;-------print product-------
	mov eax, product
	call print_string
	mov eax, 0
	mov ax, [M5]
	call print_int
	call print_nl
	call print_nl
	
	;-------print quotient-------
	mov eax, quotient
	call print_string
	mov eax, 0
	mov al, [N3]
	call print_int
	call print_nl
	call print_nl
	
	;-------print modulo-------
	mov eax, modulo
	call print_string
	mov eax, 0
	mov al, [N4]
	call print_int
	call print_nl
	call print_nl
	

	;***************CODE ENDS HERE*****************************
	popa
	mov	eax, 0		; return back to C
	leave
	ret

