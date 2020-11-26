IMPORT MessageBoxA user32.dll
IMPORT ExitProcess kernel32.dll
EXTERN MessageBoxA	
EXTERN ExitProcess	

segment .code use32
..start:	

 push dword 24h			; Button Yes/No | Icon Question
 push dword title1		
 push dword string1     
 push dword 0
 call [MessageBoxA]
 
 CMP EAX, 6
 JE  ..start

 push dword 0
 call [ExitProcess]
 leave
ret

segment .data use32
string1: db 'Display Again',0
         
title1:  db 'Assembly MsgBox',0
 