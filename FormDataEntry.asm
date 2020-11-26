%Include "FormDataEntry.INC"

WM_CREATE		equ 1h
WM_DESTROY		equ 2h
WM_COMMAND      equ 0111h
BN_CLICKED		equ 0h

EditID1			equ 1111
EditID2			equ 1112
EditID3			equ 1113

ButtonID0		equ 2220
ButtonID1		equ 2221
ButtonID2		equ 2222
ButtonID3		equ 2223

section .data 
ClassName		db "WindowForm", 0 			;Definisi Class Window
TitleBar		db "Form Data Entry", 0 
TitlemBox		db "Saved Data",0
TitleExit		db "Finish",0
ExitBox			db "EXIT ???",0

EditClassName   db "Edit",0					;Definisi Class EditBox
EditText		db "",0

LblClassName	db "Static",0				;Definisi Class Static untuk LABEL
LabelText1		db "Your Nama : ",0
LabelText2		db "Telp No.     : ",0
LabelText3		db "Address      : ",0

ButtonClassName	db "Button",0				;Definisi Class Button

ButtonText0      db "CLEAR",0
ButtonText1      db "DISPLAY",0
ButtonText2      db "QUIT",0
ButtonText3      db "SAVE",0


err_msg			db "Fail create Window. ", 0

buff1          	times 128 db 0 
buff2          	times 128 db 0
buff3          	times 128 db 0
blen1			resw 1
blen2			resw 1
blen3			resw 1
bufferA			times 1024 db 0

section .bss 
hInstance       resd 1 
CommandLine     resd 1
hWind			resd 1
hwndButton0     resd 1
hwndButton1     resd 1
hwndButton2     resd 1
hwndButton3     resd 1
hwndEdit1       resd 1
hwndEdit2       resd 1
hwndEdit3       resd 1
hwndLbl1		resd 1
hwndLbl2		resd 1
hwndLbl3		resd 1
 

;==========================================================================================================
section .text use32 
..start: 
GetModuleHandle
GetCommandLine
							;; WindowMain() require 4 paramater: 
push dword 10 				;; SW_SHOWDEFAULT is defined as 10
push dword [CommandLine]	;; CommandLine. 
push dword 0 				;; 0
push dword [hInstance]		;; hInstance	 
call WindowMain 
							 
push eax 					;; Then we exit the program, returning EAX
call [ExitProcess]			;; which is what WindowMain() will return. 
;======================================================================================================================= 

WindowMain:					;; WindowMain() function. 
    enter 76, 0 
	
    RegisterClass 			;; Create window-class and register
    CreateWindow ClassName, TitleBar, 500, 150, 500, 400 
	
	CreateLabel hwndLbl1, LabelText1, 55, 50, 90, 25
	CreateLabel hwndLbl2, LabelText2, 55, 80, 90, 25
	CreateLabel hwndLbl3, LabelText3, 55, 110, 90, 25
	
	CreateEditBox hwndEdit1, EditText, 150, 50, 270, 25, EditID1
	CreateEditBox hwndEdit2, EditText, 150, 80, 270, 25, EditID2
	CreateEditBox hwndEdit3, EditText, 150, 110, 270, 25, EditID3
	
	CreateButton hwndButton0, ButtonText0, 140, 300, 95, 25, ButtonID0
	CreateButton hwndButton1, ButtonText1, 240, 300, 95, 25, ButtonID1
	CreateButton hwndButton2, ButtonText2, 340, 300, 95, 25, ButtonID2
	CreateButton hwndButton3, ButtonText3, 40,  300, 95, 25, ButtonID3
		
	push dword [hwndEdit1]
	call [SetFocus]
	
    .MessageLoop: 
								 
        GetMessage 
        cmp eax, 0 				;; If GetMessage() returns 0, it's time to exit.
        jz .MessageLoopExit 
								 
		TranslateMsg	
		DispatchMsg

        jmp .MessageLoop 		;; And start the loop over again.
    
	.MessageLoopExit: 
								;; We'll need to jump over the error-handling routing, so we can continue. 
		jmp .finish 
    
    .new_window_failed: 
								;; Display a message box with the error message. 
        push dword 0 
        push dword 0 
        push dword err_msg 
        push dword 0 
        call [MessageBoxA] 
        						 
        mov eax, 1 				;; Exit, returning 1.
        leave 
        ret 16 
    
	.finish: 
    							;; We return the MSG.wParam value. 
    lea ebx, [ebp-72] 
    mov eax, dword [ebx+08] 
								;; It's time to leave. 
    leave 
								;; And, since WindowMain() has 4 arguments, we free 4 * 4 = 16 bytes from 
								;; the stack, after we return. 
ret 16 

