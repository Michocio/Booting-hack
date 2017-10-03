; SO zad3 - mj348711
; w pierwszym sektorze na dysku zapisujemy nasz kod bios
; w drugim zapisujemy kod kopiujący
; w trzecim orginalny bootloeader
; w piątym zapisz imie
; 1 - custom boot 2 - copy_code 3 - orginal boot 5 - name
org        0x7c00           ; BIOS ładuje ten kod pod ten adres
bits       16               ; 16 bits real mode


start:
    mov     si, msg         ; si pokazauje na wiadomosc powitalna
	call wypisz_string		; wypisz wiadomość powitalną
	
read_name:

    xor cx, cx              ; licznik wpisanych znakow

    get_key:
        mov ah, 0x00        ; serwis czytania
        int 0x16            ; czytaj znak z wejscia

print:                      ; analizuje i wypisuje wejście
    sub al, 0x8             ; czy backspace
    or al, al
    jz backspace            ; tak
    add al, 0x8

    sub al, 0x0d            ; czy enter
    or al, al
    jz enter                ; tak
    add al, 0x0d

    ; sprawdz czy nie wiecej niz 12 znakow
    cmp cx, 12
    je get_key

    xor bx, bx              ; zeruj
    mov bx, name            ; w bx adres zmiennej name
    add bx, cx              ; dodaj przesuniecie w stringu
    mov [bx], al            ; zapisz w rejestrze wczytany znak
    mov ah, 0x0e            ; wypisz wczytany znak
    int 0x10

    add cx, 0x1             ; inkrementuj liczbe wczytanych znakow
    jmp get_key             ; kontynuuj wczytywanie


backspace:                  ; obsluz znak backspace
    or cx, cx
    jz get_key              ; jeżeli zero znakow to nie rob nic, wróc do czytania

		; skasuj znak
        mov ah, 0x0e
        call wypisz_backspace

        mov al,32           ; spacja
        int 0x10            ; spacja

        call wypisz_backspace

        sub cx, 0x1         ; odejmij liczbe znakow
        jmp get_key			; kontynuuj pętle

; obsługa kliknięcia enter
enter:
    cmp cx, 3               ; czy conajmniej 3 znaki
    jb get_key              ; nie, wiec nie wychodzimy

	; conajmniej 3 znaki, więc kończymy
    xor bx, bx
    mov bx, name			; skopiuj do bx adres zmiennej name
    add bx, cx				; idź na koniec pliku
    mov dword [bx], 0x0		; dodaj zero na końcu imienia

	; zapisywanie imienia na dysku
    mov ah, 0x03			; pisanie
    mov cl, 0x05			; numer sektora, numerujac od 1
    mov al, 0x01			; liczba sektorow do pisania
    mov ch, 0				; cylinder
    mov dh, 0				; glowica
    mov dl, 0x80			; dysk
    mov bx, name			; skopiuj całą zmienną
    int 13h

    call enter_karetka

    mov si, hejo				; wypisz hello
    call wypisz_string			; wypisz hello
    

    mov si, name				; doklej imie do hello powyzej
    call wypisz_string			; doklej imie do hello powyzej
    
    call enter_karetka



    ; Wczytaj kod kopiujacy pod adres 0x200
    mov ah, 0x02            ; czytanie
    mov cl, 0x02            ; numer sektora, numerujac od 1
    mov al, 0x01            ; liczba sektorow do czytania
    mov ch, 0               ; cylinder
    mov dh, 0               ; glowica
    mov dl, 0x80            ; dysk
    mov bx, 0x500            ; czytaj do zmiennej kod
    int 13h

    wykonaj:

		; 5000000 czas := DX + (65536*CX).
		mov cx, 30
		mov dx, 33920
		mov     ah, 0x86               ; wait
		int     0x15                   ; wait

		jmp 0:zeros      ; wyzerowanie rejestru cs
		zeros:
			mov ax, cs      ; wyzerowanie pozostałych rejestrów segmentowych
			mov ds, ax
			mov es, ax
			mov ss, ax
			;mov sp, 0x8000  ; inicjacja stosu

		; skok do kopiowanie orignalnego
		mov si, 0x500
		jmp si

done:
    ret


; sekcja funkcji
enter_karetka:
	mov     ah, 0x0e        ; "serwis" wypisujacy, na wszelki wypadek
    mov al, 10              ; /n
    int 0x10                ; wypisz
    mov al, 13              ; /r
    int 0x10                ; wypisz
    ret						; wróć do miejsca wywołania

wypisz_backspace:
	mov ah, 0x0e
	mov al, 8           ; wypisz backaspace
	int 0x10
	ret

wypisz_string:
; w si powinien znajdować się string do wypisywania
	mov     ah, 0x0e        ; "serwis" wypisujacy
	petla:                  ; wypisz wiadomosc powitalna
		lodsb
		or      al, al          ; koniec napisu
		jz      koniec_string
		int     0x10            ; wypisz znak
		jmp     petla       	; kolejny znak
	koniec_string:
		ret

; sekcja zmiennych
hejo:   db        "Hello ", 0
msg:    db        "Enter your name: ", 0
kod times 100 db '0'
name: times 20 db '0'
