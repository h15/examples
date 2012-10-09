drawField proc near
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	
	mov	cl,sizeField
	mov	ax,24
	mul	cl
	add	ax,4
	mov	rvv,ax
	mov	rightBord1f,ax
	
	mov	cl,sizeField
	mov	ax,2*0Eh
	mul	cl
	add	ax,49
	mov	bottomBord,ax
	
	mov	ah,0Ch
	mov	al,00011110b
	xor	bh,bh
	call	_dSquare
	
	mov	ax,rvv
	add	ax,296
	mov	rvv,ax
	mov	rightBord2f,ax
	
	mov	ah,0Ch
	mov	al,00010110b
	mov	rv,299
	call	_dSquare
	
	mov	ah,13h
	mov	al,01h
	mov	bl,00111111b
	mov	cx,10
	mov	dl,70
	mov	dh,3

	lea	bp,msgGB
	int	10h
	mov	dh,5
	lea	bp,msgFin
	int	10h
	mov	dh,7
	lea	bp,msgRS
	int	10h
	mov	dh,9
	lea	bp,msg4v
	int	10h
	mov	dh,11
	lea	bp,msg4h
	int	10h
	mov	dh,13
	lea	bp,msg3v
	int	10h
	mov	dh,15
	lea	bp,msg3h
	int	10h
	mov	dh,17
	lea	bp,msg2v
	int	10h
	mov	dh,19
	lea	bp,msg2h
	int	10h
	mov	dh,21
	lea	bp,msg11
	int	10h
	mov	dh,23
	lea	bp,msgRD
	int	10h

	xor	dx,dx
	mov	ah,02h
	int	10h
	
	
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
ret

_dSquare:	
	mov	dx,topBord
_cci2:
	mov	cx,rv
_cci:
	int	10h
	inc	dx
	int	10h

	dec	dx
	inc	cx
	cmp	cx,rvv
	jne	_cci
	add	dx,2*0Eh
	cmp	dx,bottomBord
	jl	_cci2
	
	mov	cx,rv
_ddi2:
	mov	dx,topBord
_ddi:
	int	10h
	inc	cx
	int	10h
	
	dec	cx
	inc	dx
	cmp	dx,bottomBord
	jne	_ddi
	add	cx,18h
	cmp	cx,rvv
	jl	_ddi2
ret
rvv	dw	0
llv	dw	0
rv	dw	3
drawField ENDP


drawKillMy proc
;рисуем попадания противника в мои корабли
	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	
	xor	cx,cx
	mov	cl,y
	mov	ax,2
	mul	cl
	dec	ax
	mov	dh,al
	add	dh,3
	mov	koordy,dh
	
	mov	cl,x
	mov	ax,3
	mul	cl
	sub	ax,2
	mov	dl,al
one:
	mov	dh,koordy
	mov	cx,2
	mov	ax,1300h
	mov bp, offset kill
	int	10h
	
	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret

kill		db	2 dup (219)
koordx	db	0
koordy	db	0
drawKillMy endp

drawKillOpponent proc
;рисуем свои попадпния в корабли противника

	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	
	mov	cl,y
	mov	ax,2
	mul	cl
	dec	ax
	mov	dh,al
	add	dh,3
	mov	koordOpy,dh
	mov	cl,x
	mov	ax,3
	mul	cl
	sub	ax,2
	mov	dl,al
	add	dl,37
oneOp:
	mov	dh,koordOpy
	xor	bh,bh
	mov	bl,00111011b	
	mov	cx,1
	mov	ah,02h
	int	10h
	mov	cx,2
	mov	ax,1300h
	lea	bp,kill
	int	10h
	
	mov	dh,24
	mov	dl,80
	mov	ah,02h
	int	10h

	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
koordOpx	db	0
koordOpy	db	0
drawKillOpponent endp


drawMissOpponent proc
;рисуем промахи которые допустил сам

	push	ax
	push	bx
	push	cx
	push	dx
	push	bp	

	mov	cl,y
	mov	ax,2
	mul	cl
	dec	al
	mov	dh,al
	add	dh,3
	mov	koordMissy,dh
	mov	cl,x
	mov	ax,3
	mul	cl
	sub	ax,2
	mov	dl,al
	add	dl,38

	mov	dh,koordMissy
	xor	bh,bh
	mov	bl,00111010b	
	mov	cx,1
	mov	ah,02h
	int	10h
	
	mov	ax,1300h
	lea	bp,miss
	int	10h
	
	mov	dh,24
	mov	dl,80
	mov	ah,02h
	int	10h

	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
koordMissy	db	0
drawMissOpponent endp

drawMissMy proc
;рисуем промахи которые допустил противник

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	xor	cx , cx
	mov	cl , y
	xor	ax , ax
	mov	ax , 2
	mul	cx
	dec	ax
	mov	dh , al
	add	dh , 3
	mov	koordMissMy , dh
	xor	cx , cx
	mov	cl , x
	xor	ax , ax
	mov	ax , 3
	mul	cx
	sub	ax , 2
	mov	dl , al
	
	mov	dh , koordMissMy
	mov	bh , 0
	mov	bl , 00111010b	
	mov	cx , 1
	mov	ah , 02h
	int	10h
	mov	cx , 1
	mov	ax , 1300h
	lea	bp , miss1
	int	10h
	

	mov	dh , 24
	mov	dl , 80
	mov	ah , 02h
	int	10h

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
koordMissMy	db	0
drawMissMy endp