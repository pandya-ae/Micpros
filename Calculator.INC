%macro macro_import 2
		import %1 %2
		extern %1
%endmacro

;; Import the Win32 API functions. 
macro_import GetModuleHandleA, kernel32.dll 
macro_import GetCommandLineA, kernel32.dll 
macro_import ExitProcess, kernel32.dll 
macro_import MessageBoxA, user32.dll 
macro_import LoadIconA, user32.dll 
macro_import LoadCursorA, user32.dll 
macro_import RegisterClassExA, user32.dll 
macro_import CreateWindowExA, user32.dll 
macro_import ShowWindow, user32.dll 
macro_import UpdateWindow, user32.dll 
macro_import GetMessageA, user32.dll 
macro_import TranslateMessage, user32.dll 
macro_import DispatchMessageA, user32.dll 
macro_import PostQuitMessage, user32.dll 
macro_import DefWindowProcA, user32.dll 
macro_import SetFocus, user32.dll
macro_import GetWindowTextA, user32.dll
macro_import SetWindowTextA, user32.dll
macro_import SendMessageA, user32.dll
macro_import BeginPaint, user32.dll
macro_import DrawTextA, user32.dll
macro_import EndPaint, user32.dll

%macro GetModuleHandle 0
	push dword 0 
	call [GetModuleHandleA] 
	mov dword [hInstance], eax 
%endmacro

%macro GetCommandLine 0
	call [GetCommandLineA] 
	mov dword [CommandLine], eax 
%endmacro

%macro RegisterClass 0
    							;; We need to fill out the WNDCLASSEX structure, now. 
    lea ebx, [ebp-48]           ;; We load EBX with the address of our WNDCLASSEX structure. 
    mov dword [ebx+00], 48      ;; Offset 00 is the size of the structure. 
    mov dword [ebx+04], 3       ;; Offset 04 is the style for the window. 3 is equal to CS_HREDRAW | CS_VREDRAW 
    mov dword [ebx+08], WindowProcedure        ;; Offset 08 is the address of our window procedure. 
    mov dword [ebx+12], 0       ;; I'm not sure what offset 12 and offset 16 are for. 
    mov dword [ebx+16], 0       ;; But I do know that they're supposed to be NULL, at least for now. 
    
    mov eax, dword [ebp+8]      ;; We load the hInstance value. 
    mov dword [ebx+20], eax     ;; Offset 20 is the hInstance value. 
    
    mov dword [ebx+32], 5 	  	;; Offset 32 is the handle to the background brush. We set that to COLOR_WINDOW
    mov dword [ebx+36], 0       ;; Offset 36 is the menu name, what we set to NULL, because we don't have a menu. 
    mov dword [ebx+40], ClassName ;; Offset 40 is the class name for our window class. 
								 
    push dword 32512 			;; LoadIcon(0, IDI_APPLICATION) where IDI_APPLICATION is equal to 32512.
    push dword 0 
    call [LoadIconA] 
								;; All Win32 API functions preserve the EBP, EBX, ESI, and EDI registers, so it's 
								;; okay if we use EBX to store the address of the WNDCLASSEX structure, for now. 
    
    mov dword [ebx+24], eax     ;; Offset 24 is the handle to the icon for our window. 
    mov dword [ebx+44], eax     ;; Offset 44 is the handle to the small icon for our window. 
								 
    push dword 32512 			;; LoadCursor(0, IDC_ARROW) where IDC_ARROW is equal to 32512.
    push dword 0 
    call [LoadCursorA] 
    
    mov dword [ebx+28], eax     ;; Offset 28 is the handle to the cursor for our window. 
    
								;; Now we register our window class with Windows, so that we can use the class name 
								;; for our window, when we make that. 
								;; Since EBX already has the address of our WNDCLASSEX structure, we can just pussh 
								;; EBX, so we don't have to reload the address of that structure. 
    push ebx 
    call [RegisterClassExA] 

%endmacro

    
%macro CreateWindow 6
								;; CreateWindowEx(WS_EX_CLIENTEDGE, ClassName, window title, WS_OVERLAPPEDWINDOW,
								;;                x, y, width, height, handle to parent window, 
								;;                handle to menu, hInstance, NULL); 
    push dword 0 
    push dword [ebp+8] 
    push dword 0 
    push dword 0 
    push dword %6            	;; heigth 
    push dword %5              	;; width 
    push dword %4        		;; y
    push dword %3				;; x
    push dword 0x00 | 0xC00000 | 0x80000  | 0x20000 | 0x10000 | 0x40000    
                                ;; WS_OVERLAPPEDWINDOW = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_THICKFRAME  
    push dword %2				;; ApplicationName 
    push dword %1				;; ClassName 
    push dword 0000200h 		;; WS_EX_CLIENTEDGE
    call [CreateWindowExA] 
								;; Store the result (which should be a handle to our window) in [ebp-76]. 
    mov dword [ebp-76], eax

	mov dword [hWind], eax		;; Store handle window to hWind
								;; Check if EAX is zero. If so, jump to the error-handling routine. 
    sub eax, 0                  ;; The only difference between SUB and CMP is that CMP doesn't store the result in the first operand. 
                                ;; Here we're subtracting 0 from EAX, which won't change EAX, so it doesn't matter if we use SUB. 
    jz .new_window_failed 
    							;; Now we need to show the window and update the window. 
    push dword [ebp+20] 		;; ShowWindow([ebp-76], [ebp+20])
    push dword [ebp-76] 
    call [ShowWindow] 
								 
    push dword [ebp-76] 		;; UpdateWindow([ebp-76])
    call [UpdateWindow]   
