mainMessageLoop:
	
	push dword 0
	push dword 0
	push dword 0
	push dword mainMessageStruct
	call [GetMessageA]
	cmp eax,0
	jle quitProgram

	;push dword mainMessageStruct
	;call [TranslateMessage]
	
	push dword mainMessageStruct
	call [DispatchMessageA]
	
	jmp mainMessageLoop