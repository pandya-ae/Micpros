%INCLUDE "winAPI.inc"		;;Declare external procedure {winapi}
%INCLUDE "Console1.mac"		;;Macro definition

SEGMENT .DATA use32
cTitle   	db "Hellooooo",0 

msg1 		db 13,10,13,10,"YOUR NAME : ",0
msg1_len 	dd $-msg1

mbtitle 	db 'Hello ',0
mbtext		db 'Good Morning '
buff		resb 16
buff_len	dd 16

text2   	db ' -- God Bless You !!!',0
ptext2  	dd $-text2


SEGMENT .BSS  use32
hStdOut		resd 1 
hStdIn		resd 1 
nBytes		resd 1
iBytes		resd 1

SEGMENT .CODE use32
..start:
NewConsole 	cTitle, hStdOut, hStdIn

DisplayText	hStdOut, msg1, msg1_len, nBytes
GetText		hStdIn, buff, buff_len, iBytes

CMP dword [iBytes],2    ;; if just Enter (2 char) then Exit
JE  Exitloop

CALL mbox

Exitloop: 
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

