; Definisi Fungsi Di-import Dari file DLL
extern ExitProcess 
extern GetStdHandle 
extern WriteFile 
extern AllocConsole 
extern FreeConsole 
extern SetConsoleTitleA 
extern Sleep 

import ExitProcess kernel32.dll 
import GetStdHandle kernel32.dll 
import WriteFile kernel32.dll 
import ReadFile kernel32.dll 
import AllocConsole kernel32.dll 
import FreeConsole kernel32.dll 
import SetConsoleTitleA kernel32.dll 
import Sleep kernel32.dll 

section .DATA 		

Judul       db "MENAMPILKAN PESAN PADA CONSOLE", 0 
Pesan1      db 13,10,"PROGRAM ASSEMBLY NASM ", 13,10,0 
Panjang1	dd $-Pesan1 
Pesan2		db 13,10,"Tunggu 10 detik ..........", 13,10,0 
Panjang2    dd $-Pesan2 

hStdOut     resd 1 
nBytes      resd 1

section .CODE use32 
..start: 

	call [AllocConsole] 

	push dword Judul 
	call [SetConsoleTitleA] 

	push dword -11 				;; STD_OUTPUT_HANDLE = -11.
	call [GetStdHandle] 
	mov dword [hStdOut], eax 
								;; menampilkan Teks ke Console(Monitor) dg WriteFile
	push dword 0 				;; parameter ke 5 dari WriteFile() adalah 0 
	push dword nBytes			;; parameter ke 4 jumlah byte yg sesungguhnya tertulis
	push dword [Panjang1] 		;; parameter ke 3 panjang string
	push dword Pesan1			;; parameter ke 2 string yang akan ditampilkan "Tulis Kalimat : "
	push dword [hStdOut] 		;; parameter ke 1 handle stdout
	call [WriteFile] 				

	push dword 0 
	push dword nBytes 
	push dword [Panjang2] 
	push dword Pesan2 			;;parameter ke 2 string "Tunggu 10 detik ...................."
	push dword [hStdOut] 
	call [WriteFile] 

	push dword 10000 			;; delay 10 second 
	call [Sleep] 

	call [FreeConsole] 

	push 0 
	call [ExitProcess] 

