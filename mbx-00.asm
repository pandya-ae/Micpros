IMPORT MessageBoxA user32.dll
IMPORT ExitProcess kernel32.dll
EXTERN MessageBoxA	
EXTERN ExitProcess	

segment .code use32
..start:	

 push dword 00h			; Button OK
 push dword title1		
 push dword string1     
 push dword 0
 call [MessageBoxA]

 push dword 0
 call [ExitProcess]
 leave
ret

segment .data use32
string1: db 'Display message on MessageBox',13,10,
         db 'Using WindowsAPI [MessageBoxA]',0
title1:  db 'Assembly MsgBox',0
 