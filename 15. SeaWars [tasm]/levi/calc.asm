calcPlaceShip proc
;вычисляются координаты при расстановке кораблей т е первое поле
	push	ax
	push	bx

	mov	ax,x1
	mov	bl,24
	div	bl
	inc	al
	mov	x,al
	mov	ax,y1
	mov	bl,14
	div	bl
	xor	ah,ah
	sub	al,3
	shr	al,1
	inc	al
	mov	y,al

	pop	bx
	pop	ax
ret
calcPlaceShip endp

calcAttackShip 	proc
;вычисляются координаты нашей аттаки т е куда <ы нажали т е второе поле
	push	ax
	push	bx

	mov	ax,x1
	shr	ax,3
	sub	ax,37
	mov	bl,3
	div	bl
	inc	ax
	mov	x,al
	mov	ax,y1
	mov	bl,14
	div	bl
	sub	ax,3
;	mov	bl,2
;	div	bl
	shr	al, 1
	inc	ax
	mov	y,al

	pop	bx
	pop	ax
ret
calcAttackShip	endp


calcCorrectVert4	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	xor	cx , cx
	mov	cl , x
	mov	si , cx
	mov	cl , y
	mov	bp , cx
	mov	cl , sizeField
	sub	cx , bp
	cmp	cx , 3
	jl	okVert4
	xor	cx , cx
	mov	cl , y
	xor	dx , dx
	mov	ax , 12
	mul	cx
	mov	bp , ax
	dec	si
	sub	bp , 12
	xor	ax , ax
	xor	cx , cx
	mov	cx , 6
incsi4:
	cmp	field[bp][si] , 0
	jne	okVert4
	inc	si
	inc	ax
	cmp	ax , 3
	jl	incsi4	

	xor	ax , ax
	add	bp , 12
	sub	si , 3
	loop	incsi4 

	inc	si
	sub	bp , 24
	mov	ok , 1
	mov	field[bp][si] , 1
	sub	bp , 12
	mov	field[bp][si] , 1
	sub	bp , 12
	mov	field[bp][si] , 1
	sub	bp , 12
	mov	field[bp][si] , 1

okVert4:

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret 

calcCorrectVert4	endp

calcCorrectHor4	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	xor	cx , cx
	mov	cl , x
	mov	si , cx
	mov	cl , y
	xor	dx , dx
	mov	ax , 12
	mul	cx
	mov	bp , ax
	mov	cl , sizeField
	sub	cx , si
	cmp	cx , 3
	jl	okHor4
	dec	si
	sub	bp , 12
	xor	ax , ax
	mov	cx , 3
incsih4:
	cmp	field[bp][si] , 0
	jne	okHor4
	inc	si
	inc	ax
	cmp	ax , 6
	jl	incsih4	

	xor	ax , ax
	add	bp , 12
	sub	si , 6
	loop	incsih4

	inc	si
	sub	bp , 24
	mov	ok , 1
	mov	field[bp][si] , 1
	inc	si
	mov	field[bp][si] , 1
	inc	si
	mov	field[bp][si] , 1
	inc	si
	mov	field[bp][si] , 1

okHor4:

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret

calcCorrectHor4	endp

calcCorrectHor3	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	xor	cx , cx
	mov	cl , x
	mov	si , cx
	mov	cl , y
	xor	dx , dx
	mov	ax , 12
	mul	cx
	mov	bp , ax
	mov	cl , sizeField
	sub	cx , si
	cmp	cx , 2
	jl	okHor3
	dec	si
	sub	bp , 12
	xor	ax , ax
	mov	cx , 3
incsih3:
	cmp	field[bp][si] , 0
	jne	okHor3
	inc	si
	inc	ax
	cmp	ax , 5
	jl	incsih3	

	xor	ax , ax
	add	bp , 12
	sub	si , 5
	loop	incsih3

	inc	si
	sub	bp , 24
	mov	ok , 1
	mov	field[bp][si] , 1
	inc	si
	mov	field[bp][si] , 1
	inc	si
	mov	field[bp][si] , 1

okHor3:

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret 

calcCorrectHor3	endp

calcCorrectVert3	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	xor	cx , cx
	mov	cl , x
	mov	si , cx
	mov	cl , y
	mov	bp , cx
	mov	cl , sizeField
	sub	cx , bp
	cmp	cx , 2
	jl	okVert3	
	xor	cx , cx
	mov	cl , y
	xor	dx , dx
	mov	ax , 12
	mul	cx
	mov	bp , ax
	dec	si
	sub	bp , 12
	xor	ax , ax
	mov	cx , 5
