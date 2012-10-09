	.model tiny
	.code
	org 100h
_1:
jmp Main
    
    include ../lib/serial.asm

;ОТПРАВКА СООБЩЕНИЯ
Main:
    call serial_install
    
	mov	dx,offset Print
	mov	ah,09
	int 21h
Input:
Input_:

	mov	ah,1
	int 16h
	jz Input
	xor	ax,ax
	int 16h
	cmp	ah,1
    
	jne ok
        call serial_uninstall
        ret
    ok:
    
	cmp	ah,1ch
	jne	skip_send
        call serial_send
    skip_send:
    
	cmp	al,20h
	jb	Input
;сохpаняем символ	
	mov	ah,02h
	mov	dl,al
	int 21h
	
	inc	serial_bufCount
	
	mov	bx,[serial_bufPtr]
	mov	[bx],al
	inc	bx
	cmp	bx,offset serial_buf + serial_bufSize
	jb	Save_ok
	mov	bx,offset serial_buf
Save_ok:
	mov	serial_bufPtr,bx
	
	jmp	Input	

;Пpишло сообщение!!                   
;Incoming:  
;   call serial_get
;   jmp	Input

Print	db	0dh,0ah,'COM2>',24h

end _1
