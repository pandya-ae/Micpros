%INCLUDE "winAPI.inc"		;;Declare external procedure {winapi}
%INCLUDE "Console1.mac"		;;Macro definition

SEGMENT .DATA use32
Title   	db "LOWERCASE AND REVERSED TEXT",0

msg1 		db 13,10,13,10,"WRITE TEXT (Enter to quit): ",0
msg1_len 	dd $-msg1
msg2 		db 13,10,"YOUR TEXT                   : ",0
msg2_len 	dd $-msg2
msg3 		db 13,10,"CONVERTED TEXT              : ",0
msg3_len 	dd $-msg3
msg4		db 13,10,"REVERSED TEXT               : ",0
msg4_len	dd $-msg4


buff		resb 255
buff_len	dd 255

buffC		resb 255
buffC_len	dd 255

buffR		resb 255
buffR_len	dd 255


SEGMENT .BSS  use32
hStdOut		resd 1
hStdIn		resd 1
nBytes		resd 1
iBytes		resd 1

SEGMENT .CODE use32
..start:

NewConsole 	Title, hStdOut, hStdIn

Again:
DisplayText	hStdOut, msg1, msg1_len, nBytes
GetText		hStdIn, buff, buff_len, iBytes

CMP dword [iBytes],2
JE  Exitloop

DisplayText	hStdOut, msg2, msg2_len, nBytes
DisplayText	hStdOut, buff, iBytes, nBytes

CALL LowtoUpp

DisplayText	hStdOut, msg3, msg3_len, nBytes
DisplayText	hStdOut, buffC, iBytes, nBytes		; Uppercased

CALL Reverse

DisplayText	hStdOut, msg4, msg4_len, nBytes
DisplayText	hStdOut, buffR, iBytes, nBytes	; Reversed

JMP Again

Exitloop:
   QuitConsole

RET

; CONVERT Lowercase to Uppercase
;-------------------------------------------------------------------------------------
LowtoUpp:
   mov ecx, [iBytes]
   mov ebx, dword buff
   mov edi, buffC
   dec ebx                          ; adjust count to offset
   dec edi							; same	

	Testlow:
		mov al,byte[ebx+ecx]
		mov byte[edi+ecx],al
		cmp byte[edi+ecx],0x61		; ebx+ecx below 'a'
		jb Decrement
		cmp byte[edi+ecx],0x7A		; ebx+ecx above 'z'
		ja Decrement
		sub byte[edi+ecx],0x20 			; uppercased

	Decrement:
		dec ecx                     ; next character for source
		jnz Testlow

ret

; REVERSE text
;-------------------------------------------------------------------------------------
Reverse:
	mov ebx, dword buff
	mov edi, dword buffR
	mov ecx, [iBytes]
	add ebx, ecx
	sub ebx,3


	loop:
		mov al, byte[ebx]
		mov [edi], al
		dec ebx
		inc edi
		loop loop

ret

