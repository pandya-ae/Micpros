%INCLUDE "winAPI.inc"		;;Declare external procedure {winapi}
%INCLUDE "Console1.mac"		;;Macro definition

section .data
cTitle   	db "Hellooooo",0 

msg1 		db 13,10,13,10,"YOUR NAME : ",0
msg1_len 	dd $-msg1

mbtitle 	db 'Hello ',0
mbtext		db 'Good Morning '
buff		resb 64
buff_len	dd 64

text2   	db ' -- God Bless You !!!',0
ptext2  	dd $-text2

teks3		db 13,10,13,10,"Again ? (y/n) : ",0 
pteks3	    dd $-teks3

section .bss
hStdOut		resd 1 
hStdIn		resd 1 
nBytes		resd 1
iBytes		resd 1

section .text use32
..start:
NewConsole 	cTitle, hStdOut, hStdIn

Again:
DisplayText	hStdOut, msg1, msg1_len, nBytes
GetText		hStdIn, buff, buff_len, iBytes

CALL mbox

DisplayText	hStdOut, teks3, pteks3, nBytes
GetText		hStdIn, buff, buff_len, iBytes

mov ebx, buff
mov al, [ebx]
cmp al, 'y'
JE Again

QuitConsole
	
RET

; Display on MessageBox 
;-------------------------------------------------------------------------------------
mbox:
 mov esi, buff			; mbtext + buff + text2 (concatenate 3 string)
 add esi, [iBytes]
 sub esi,2

 mov dl,' '
 mov [esi], dl
 inc esi
 mov ecx, [ptext2]
 mov ebx, text2
 cptx:
	mov dl, byte [ebx]
	mov [esi], dl
	inc esi
	inc ebx
 loop cptx
 
 push dword 30h			; Button OK | icon exclamation
 push dword mbtitle		
 push dword mbtext  	
 push dword 0			

 call [MessageBoxA]

ret

