section .data

section .bss

section .text
   GLOBAL _replaceChar

   ; (Param 1) Pointer to textLines should be [EBP+8]
   ; (Param 2) Length of textLines should be [EBP+12]
   ; (Param 3) Pointer to searchCharacter should be [EBP+16]
   ; (Param 4) Pointer to replaceCharacter should be [EBP+20]


_replaceChar:
   ; save the caller's stack frame
   push EBP
   mov EBP, ESP
   mov ESI, 0

   ; reserve space for local variables
   ; sub ESP, numberOfBytesNeeded

   ; save registers if needed

   ; actually start the _replaceChar function

   ; Setup parameters in regs for searching loop
   ; move length of textLines into EDX 
   mov EDX, [EBP+12]
   ; move searchChar into ECX
   mov ECX, [EBP+16]
   ; move textLines into EBX
   mov EBX, [EBP+8]

   ; setup the searchCharacter (get the first character entered into the searchCharacter buffer)
   mov byte AH, [ECX]
   ; since that is setup, put the replaceCharacter into ECX and setup into CH
   mov ECX, [EBP+20]
   mov byte CH, [ECX]

_searchLoop:
   ; move through byte by byte comparing each character to the searchCharacter
   mov byte AL, [EBX]
   ; compare the current byte to the searchCharacter and if they are the same, replace the character
   cmp AH, AL
   je _replace
_finishLoop:
   ; increment the textLines pointer
   inc EBX

   ; decrement the length
   ; if end of line move to wrapup
   dec EDX
   jz _WrapUp
   jmp _searchLoop

_replace:
   ; replace the character with replaceCharacter which is in CH
   mov byte [EBX], CH
   ; increment EAX for the counter of replaced characters
   inc ESI
   jmp _finishLoop

_WrapUp:

;;;;TO DO;;;;

   ; restore registers
   ; pop reg

   ; restore local variables
   ; add ESP, numberOfBytesNeeded
   ; move ESP, EBP                 alternative to adding to ESP

   ; set counter to EAX
   mov EAX, ESI
   ; restores caller's frame pointer
   pop EBP

   ;return to caller
   ret
