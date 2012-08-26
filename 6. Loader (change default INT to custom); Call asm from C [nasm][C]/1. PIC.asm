;	Nams file
	org 7c00h
;
;	Read 0/0/2 - 0/0/4 sectors from disc A
;
	mov ax, 0203h
	mov cx, 2
	xor dx, dx
	mov bx, idt
	int 13h
	; Can't read
	jc bad
	
	jmp protected_mode
	
bad:	
	mov bp, msg_err

	mov cx, [bp]
	add bp, 2

	mov ax, 1301h
	mov bx, 0004h
	xor dx, dx
	int 10h

	cli
	hlt

protected_mode:
cli	
;	Load pm regs
	lgdt [gdtr]
	lidt [idtr]
	mov bx,	1
	lmsw bx
;	Annul regs
	jmp short $+2
	xor ax, ax
	mov ds, ax
	mov es, ax
;	mov ax, 600h
	mov ss, ax
;	PIC
	mov al, 00010011b
    out 20h, al
    mov al, 00001000b
    out 21h, al
    mov al, 00000011b
    out 21h, al
    mov al, 11111101b
    out 21h, al
sti

wait_count:
	mov ax, cnt
	cmp ax, 180
	jle wait_count

;	INT 0
	mov bx,0
	div bx
	
	cli
	hlt
	
gdtr	dw gdt_size
		dd gdt
idtr	dw 800h
		dd idt
	
ints:
	mov si, text
	call print
	iret
;
; print word's line si
;
print:
	mov cx, [si]
	; ds:si
	add si, 2
	xor ax, ax
	mov ds, ax
	; es:di
	mov ax, 4
	mov di, ax
	mov ax, 10h
	mov es, ax
	
	rep movsb
	
	ret
;
;	Timer
;
int_8:
	mov ax, cnt
	cmp ax, 180
	jge int_8_exit
	
;	inc cnt
	mov si, cnt
	inc ax
	mov [si], ax
;
	and al, 11111b
	cmp al, 18
	jne int_8_exit
		; es:di
		xor ax, ax
		mov di, ax
		mov ax, 10h
		mov es, ax
	
		mov ax, 032fh
		add ax, cnt
		
		stosw
	
int_8_exit:
	iret
	
cnt		dw 0
text	dw 5
		dw 0149h, 024eh, 0454h, 010dh, 010ah ; 'INT'
msg_err	dw 24
		db 'Can not read 2nd sector.'

gdt:
;	null descriptor
times	4	dw 0
;	code
	dw 16
	db 0,0,0
	db 10011010b
	db 10000000b
	db 0
;	for video
	db 0,0,0
	dw 0B80h
	db 10010010b
	dw 0
gdt_size	db $-gdt

times	510 - ($ - $$) db 0
		dw 55aah

idt:
;	for all ints
	times	8 dw ints, 8, 1000011000000000b, 0
	dw int_8, 8, 1000011000000000b, 0
	times	247 dw ints, 8, 1000011000000000b, 0

