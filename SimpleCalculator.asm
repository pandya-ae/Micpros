%Include "Calculator.inc"

WM_CREATE		equ 1h
WM_DESTROY		equ 2h
WM_COMMAND      equ 0111h
BN_CLICKED		equ 0h

EditID1			equ 1111
EditID2			equ 1112
EditID3			equ 1113
EditID4			equ 1114

ButtonID0		equ 2220
ButtonID1		equ 2221
ButtonID2		equ 2222
ButtonID3		equ 2223
ButtonID4		equ 2224

section .data 
ClassName		db "Calculator", 0 			;DefiniSI Class Calculator
TitleBar		db "Simple Calculator", 0 
TitlemBox		db "Summing Result", 0
TitleExit		db "Finish", 0
ExitBox			db "EXIT", 0

EditClassName   db "Edit", 0					;DefiniSI Class EditBox
EditText		db "", 0

LblClassName	db "Static", 0				;DefiniSI Class Static untuk LABEL
LabelText1		db "1st Number	: ", 0
LabelText2		db "2nd Number	: ", 0
LabelText3		db "Result	: ", 0
LabelText4		db "Remainder	: ", 0

ButtonClassName	db "Button", 0				;DefiniSI Class Button
ButtonText0     db "+", 0
ButtonText1     db "-", 0
ButtonText2     db "*", 0
ButtonText3     db "/", 0
ButtonText4		db "EXIT", 0

DefaultValue	db "0", 0

err_msg			db "Fail create Window. ", 0

buff1          	times 128 db 0 
buff2          	times 128 db 0
blen1			resw 1
blen2			resw 1
bufferA			times 1024 db 0

shaSIl1          resb 512
shaSIl2          resb 512
strminus		 db "-"
strcopy			 resb 512

section .bss 
hInstance       resd 1 
CommandLine     resd 1
hWind			resd 1
hwndButton0     resd 1
hwndButton1     resd 1
hwndButton2     resd 1
hwndButton3     resd 1
hwndButton4		resd 1
hwndEdit1       resd 1
hwndEdit2       resd 1
hwndEdit3       resd 1
hwndEdit4       resd 1
hwndLbl1		resd 1
hwndLbl2		resd 1
hwndLbl3		resd 1
hwndLbl4		resd 1
nhaSIl1			dd 0
nhaSIl2			dd 0

;==========================================================================================================
section .text use32 
..start: 
GetModuleHandle
GetCommandLine
							;; WindowMain() require 4 paramater: 
PUSH dword 10 				;; SW_SHOWDEFAULT is defined as 10
PUSH dword [CommandLine]	;; CommandLine. 
PUSH dword 0 				;; 0
PUSH dword [hInstance]		;; hInstance	 
CALL WindowMain 
							 
PUSH EAX 					;; Then we exit the program, returning EAX
CALL [ExitProcess]			;; which is what WindowMain() will return. 
;======================================================================================================================= 

WindowMain:					;; WindowMain() function. 
    ENTER 76, 0 
	
    RegisterClass 			;; Create window-class and register
    CreateWindow ClassName, TitleBar, 500, 150, 500, 400 
	
	CreateLabel hwndLbl1, LabelText1, 20, 35, 110, 25
	CreateLabel hwndLbl2, LabelText2, 20, 65, 110, 25
	CreateLabel hwndLbl3, LabelText3, 20, 95, 110, 25
	CreateLabel hwndLbl4, LabelText4, 20, 125, 110, 25
	
	CreateEditBox hwndEdit1, EditText, 135, 35, 270, 25, EditID1
	CreateEditBox hwndEdit2, EditText, 135, 65, 270, 25, EditID2
	CreateEditBox hwndEdit3, EditText, 135, 95, 270, 25, EditID3
	CreateEditBox hwndEdit4, EditText, 135, 125, 270, 25, EditID4
	
	CreateButton hwndButton0, ButtonText0, 135, 170, 25, 25, ButtonID0
	CreateButton hwndButton1, ButtonText1, 165, 170, 25, 25, ButtonID1
	CreateButton hwndButton2, ButtonText2, 195, 170, 25, 25, ButtonID2
	CreateButton hwndButton3, ButtonText3, 225,  170, 25, 25, ButtonID3
	CreateButton hwndButton4, ButtonText4, 255,  170, 50, 25, ButtonID4
		
	PUSH dword [hwndEdit1]
	CALL [SetFocus]
	
    .MessageLoop: 
								 
        GetMessage 
        CMP EAX, 0 				;; If GetMessage() returns 0, it's time to exit.
        JZ .MessageLoopExit 
								 
		TranslateMsg	
		DispatchMsg

        JMP .MessageLoop 		;; And start the loop over again.
    
	.MessageLoopExit: 
								;; We'll need to jump over the error-handling routing, so we can continue. 
		JMP .finish 
    
    .new_window_failed: 
								;; Display a message box with the error message.
        PUSH dword 0 			;; MB_OK
        PUSH dword 0 			;; Report
        PUSH dword err_msg 		;; Display message
        PUSH dword 0 
        CALL [MessageBoxA] 
        						 
        MOV EAX, 1 				;; Exit, returning 1.
        LEAVE 
        RET 16 
    
	.finish: 
								;; We return the MSG.wParam value.
		lea EBX, [EBP-72] 		;; msg
		MOV EAX, dword [EBX+08] ;; msg + MSG.wParam 
		LEAVE 
		RET 16  