;; WindowProcedure()take 4 arguments, which are as follows: 
;;    hWnd             The handle to the window that sent us that event. 
;;                     This would be the handle to the window that uses 
;;                     our window class. 
;;    uMsg             This is the message that the window sent us. It 
;;                     describes the event that has happened. 
;;    wParam           This is a parameter that goes along with the 
;;                     event message. 
;;    lParam           This is an additional parameter for the message. 
WindowProcedure: 
    
    enter 0, 0		;; We don't really need any local variables, for now, besides the function arguments.  
    
    mov eax, dword [ebp+12]		;; retrieve the uMsg value (the second argument) 
    
    cmp eax, WM_DESTROY			;; Compare EAX to WM_DESTROY, which is equal to 2. 
    jz .window_destroy          ;; If it's equal, jump to the .window_destroy label. 

    cmp eax, WM_COMMAND 		;; Else compare to WM_COMMAND
	jnz .window_default

	mov eax, dword [ebp+16]		;; If it's equal, retrieve wParam
	
	.cekbutton2:
	cmp eax, ButtonID2			;; If it's equal to ButtonID2
    jnz .cekbutton1

	call mBoxKonfirmasi

	shr eax, 16					;; Shiftleft 16bit to get Event
	cmp eax, BN_CLICKED			;; If it's Button-Click
	jz .window_destroy          ;; If it's equal, jump to .window_destroy label
    jmp .window_default			;; Else just jump to the window_default label.

	.cekbutton1:
	cmp eax, ButtonID1			;; If it's equal to ButtonID1
	jnz .cekbutton0

	shr eax, 16					;; Shiftleft 16bit to get Event
	cmp eax, BN_CLICKED			;; If it's Button-Click
	jz .show_data              	;; If it's equal, jump to .show_data label
    jmp .window_default			;; Else just jump to the window_default label.

	.cekbutton0:
	cmp eax, ButtonID0			;; If it's equal to ButtonID0
	jnz .cekbutton3
	shr eax, 16					;; Shiftleft 16bit to get Event
	cmp eax, BN_CLICKED			;; If it's Button-Click
	jz .clear_data              ;; If it's equal, jump to .clear_data

    jmp .window_default			;; Else just jump to the window_default label.

	.cekbutton3:
	cmp eax, ButtonID3			;; If it's equal to ButtonID0
	jnz .window_default
	shr eax, 16					;; Shiftleft 16bit to get Event
	cmp eax, BN_CLICKED			;; If it's Button-Click
	jz .get_data              ;; If it's equal, jump to .get_data label

    jmp .window_default			;; Else just jump to the window_default label.
    
    .window_destroy: 
        push dword 0 
        call [PostQuitMessage] 
        jmp .window_finish 

    .window_default: 
        push dword [ebp+20] 
        push dword [ebp+16] 
        push dword [ebp+12] 
        push dword [ebp+08] 
        call [DefWindowProcA] 

        leave 	;; WindowProcedure() has 4 arguments, 4 bytes each,         
        ret 16	;; so we free 4 * 4 = 16 bytes from the stack, after returning. 

	.show_data:
		call Copy_data
		call TampilkanIsi
		leave 
		ret 16

	.clear_data:
		SetTextEditBox [hwndEdit1], EditText
		SetTextEditBox [hwndEdit2], EditText
		SetTextEditBox [hwndEdit3], EditText
		leave 
		ret 16
	
	.get_data:	
		GetTextEditBox [hwndEdit1], buff1, 128, blen1
		GetTextEditBox [hwndEdit2], buff2, 128, blen2
		GetTextEditBox [hwndEdit3], buff3, 128, blen3	
		leave 
		ret 16
		
    .window_finish: 
		xor eax, eax                  ;; XOR EAX, EAX is a way to clear EAX. 
		leave 
		ret 16 

TampilkanIsi:
		push dword 0H			; tombol OK
		push dword TitlemBox	; judul message box
		push dword bufferA     	; Pesan yg ditampilkan, diakhiri dengan 0 (null)
		push dword [hWind]		; owner windows dari msgbox, atau NULL (tdk punya owner)
		call [MessageBoxA]
		ret

mBoxKonfirmasi:
		push dword 20H			; tombol OK
		push dword TitleExit	; judul message box
		push dword ExitBox     	; Pesan yg ditampilkan, diakhiri dengan 0 (null)
		push dword [hWind]		; owner windows dari msgbox, atau NULL (tdk punya owner)
		call [MessageBoxA]
		ret

Copy_data:
		mov EDI, bufferA
		mov ESI, buff1
		l1:
		   mov al,[ESI]
		   mov byte[EDI],al
		   INC ESI
		   inc EDI
		   cmp al,0
		   jne l1
		dec EDI
		mov byte[EDI],13
		inc EDI
		mov byte[EDI],10
		   
		mov ESI, buff2
		l2:
		   mov al,[ESI]
		   mov byte[EDI],al
		   INC ESI
		   inc EDI
		   cmp al,0
		   jne l2
		dec EDI
		mov byte[EDI],13
		inc EDI
		mov byte[EDI],10
		   
		mov ESI, buff3
		l3:
		   mov al,[ESI]
		   mov byte[EDI],al
		   INC ESI
		   inc EDI
		   cmp al,0
		   jne l3
		ret