%endmacro

%macro CreateLabel 6
    push dword 0 
    push dword [hInstance] 		;; hInstance value in [ebp+8]
    push dword 0 
    push dword [ebp-76]			;; handle to window in [ebp-76] 
    push dword %6				;; tinggi= 22 
    push dword %5	            ;; lebar = 90
    push dword %4				;; y = 50
    push dword %3			    ;; x = 55
    push dword 0x40000000 | 0x10000000 | 0x0000000B 		
								;; WS_CHILD | WS_VISIBLE | SS_SIMPLE           
	push dword %2				;; LabelText1
    push dword LblClassName		;; LblClassName 
    push dword 00000200h		;; WS_EX_CLIENTEDGE 
    call [CreateWindowExA]
	mov [%1],eax
%endmacro

%macro CreateEditBox 7
    push dword 0 
    push dword [hInstance] 		;; hInstance value in [ebp+8]
    push dword %7				;; EditID 
    push dword [ebp-76]			;; handle to window in [ebp-76] 
    push dword %6				;25			tinggi 
    push dword %5				;250        lebar. 
    push dword %4				;50			y
    push dword %3				;150		x 
    push dword 0x40000000 | 0x10000000 
								;;  WS_CHILD  | WS_VISIBLE 
	push dword %2 
    push dword EditClassName 
    push dword 00000200h		;;WS_EX_CLIENTEDGE 
    call [CreateWindowExA]
	mov [%1],eax
%endmacro

%macro CreateButton 7
    push dword 0 
    push dword [hInstance] 		;; hInstance value in [ebp+8]
    push dword %7 
    push dword [ebp-76]			;; handle to window in [ebp-76] 
    push dword %6				;; tinggi 
    push dword %5               ;; lebar. 
    push dword %4				;; x 
    push dword %3			    ;; y 
    push dword 0x40000000 | 0x10000000 | 0x1    
                                ;; WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON
    push dword %2 
    push dword ButtonClassName 
    push dword 0 
    call [CreateWindowExA]
	mov [%1],eax  
%endmacro

%macro GetMessage 0
        push dword 0 			;; GetMessage(the MSG structure, 0, 0, 0)
        push dword 0 
        push dword 0 
		lea ebx, [ebp-72] 
        push ebx 
        call [GetMessageA] 
%endmacro								 
 
%macro TranslateMsg 0
        lea ebx, [ebp-72] 		;; TranslateMessage(the MSG)
        push ebx 
        call [TranslateMessage] 
%endmacro								 

%macro DispatchMsg 0
        lea ebx, [ebp-72] 		;; DispatchMessage(the MSG)
        push ebx 
        call [DispatchMessageA] 
%endmacro								 

;int GetWindowTextA(
;  HWND  hWnd,
;  LPSTR lpString,
;  int   nMaxCount
;)

%macro GetTextEditBox 4
	push word  %3
	push dword %2 
	push dword %1
	Call [GetWindowTextA]
	mov [%4], eax
%endmacro

;BOOL SetWindowTextA(
;  HWND   hWnd,
;  LPCSTR lpString
;);

%macro SetTextEditBox 2
	push dword %2 
	push dword %1
	Call [SetWindowTextA]
%endmacro

%macro str2int 1
        push    ebx ;
        push    esi ;
        push    edi ;
        mov ebx, 0
        mov ecx, 0
        xor eax,eax
        mov ebx,0000000Ah
        mov esi, %1
        %%ConvertLoop:
        movzx ecx,byte [esi] ;Zeichen laden.
        test ecx,ecx
        jz  short %%ExitConvertLoop ;0 => Exit
        inc esi
        sub cl,30h ;0-9...
        mul ebx ;Ergebnis * 10
        add eax,ecx ;+ nächste Ziffer
        jmp short %%ConvertLoop
        %%ExitConvertLoop:
        pop     edi
        pop     esi
        pop     ebx
%endmacro

%macro int2str 2
        push    ebx ;
        push    esi ;
        push    edi ;
        %%start:
        mov  eax, %1
        xor  ecx, ecx
        mov  ebx, 000Ah
        %%DecConvert:
        xor  edx,  edx
        div  ebx
        add  edx,  0030h
        push edx
        inc  ecx
        or   eax,  eax
        jnz  short %%DecConvert
        mov  edi,  %2
        %%SortDec:
        pop   eax
        stosb
        loop  %%SortDec
        mov eax, 0h
        stosb
        pop     edi
        pop     esi
        pop     ebx
%endmacro

;LRESULT SendMessageA(
;  HWND   hWnd,
;  UINT   Msg,
;  WPARAM wParam,
;  LPARAM lParam
;);