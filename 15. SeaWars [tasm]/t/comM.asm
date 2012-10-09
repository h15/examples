	.model tiny
	.code
	org 100h
_1:
jmp Main
    
    include ../lib/serial.asm
	
;ОТПРАВКА СООБЩЕНИЯ
Main:
    call serial_install
    
	mov	dx, offset Print
	mov	ah, 09
	int 21h
Input:
Input_:
	mov	ah, 1
	int 16h
	jz  Input
	xor	ax, ax
	int 16h
	cmp	ah, 1
    jne ok
        call print_buf
        call serial_uninstall
        ret
    ok:
	cmp	ah, 1ch
	jne	skip_send
        call serial_send
    skip_send:
    
	cmp	al, 20h
	jb	Input
;сохpаняем символ	
	mov	ah, 02h
	mov	dl, al
	int 21h
	
    call serial_alToBuf
	
	jmp	Input

print_buf proc
    lea si, serial_recvBuf
    mov cx, serial_recvCount
    mov ah, 02h
    print_buf_while:
        mov dl, [si]
        int 21h
        inc si
    loop print_buf_while
    
    ret
print_buf endp

;Пpишло сообщение!!                   
;Incoming:  
;   call serial_get
;   jmp	Input

Print	db	0dh,0ah,'COM2>',24h

end _1
