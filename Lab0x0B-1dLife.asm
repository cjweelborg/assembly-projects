section .data
	joke db "Try again.. with the correct input!", 0x0A
	lenJoke equ $ - joke
	nullterm db "Null term found!", 0x0A
	lenNullTerm equ $ - nullterm
	missingArg db "Missing command line argument", 0x0A
	lenMissingArg equ $ - missingArg
section .bss
	userinput resb 10
	linelength resb 10
	line resb 50
	newline resb 50

section .text
	global _start
	EXTERN printf
_start:
	;Initiate the stack
	push	ebp
	mov	ebp, esp

	cmp	dword [ebp+4], 1
	je	_missingArg

	mov	EDI, dword [ebp+12]
	mov	ESI, 0

;Loop to check the line to make sure it is correct
_checkLine:
	mov	byte AL, [EDI]

	;Compare to Null Term
	cmp	AL, 0x00
	je	_mainLoop

	;Compare to #
	cmp	AL, '#'
	je	_increment

	;Compare to [space]
	cmp	AL, ' '
	je	_increment

	;If not - then quit with a joke
	jmp	_quitWithJoke

;Increment EDI and jmp back to check the next character
_increment:
	;Jump back to check the next character
	inc	EDI
	inc	ESI
	jmp	_checkLine

;Loop for the number of iterations
_mainLoop:
	mov	EDI, dword [ebp+12]
;Length is already in ESI from the previous loop
	;Print the line
	mov	EDX, ESI
	mov	ECX, EDI
	mov	EBX, 1
	mov	EAX, 0x04
	int	0x80

	_nextLineLoop:
;Loop for creating the next line and storing it into EDI
	;First save the length (in ESI)
	push	ESI

	;Make EDX the counter for the loop
	mov	EDX, ESI
	mov	ECX, 0

		_createLine:
	; add 1 to a
	; b = string pointer
	; cmp [b + a]
		;Increment/Decrement the counters
		inc	ECX
		dec	EDX
		cmp	EDX, 0
		je	_printLine
			_innerLoop1:
			;ESI holds the length, EDI holds the string
			;Get the current character
			;mov	byte AL, [EDI]+ECX
			;Compare to Null Term
			cmp	AL, 0x00
			je	_printLine

			;Compare to #
			cmp	AL, '#'
			;je	_addLife1
			;Check the neighboring char -2
			;Check the neighboring char -1
			;Check the neighboring char +1
			;Check the neighboring char +2
;if(currentchar-2 EXISTS)
;	if(neighborchar-2 == #)
;		total+1
;if(currentchar-1 EXISTS)
;	if(neighborchar-1 == #)
;		total+1
;if(currentchar+1 EXISTS)
;	if(neighborchar+1 == #)
;		total+1
;if(currentchar+2 EXISTS)
;	if(neighborchar+2 == #)
;		total+1
;
;if(currentchar == #)
;	if(total == 0 || total == 1 || total == 3)
;		currentchar "dies" (# = ' ')
;
;if(currentchar == ' ')
;	if(total == 2 || total == 3)
;		currentchar is "born" (' ' = #)  

	_printLine:
	;Restore the length
	pop	ESI

	;Print the line
	mov	EDX, ESI
	mov	ECX, EDI
	mov	EBX, 1
	mov	EAX, 0x04
	int	0x80

;Print out the next line

;Set the next line as the seed for the following line

;Get input for the next line to print
	mov	EDX, 10
	mov	ECX, userinput
	mov	EBX, 1
	mov	EAX, 0x03 ;sys_read
	int	0x80
;If the user presses enter loop back
	mov	EBX, userinput
	mov	byte CH, [EBX]
	cmp	CH, 0x0A
	je	_nextLineLoop
;If the user presses q - then quit
	cmp	CH, 'q'
	je	_quit

_quitWithJoke:
	;Sys_write joke
	mov	EDX, lenJoke
	mov	ECX, joke
	mov	EBX, 1
	mov	EAX, 0x04
	int	0x80

	;Jump to quit
	jmp	_quit

_missingArg:
	;Sys_write missingArg
	mov	EDX, lenMissingArg
	mov	ECX, missingArg
	mov	EBX, 1
	mov	EAX, 0x04
	int	0x80

	;Jump to quit
	jmp	_quit
_quit:
	mov	EBX, 0
	mov	EAX, 1
	int	0x80
