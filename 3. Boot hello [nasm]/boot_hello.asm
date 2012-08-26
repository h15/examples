;	Nams file
	org 7c00h
;
;	Read 0/0/2 sector from disc A
;
	mov ax, 0201h
	mov cx, 2
	mov dx, 0
	mov es, dx
	mov bx, buffer
	int 13h
;	Can't read
	jc bad
;
	mov bp, buffer
	jmp short print
bad:
	mov bp, msg_err
print:
	mov cx, [bp]
	add bp, 2
	
	mov ax, 1301h
	mov bx, 0004h
	xor dx, dx
	int 10h

	cli
	hlt

msg_err	dw 24				;	length
	db 'Can not read 2nd sector.'	;	text

times	510 - ($ - $$) db 0
	db 55h, 0aah

buffer	dw 22
	db 'Hello from 2nd sector!'
times	1024 - ($ - $$) db 0

