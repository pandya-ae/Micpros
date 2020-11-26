[BITS 32]

	;Define import macro, to import function from external DLL files
	%macro macro_import_function 2
		import %2 %1
		extern %2
	%endmacro

	;Define import functions
	macro_import_function user32.dll,		LoadIconA
	macro_import_function user32.dll,		LoadCursorA
	macro_import_function user32.dll,		RegisterClassExA
	macro_import_function user32.dll,		MessageBoxA
	macro_import_function user32.dll,		CreateWindowExA
	macro_import_function user32.dll,		GetMessageA
	macro_import_function user32.dll, 		TranslateMessage
	macro_import_function user32.dll, 		DispatchMessageA
	macro_import_function user32.dll, 		DefWindowProcA
	macro_import_function user32.dll, 		ShowWindow
	macro_import_function user32.dll, 		UpdateWindow
	macro_import_function user32.dll, 		SendMessageA
	macro_import_function user32.dll, 		PostQuitMessage
	macro_import_function user32.dll, 		DestroyWindow

	macro_import_function kernel32.dll,		ExitProcess
	macro_import_function kernel32.dll,		GetModuleHandleA
	macro_import_function kernel32.dll,		GetCommandLineA

	; Define come constants
	CS_VREDRAW  	equ 		0x0001
	CS_HREDRAW  	equ 		0x0002
	IDI_APPLICATION equ 		32512
	COLOR_WINDOW 	equ 		5
	IDC_ARROW 		equ 		32512

	MB_OK  			equ 		0x00000000
	MB_ICONEXCLAMATION equ 		0x00000030

	WS_SYSMENU  	equ 		0x00080000

	SW_SHOW  		equ 		5

	WM_CREATE 		equ 		0x1
	WM_DESTROY 		equ 		0x2
	WM_CLOSE  		equ 		0x0010


[SEGMENT .DATA USE32]
	
	mainWindowClassName 	db "mainWindowClass",0
	mainWindowName 			db "BASIC-WINDOWS",0
	
	error_title 			db "~Error:",0
	error_registerClassEx	db "Register class error",0
	error_createWindowEx 	db "Create window error",0
	
[SEGMENT .BSS USE32]
	
	hInstance 				resb 4
	commandLine 			resb 4
	
	mainWindowClassEx 		resb 12*4
	mainMessageStruct 		resb 7*4
	
	windowHandle 			resb 4


[SEGMENT .TEXT USE32]
	
..start:
	
	; Get instance, once and for all
	push dword 0
	call [GetModuleHandleA]
	mov [hInstance],eax
	
	; Get command line argument
	call [GetCommandLineA]
	mov [commandLine],eax
	
	; Include external file
	; Create window class and register
	%include "___RegisterClassEx.asm"

	; Include external file
	; Create window
	%include "___CreateWindowEx.asm"
	
	; Include external file
	; Do message loop
	%include "___MessageLoop.asm"
	
	jmp quitProgram
	
	; Error handler for RegisterClassEx failure
registerClassError:
	push dword MB_OK + MB_ICONEXCLAMATION
	push dword error_title
	push dword error_registerClassEx
	push dword 0
	call [MessageBoxA]
	jmp quitProgram
	
	; Error handler for CreateWindowEx failure
createWindowError:
	push dword MB_OK + MB_ICONEXCLAMATION
	push dword error_title
	push dword error_createWindowEx
	push dword 0
	call [MessageBoxA]
	
	; Quit program label
quitProgram:
	push dword 0
	call [ExitProcess]
	ret
	
; Include external file
; Window procedure goes here
%include "___windowProcedure.asm"
	

	
