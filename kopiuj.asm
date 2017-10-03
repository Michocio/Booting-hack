; SO zad3 - mj348711
; kod kopiujacy orginalny bootloader tam gdzie jego miejsce :)
org        0x500				; gdzie będzie wykonywany
bits       16

start:

	; czytania orginalnego boot loadera z dysku
	mov ax, 0
	mov es, ax 
	mov ah, 0x02				; czytanie
	mov cl, 0x03				; numer sektora, numerujac od 1 1024
	mov al, 0x01				; liczba sektorow do czytania
	mov ch, 0					; cylinder
	mov dh, 0					; glowica
	mov dl, 0x80				; dysk
		
	mov bx, 0x7c00
	int 13h
	
	wykonaj: 
		jmp 0:zeros      	; wyzerowanie rejestru cs

		zeros:
			mov ax, cs      ; wyzerowanie pozostałych rejestrów segmentowych
			mov ds, ax
			mov es, ax
			mov ss, ax

		; skok do kopiowanie orignalnego, oddanie władzy	
		mov si, 0x7c00	
		jmp si

