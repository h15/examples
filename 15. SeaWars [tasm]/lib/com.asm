proc com_init
	mov	ax,40h
	push es
	mov	es,ax
	mov	dx,es:[bx]
	mov	com_base,dx
	add	dx,3
	mov	al,128
	out	dx,al
	sub	dx,2
	mov	al,0
	out	dx,al
	dec	dx
	mov	al,0Ch
	out	dx,al
	mov	al,0
	or	al,01111B
	add	dx,3
	out	dx,al
	sub	dx,2
	mov	al,0
	out	dx,al
	pop es
	ret
endp com_init

proc com_get
	mov	dx,com_base
	in	al,dx
	ret
endp com_get

proc com_send
	mov	dx,com_base
	out dx,al
	ret
endp com_send
	
proc com_send
	mov	dx,com_base
	add	dx,5
	in	al,dx
	ret
endp com_send

com_base	dw	0