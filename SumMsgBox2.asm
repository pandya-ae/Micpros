%INCLUDE "winAPI.inc"		;;Declare external procedure {winapi}
%INCLUDE "Console1.mac"		;;Macro definition

SEGMENT .DATA use32
Title   	db "Sum",0 

msg1 		db 13,10,13,10,"Input number (sum < 65536) (just press enter to sum, ctrl+c to exit)",13,10
msg1_len 	dd $-msg1		

mbtitle 	db 'Sum ',0
mbtext		db 'The sum: '

buff		resb 255
buff_len	dd 255

strhasil	dd '      ',0
str_len		db 6   


SEGMENT .BSS  use32
hStdOut		resd 1 
hStdIn		resd 1 
nBytes		resd 1
iBytes		resd 1
rBytes		resd 1
num			resd 1

SEGMENT .CODE use32
..start:

NewConsole 	Title, hStdOut, hStdIn

Again:


DisplayText	hStdOut, msg1, msg1_len, nBytes

again1:
mov eax,0
mov [num],eax

GetText		hStdIn, buff, buff_len, iBytes

CMP dword [iBytes],2    ;; if just Enter (2 char) then Exit
JE  Exitloop

CALL Str2Numeric
jmp again1

Exitloop:
CALL Numeric2StrT

CALL mbox

cmp eax,4
JE Again
QuitConsole

RET

; CONVERT STRING (buff) TO Numeric (rBytes)
;-------------------------------------------------------------------------------------
Str2Numeric:
	mov ecx, [iBytes]
	mov esi, dword buff
	sub ecx, 2
	
	loop:
		movzx eax, byte[esi]
		sub eax, '0'
		mov ebx, ecx
		dec ecx
		cmp ecx,0
		je fin
		mult:
			imul eax,10
			loop mult
		mov ecx, ebx
		add [num], eax
		inc esi
		loop loop
		
	fin:
		add [num],eax
ret

;other version
;Str2Numeric:
;	xor eax,eax
;	mov esi, 10
;	mov ebx, buff
;	mov ecx, [iBytes]
;	sub ecx, 2
;	xor edx, edx
;	
;	loopnum:
;		mul esi
;		mov dl, byte[ebx]
;		sub dl, 0x30
;		add eax, edx
;		inc ebx
;		loop loopnum
;		
;	mov [num], eax
;ret

ret
; CONVERT Numeric (iBytes) TO STRING (strhasil) 
;-------------------------------------------------------------------------------------
Numeric2StrT: 
	mov ebx, strhasil
	mov eax, [num]
	mov si, 10

loop1:				
	inc ebx				;; ebx digunakan sebagai pointer ke strhasil
	cmp byte[ebx],0		;; diposisikan pada akhir string strhasil 
	jne loop1		
	
	dec ebx

loop2:				
	xor edx, edx		;; edx di-nolkan untuk menampung sisa bagi
	div si				;; dilakukan pembagian 10 berulang
	add dl, '0'        	;; sisa bagi pada edx (dl) di ubah ke character
	mov [ebx], dl		;; simpan ke strhasil dari belakang ke depan
	dec ebx				;; majukan pointer
	or  eax,eax			;; test apakah yang dibagi sudah nol
	jnz loop2 			;; selesai perulangan jika yang dibagi sdh nol   

ret

; Display on MessageBox 
;-------------------------------------------------------------------------------------
mbox:
	mov ecx, strhasil
	add ecx, str_len			; mbtext + buff + text2 (concatenate 3 string)
	mov esi, ecx
	
	push dword 5			; Button OK | icon exclamation
	push dword mbtitle		
	push dword mbtext  	
	push dword 0			
	
	call [MessageBoxA]

ret

