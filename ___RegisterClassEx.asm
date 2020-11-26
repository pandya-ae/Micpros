; Fill main WNDCLASSEX structure ----------------------------------------------------------------
; -----------------------------------------------------------------------------------------------
	
	; 1. WNDCLASSEX.cbSize
	mov [mainWindowClassEx + 0], dword 12*4	

	; 2. WNDCLASSEX.style
	mov [mainWindowClassEx + 4], dword CS_VREDRAW + CS_HREDRAW

	; 3. WNDCLASSEX.lpfnWndProc
	mov [mainWindowClassEx + 8], dword windowProcedure

	; 4. WNDCLASSEX.cbClsExtra
	mov [mainWindowClassEx + 12], dword 0

	; 5. WNDCLASSEX.cbWndExtra
	mov [mainWindowClassEx + 16], dword 0

	; 6. WNDCLASSEX.hInstance
	mov eax,dword [hInstance]
	mov [mainWindowClassEx + 20],eax

	; 7. WNDCLASSEX.hIcon
	push dword IDI_APPLICATION
	push dword 0 ; This parameter must be NULL when a standard icon is being loaded.
	call [LoadIconA]
	mov [mainWindowClassEx + 24],eax

	; 8. WNDCLASSEX.hCursor
	push dword IDC_ARROW
	push dword 0 ; This parameter must be NULL when a standard cursor is being loaded.
	call [LoadCursorA]
	mov [mainWindowClassEx + 28],eax

	; 9. WNDCLASSEX.hbrBackground
	mov [mainWindowClassEx + 32],dword COLOR_WINDOW

	; 10. WNDCLASSEX.lpszMenuName
	mov [mainWindowClassEx + 36],dword 0

	; 11. WNDCLASSEX.lpszClassName
	mov [mainWindowClassEx + 40],dword mainWindowClassName

	; 12. WNDCLASSEX.hIconSm
	push dword IDC_ARROW
	push dword  [hInstance]
	call [LoadCursorA]
	mov [mainWindowClassEx + 44],eax
	
	; Try Register

	push dword mainWindowClassEx
	call [RegisterClassExA]
	cmp eax,0
	je registerClassError