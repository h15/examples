;	Nams file
;	Tested under VirtualBox
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
	lgdt [gdtr]
	lidt [idtr]

	mov eax, cr0
	or al, 1
	mov cr0, eax

	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	
	jmp 8:$+3
sti
;	INT 0
	mov bx,0
	div bx
;	int 0ffh
	
	cli
	hlt
	
gdtr	dw gdt_size
	dd gdt
idtr	dw 800h
	dd idt
	
ints:
	mov si, text
	call print	
	cli
	hlt
	iret
;
;	print word's line si
;
print:
	mov cx, [si]
	; ds:si
	add si, 2
	xor ax, ax
	mov ds, ax
	; es:di
	mov di, ax
	mov ax, 10h
	mov es, ax
	
	rep movsb
	
	ret

text	dw	5
	dw 0149h, 024eh, 0454h, 010dh, 010ah ; 'INT'
msg_err	dw 24
	db 'Can not read 2nd sector.'

gdt:
;	null descriptor
times	4	dw 0
;	64kb segment
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
;
gdt_size	db $-gdt

times	510 - ($ - $$) db 0
	dw 55aah

idt:
;	for all ints
	times	256 dw ints, 8, 1000011000000000b, 0

