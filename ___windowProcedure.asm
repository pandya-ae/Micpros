; Main window procedure
windowProcedure:
	push ebp
	mov  ebp,esp
	
	; Window procedure is stdcall convetion, so,
	; the parameters are located at these kind of offsets.
	; 4 Parameters
	%define ebp_hwnd 	ebp+8
	%define ebp_message ebp+12
	%define ebp_wparam 	ebp+16
	%define ebp_lparam 	ebp+20
	
	; Switch\jump table
	cmp [ebp_message],dword WM_CLOSE
	je .onClose
	cmp [ebp_message],dword WM_DESTROY
	je .onDestroy
	cmp [ebp_message],dword WM_CREATE
	je .onCreate
	
.defaultProcedure:
	push dword [ebp_lparam]
	push dword [ebp_wparam]
	push dword [ebp_message]
	push dword [ebp_hwnd]
	call [DefWindowProcA]
	mov esp,ebp
	pop ebp
	ret 16 ; stdcall convetion requires pop all parameters from stack 4*4 = 16 bytes
	
.onCreate:
	push dword SW_SHOW
	push dword [ebp_hwnd]
	call [ShowWindow]
	
	push dword [ebp_hwnd]
	call [UpdateWindow]
	
	mov eax,0
	mov esp,ebp
	pop ebp
	ret 16 ; stdcall convetion requres pop all parameters from stack 4*4 = 16 bytes
	
.onClose:
	push dword [ebp_hwnd]
	call [DestroyWindow]
	mov eax,0
	mov esp,ebp
	pop ebp
	ret 16 ; stdcall convetion requres pop all parameters from stack 4*4 = 16 bytes
	
.onDestroy:
	push dword 0
	call [PostQuitMessage]
	mov eax,0
	mov esp,ebp
	pop ebp
	ret 16 ; stdcall convetion requres pop all parameters from stack 4*4 = 16 bytes