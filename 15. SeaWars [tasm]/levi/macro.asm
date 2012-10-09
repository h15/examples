pushr	macro	registers
	irp	reg, <registers>
		push	reg
	endm
endm	pushr

popr	macro	registers
	irp	reg, <registers>
		pop	reg
	endm
endm	popr

movpp	macro	reg1, reg2
	push	reg2
	pop	reg1
endm	movpp


newline macro
	pushr	<ax, dx, ds>
	jmp	@@tmp1
msg	db	0ah, 0dh, '$'
	@@tmp1:
	movpp	ds, cs
	lea	dx, msg
	mov	ah, 9h
	int	21h
	popr	<ds, dx, ax>
endm newline

sep macro
	pushr	<ax, dx, ds>
	jmp	@@tmp2
	msg2	db	'----', 0ah, 0dh, '$'
	@@tmp2:
	movpp	ds, cs
	lea	dx, msg2
	mov	ah, 9h
	int	21h
	popr	<ds, dx, ax>
endm sep
buffer	db	7 dup (0), '$'

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Prints signed decimal number to screen.
	; Call:
	; push number
	; call prints
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

prints proc	near
	push	bp
	mov	bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	ds
	movpp	ds, cs

	mov	ax, [bp+4]
	xor	si, si
	test	ax, ax
	jns	@@0
	inc	si
	neg	ax
@@0:
	lea	bx, buffer+7
	mov	cx, 10

@@1:
	xor	dx, dx
	div	cx
	add	dx, '0'
	dec	bx
	mov	[bx], dl
	or	ax, ax
	jnz	@@1

	test	si, si
	jz	@@2
	dec	bx
	mov	byte ptr [bx], '-'
@@2:
	mov	dx, bx
	mov	ah, 9
	int	21h

	pop	ds
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	ret	2
prints	endp

