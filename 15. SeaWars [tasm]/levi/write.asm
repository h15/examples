
wrClean	proc
	push	ax
	push	bx
	push	bp

	mov	ah,13h
	mov	al,01h
	xor	bh,bh
	lea	bp,clean
	int	10h 

	pop	bp
	pop	bx
	pop	ax

ret
wrClean	endp


wrErrMsg	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	
	mov	ah,13h
	mov	al,01h
	xor	bh,bh
	mov	bl,00111100b
	mov	cx,13
	xor	dl,dl
	mov	dh,1
	mov	bp,offset errmsg
	int	10h	

	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
errmsg	db 'Not correct!'
wrErrMsg	endp

wrWin	proc
	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	
	mov	ah,13h
	mov	al,01h
	xor	bh,bh
	mov	bl,00111111b
	mov	cx,26
	xor	dx,dx
	lea	bp,mWin
	int	10h	

	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax

ret
wrWin	endp

wrWon	proc
	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	
	mov	ah,13h
	mov	al,01h
	xor	bh,bh
	mov	bl,00111111b
	mov	cx,26
	xor	dx,dx
	lea	bp,mWon
	int	10h	

	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax

ret
wrWon	endp


wrNic	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	
	push	cs
	pop	es
	mov	ah,13h
	mov	al,01h
	xor	bh,bh
	mov	bl,00011100b
	mov	cx,10
	mov	dx,200h
	lea	bp,myName
	int	10h

	mov	dl,37
	lea	bp,opName	
	int	10h

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
wrNic	endp

vvodNic	proc
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	
	mov	ah,13h
	mov	al,01h
	mov	bh,0
	mov	bl,00001100b
	mov	cx,29
	xor	dx,dx
	cmp	master,1
	je	wwww
	push	cs
	pop	es
wwww:
	lea	bp,msgNic
	int	10h
	xor	si,si
writeNic:
	xor	ah,ah
	int	16h
	cmp	ah,1ch	
	je	cancle
	push	ax
	mov	ah,09h
	mov	cx,1
	int	10h
	pop	ax
	mov	myName[si],al
	inc	si
	cmp	si,11
	je	cancle
	mov	ah,03h
	int	10h
	inc	dl
	mov	ah,02h
	int	10h
	jmp	writeNic
cancle:
	xor	dx,dx
	mov	cx,60
	mov	ah,13h
	mov	al,01h
	lea	bp,clean
_ccl2:
	int	10h
	inc	dh
	cmp	dh,6
	jne	_ccl2
	
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
vvodNic	endp

wrInf	proc	

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	
	mov	al,ship4
	add	al,'0'
	mov	hh+4,al
	mov	al,ship3
	add	al,'0'
	mov	hh+11,al
	mov	al,ship2
	add	al,'0'
	mov	hh+18,al
	mov	al,ship1
	cmp	al,0ah
	jne	_noah
	mov	al,'a'
	mov	hh+25,al
	jmp	_z
_noah:
	add	al,'0'
	mov	hh+25,al
_z:
;	mov	cx,27
;	xor	dx,dx
;	xor	bh,bh
;	mov	bl,4
;	mov	al,01h
;	mov	ah,13h
;	lea	bp,hh
;	int	10h
	xor	ax,ax
	mov	ah,09h
	mov	dx,offset hh
	int	21h
	
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
hh	db	'4x:=   3x:=   2x:=   1x:=  ',0dh,0ah,24h
wrInf	endp

wrWait	proc
	
	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	
	mov	ah,13h
	mov	al,01h
	mov	bh,bh
	mov	bl,00111111b
	mov	cx,50
	xor	dx,dx
	lea	bp,wtm
	int	10h
	
	
	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
wtm	db	'Waait wait...                                         '
wrWait	endp

wrHod	proc
	
	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	push	ss
	push	ds
	push	si
	push	di

	mov	ah,13h
	mov	al,01h
	xor	bh,bh
	mov	bl,00111111b
	mov	cx,50
	xor	dx,dx

	lea	bp,gggggg
	int	10h
	
	pop	di
	pop	si
	pop	ds
	pop	ss
	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax

ret
gggggg	db	'Your hod  ) Cmn)                                          '

wrHod	endp