incsi3:
	cmp	field[bp][si] , 0
	jne	okVert3
	inc	si
	inc	ax
	cmp	ax , 3
	jl	incsi3	

	xor	ax , ax
	add	bp , 12
	sub	si , 3
	loop	incsi3 

	inc	si
	sub	bp , 24
	mov	ok , 1
	mov	field[bp][si] , 1
	sub	bp , 12
	mov	field[bp][si] , 1
	sub	bp , 12
	mov	field[bp][si] , 1

okVert3:

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret 

calcCorrectVert3	endp

calcCorrectVert2	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	xor	cx , cx
	mov	cl , x
	mov	si , cx
	mov	cl , y
	mov	bp , cx
	mov	cl , sizeField
	sub	cx , bp
	cmp	cx , 1
	jl	okVert2
	xor	cx , cx
	mov	cl , y
	xor	dx , dx
	mov	ax , 12
	mul	cx
	mov	bp , ax
	dec	si
	sub	bp , 12
	xor	ax , ax
	mov	cx , 4
incsi2:
	cmp	field[bp][si] , 0
	jne	okVert2
	inc	si
	inc	ax
	cmp	ax , 3
	jl	incsi2	

	xor	ax , ax
	add	bp , 12
	sub	si , 3
	loop	incsi2 

	inc	si
	sub	bp , 24
	mov	ok , 1
	mov	field[bp][si] , 1
	sub	bp , 12
	mov	field[bp][si] , 1

okVert2:

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret

calcCorrectVert2	endp

calcCorrectHor2	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	xor	cx , cx
	mov	cl , x
	mov	si , cx
	mov	cl , y
	xor	dx , dx
	mov	ax , 12
	mul	cx
	mov	bp , ax
	mov	cl , sizeField
	sub	cx , si
	cmp	cx , 1
	jl	okHor2
	dec	si
	sub	bp , 12
	xor	ax , ax
	mov	cx , 3
incsi:
	cmp	field[bp][si] , 0
	jne	okHor2
	inc	si
	inc	ax
	cmp	ax , 4
	jl	incsi	

	xor	ax , ax
	add	bp , 12
	sub	si , 4
	loop	incsi 

	inc	si
	sub	bp , 24
	mov	ok , 1
	mov	field[bp][si] , 1
	inc	si	
	mov	field[bp][si] , 1

okHor2:

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret

calcCorrectHor2	endp

calcCorrect1	proc

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	xor	cx , cx
	xor	si , si
	xor	bx , bx
	mov	cl , x
	mov	si , cx
	mov	cl , y
	xor	dx , dx
	mov	ax , 12
	mul	cx
	mov	bx , ax
	dec	si
	sub	bx , 12
	xor	ax , ax
	mov	cx , 3
decsi:
	cmp	field[bx][si] , 0
	jne	ok1
	inc	si
	inc	ax
	cmp	ax , 3
	jl	decsi	

	xor	ax , ax
	add	bx , 12
	sub	si , 3
	loop	decsi 

	inc	si
	sub	bx , 24
	mov	ok , 1
	mov	field[bx][si] , 1
ok1:

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret 
calcCorrect1	endp

calcNShip proc
;вычисляе< количество клеток зани<ае<ые корaбля<и
	push	ax
	push	bx

	xor	ah,ah
	mov	al,ship4
	mov	bl,4
	mul	bl
	mov	Nship,al
	xor	ax,ax
	mov	al,ship3
	mov	bl,3
	mul	bl
	add	Nship,al
	xor	ax,ax
	mov	al,ship2
	mov	bl,2
	mul	bl
	add	Nship,al
	xor	ax,ax
	mov	al,ship1
	add	Nship,al
	
	pop	cx
	pop	bx
ret
calcNShip endp

calcStatus	proc
	push	bx
	push	si

	mov	bx,statusy
	mov	si,statusx
	sub	bx,12
	cmp	field[bx][si],1
	jne	status1
	mov	status,0 ; не убил а только попал
	jmp	finstatus
status1:
	cmp	field[bx][si],2

finstatus:
	pop	si
	pop	bx
ret
calcStatus	endp