WindowProcedure: 
    ENTER 0, 0		
    MOV EAX, dword [EBP+12]		;; uMsg
    
    CMP EAX, WM_DESTROY		 
    JZ .window_destroy          ;; If EAX equal to WM_DESTROY, jump to .window_destroy

    CMP EAX, WM_COMMAND 		;; Else compare to WM_COMMAND
	JNZ .window_default

	MOV EAX, dword [EBP+16]		;; If it's equal, retrieve wParam
	
	.CheckButton4:
    CMP EAX, ButtonID4
	JNZ .CheckButton0
	
	CALL mBoxKonfirmaSI
	
	SHR EAX, 16					;; Shiftleft 16bit to get Event
	CMP EAX, BN_CLICKED			;; If it's Button-Click
	JZ .window_destroy          ;; If it's equal, jump to .window_destroy label
    JMP .window_default			;; Else just jump to the window_default label.
	
	.CheckButton0:
	CMP EAX, ButtonID0
	JNZ .CheckButton1
	
	SHR EAX, 16					;; Shiftleft 16bit to get Event
	CMP EAX, BN_CLICKED			;; If it's Button-Click
	JNZ .window_default
	
	GetTextEditBox [hwndEdit1], buff1, 128, blen1
	GetTextEditBox [hwndEdit2], buff2, 128, blen2
	str2int buff1
	MOV [buff1],EAX
	str2int buff2
	MOV [buff2],EAX
	
	MOV EAX, [buff1]
	MOV EBX, [buff2]
	ADD EAX,EBX
		
	MOV [nhaSIl1], EAX
	int2str [nhaSIl1], shaSIl1
	SetTextEditBox [hwndEdit3], shaSIl1		
	SetTextEditBox [hwndEdit4], DefaultValue
	
	.CheckButton1:
	CMP EAX, ButtonID1			;; If it's equal to ButtonID0
	JNZ .CheckButton2
	
	SHR EAX, 16					;; Shiftleft 16bit to get Event
	CMP EAX, BN_CLICKED			;; If it's Button-Click
	JNZ .window_default
	
	GetTextEditBox [hwndEdit1], buff1, 128, blen1
	GetTextEditBox [hwndEdit2], buff2, 128, blen2
	str2int buff1
	MOV [buff1], EAX
	str2int buff2
	MOV [buff2], EAX
	
	MOV EAX, [buff1]
	MOV EBX, [buff2]

	CMP EAX,EBX
	JL .balik
	SUB EAX,EBX
	MOV [nhaSIl2],EAX
	int2str [nhaSIl2], shaSIl2
	SetTextEditBox [hwndEdit3], shaSIl2	
	SetTextEditBox [hwndEdit4], DefaultValue
	
	.CheckButton2:
	CMP EAX, ButtonID2
	JNZ .CheckButton3

	SHR EAX, 16					;; Shiftleft 16bit to get Event
	CMP EAX, BN_CLICKED			;; If it's Button-Click
	JNZ .window_default
	
	GetTextEditBox [hwndEdit1], buff1, 128, blen1
	GetTextEditBox [hwndEdit2], buff2, 128, blen2
	str2int buff1
	MOV [buff1], EAX
	str2int buff2
	MOV [buff2], EAX
	
	MOV EAX, [buff1]
	MOV ESI, [buff2]
	XOR EDX, EDX
	MUL SI
	
	MOV [nhaSIl1], EAX
	int2str [nhaSIl1], shaSIl1
	SetTextEditBox [hwndEdit3], shaSIl1
	SetTextEditBox [hwndEdit4], DefaultValue
	
	.CheckButton3:
	CMP EAX, ButtonID3
	JNZ .window_default
	
	SHR EAX, 16					;; Shiftleft 16bit to get Event
	CMP EAX, BN_CLICKED			;; If it's Button-Click
	JNZ .window_default
	
	GetTextEditBox [hwndEdit1], buff1, 128, blen1
	GetTextEditBox [hwndEdit2], buff2, 128, blen2
	str2int buff1
	MOV [buff1], EAX
	str2int buff2
	MOV [buff2], EAX
	
	MOV EAX, [buff1]
	MOV ESI, [buff2]
	XOR EDX, EDX
	DIV SI
	
	MOV [nhaSIl2], EAX
	MOV [nhaSIl1], EDX
	int2str [nhaSIl2], shaSIl2
	SetTextEditBox [hwndEdit3], shaSIl2
	
	int2str [nhaSIl1],shaSIl1
	SetTextEditBox [hwndEdit4], shaSIl1
	
	JMP .window_default
	
    .window_destroy: 
        PUSH dword 0 
        CALL [PostQuitMessage] 
        JMP finish

    .window_default: 
        PUSH dword [EBP+20] 
        PUSH dword [EBP+16] 
        PUSH dword [EBP+12] 
        PUSH dword [EBP+08] 
        CALL [DefWindowProcA] 

        LEAVE 	;; WindowProcedure() has 4 arguments, 4 bytes each,         
        RET 16	;; so we free 4 * 4 = 16 bytes from the stack, after returning. 

	.balik:
		SUB EBX,EAX
		MOV [nhaSIl2],EBX
		int2str [nhaSIl2],strcopy
		SetTextEditBox [hwndEdit3], strminus
		RET
	
	mBoxKonfirmaSI:
		PUSH dword 20H			; tombol OK
		PUSH dword TitleExit	; judul message box
		PUSH dword ExitBox     	; Pesan yg ditampilkan, diakhiri dengan 0 (null)
		PUSH dword [hWind]		; owner windows dari msgbox, atau NULL (tdk punya owner)
		CALL [MessageBoxA]
		RET

    finish: 
		XOR EAX, EAX                  ;; XOR EAX, EAX is a way to clear EAX. 
		LEAVE 
		RET 16 	