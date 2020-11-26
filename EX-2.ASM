segment data 
TEXT1:  db	13, 10,"COPY FROM STR1 TO STR2", 13, 10, "$"

STR1:  db	13, 10,"THIS LINE WILL BE COPIED", 13, 10, "$"

segment bss

STR2:	resb 64

segment stack stack 
        resb 64
stacktop:

segment code 
..start:
        mov     ax,data
        mov     ds,ax
        mov     ax,stack
        mov     ss,ax
        mov     sp,stacktop
		
		mov     dx,TEXT1
        mov     ah,9
        int     0x21
		
		mov     dx,STR1
        mov     ah,9
        int     0x21
		
		mov		si,STR1
		mov		di,STR2
	
	again:	
		mov		al,[si]
		mov		[di], al
		cmp		al, "$"
		je		next
		inc		si
		inc		di
		jmp		again
		
	next:
		mov     dx,STR2
        mov     ah,9
        int     0x21

		mov     ax,0x4c00
        int     0x21