locals @@
	.model tiny
	.code
	.386
	org 100h

_start: 
	jmp	_1
.data

xx		db	0
yy		db	0
Buf_Size  	equ  	1024           ; pазмеp буфеpа
Source    	db   	Buf_Size+2 dup (0) ; буфеp пpиема символов
Src_ptr   	dw  	Source         ; указатель позиции в буфеpе
Count     	dw   	0              ; количество символов в буфеpе
Ser_ip    	dw   	0              ; стаpый адpес Int 0Ch
Ser_cs    	dw   	0
Save_ds   	dw   	0              ; служебные пеpеменные
Int_sts   	db   	0
Overrun   	db   	0
hidec	db	0
Nship		db	0
ship1		db	0
ship2		db	0
ship3		db	0
ship4		db	0
hNship		db	0
hship1		db	1
hship2		db	0
hship3		db	0
hship4		db	0
sizeField	db	6
;делаем поле на 1 строчку/столбец больше с каждой стороны для удобства проверок расстановки кораблей т е нумерация будет с 1
field		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ;0 - пустая клетка поля
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ;1 - здесь стоит корабль, который еще не подбили
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ;2 - раненый/убитый корабль
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ;3 - сюда уже стреляли но здесь ничего нет
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
		db	0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 
fieldOp		db	5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 ;5 - края,это не поле
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 ;1 - здесь корабль противника
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 ;2 - сюда стреляла,либо точно ничего нет
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5
		db	5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5
		db	5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5 
allPar		db	0 , 0 , 0 , 0 , 0
rightBord2f	dw	0
rightBord1f	dw	0
leftBord2f	dw	296
bottomBord	dw	0
topBord		dw	48
ok		dw	0
myName		db	51h , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0  
opName		db	4eh , 6fh , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
master		dw	0;slave=0 master =1
McountIn	dw	0
ScountIn	dw	0
McountOut	dw	0
win		dw	0
exit		dw	0
clean		db	80 dup(0)
clean1		db	80 dup(00h)
x		db	1
y		db	1
x1		dw	1
y1		dw	1
stat		dw	?

miss		db	2 dup (3)
miss1		db	2 dup (3)
msgNic		db	'Vvedi your Nic = 10 simbol : '
msgGB		db	'Good-Bye  ' 
msgFin		db	'Finish    ' 
msgRS		db	'Restart   ' 
msgRD		db	'Ready     ' 
msg4v		db	'4-verticl ' 
msg4h		db	'4-horizl  ' 
msg3v		db	'3-verticl ' 
msg3h		db	'3-horizl  ' 
msg2v		db	'2-vertcl  ' 
msg2h		db	'2-horzl   ' 
msg11		db	'1-cell' 
mGB			db	'You opponent exit!        '
mWin		db	'You win!                  '
mWon		db	'You lose                  '
myErrProt	db	'Error in my protocol      '
opErrProt	db	'Error in opponent protocol'
msgShur		db	'Your enemy surrended!     '
msgShur1	db	'Want surrender?           '
okGB		dw	0
okFin		dw	0
okRS		dw	0
okRD		dw	0
pp		db	0
xxx		db	0
yyy		db	0
fh4		dw	0
fv4		dw	0
fh3		dw	0
fv3		dw	0
fh2		dw	0
fv2		dw	0
f1		dw	0
xk		db	0
yk		db	0
myErr		dw	0
myHod		dw	0
status		dw	0
statusx		dw	0
statusy		dw	0
fyes		dw	0
Sflagerr	dw	0
Mflagerr	dw	0
slaveR	db	0
cansenda	db	1
b2	db	0
lgth	db	0
state	db	0
wstate4	db	0
sheepField	db	'Size of field:   7  '
sheep4	db	'Amount of:  ',0Dbh,0Dbh,0Dbh,0Dbh,' 1  '
sheep3	db	'Amount of:  ',0Dbh,0Dbh,0Dbh,'  2  '
sheep2	db	'Amount of:  ',0Dbh,0Dbh,'   5  '
sheep1		db	'Amount of:  ',0Dbh,'    a  '
mouseNotF	db	'Mouses Driver Not Found'
masp	db	07h,01h,02h,05h,0Ah
maxp	db	0Ah,01h,02h,05h,0Ah
minp	db	06h,00h,00h,00h,01h

.code

include macro.asm
include com.asm
include mdraw.asm
include calc.asm
include write.asm

;=============Timer===========;
Int_08h:
	cli
	push	ax
	cmp	master,1
	jne	_int_08s
	inc	McountIn	;time from last receive
	inc	McountOut	;time from last send	
	cmp	McountOut,10
	jl	_no
	cmp	cansenda,1
	jne	_waitc
	mov	al,0aah
	call	Out_Chr
_waitc:
	mov	McountOut,0
_no:
	cmp	McountIn,60
	jle	_nofin
	mov	Mflagerr,1
	mov	McountIn,0
	jmp	_nofin
_int_08s:
	inc	ScountIn
	cmp ScountIn,60;
	jle	_nofin
	mov	Sflagerr,1
	mov	ScountIn,0
_nofin:
	pop	ax
	db 0EAh
Int_08h_old	dw	0,0

;=========Start==========;
_1:
	call	_ms
	cmp	master,1
	jne	Slave0
	
	call	_inp

	xor	ax,ax
	push	ax
	pop	ds
	cmp	[ds:0CCh],ax
	push	cs
	pop	ds
	je	_mouseNF

	mov	ax,0
	int	33h
	cmp	ax,0
	je	_mouseNF

	mov	ax,01h
	int	33h

	mov	ax,0Ch
	mov	dx,offset _obr1
	mov	cx,2
	int	33h
_choosep:
	mov	ah,00h
	int	16h
	cmp	al,1Bh
	jnz	_choosep
	jmp	_vvNick
_mouseNF:
	mov	dx,offset mouseNotF
	mov	ah,09h
	int	21h
	ret
_vvNick:
	mov	ax,2		
	int	33h	
	xor	cx,cx
	mov	ax,0Ch
	int	33h
	mov	ah,0
	mov	al,7h
	int	10h
	
	mov	al,masp[0]
	mov	sizeField,al
	mov	al,masp[1]
	mov	ship4,al
	mov	al,masp[2]
	mov	ship3,al
	mov	al,masp[3]
	mov	ship2,al
	mov	al,masp[4]
	mov	ship1,al

	call	vvodNic	
	call	_intset
	call	_vset

	call	Ser_Ini
	
;############Masster

_State0:				;wait for answer 01 on owr aa
	call	Get_Chr
	jc	_State0
	cmp	al,01h
	jne	_State0
	mov McountIn,0
	mov	al,0a1h
	call	Out_Chr
_State01:
	call	Get_Chr
	jc	_State01
	cmp	al,01h
	jne	_State01_1a
	mov	McountIn,0
	jmp	_State01
_State01_1a:	
	cmp	al,1ah
	je	State1
	jmp _State01
State1:
	mov	McountIn,0
	
	mov	cansenda,0
	mov	al,0b1h
	call	Out_Chr
	mov	al,10
	call	Out_Chr
	xor	si,si
_State11:
	mov	al,myName[si]
	call	Out_Chr
	inc	si
	cmp	si,10
	jne	_State11
	mov	cansenda,1
	
_State1:
	cmp	state,2
	jl	_State2and1
	cmp	okFin,1
	jne	_State21
	mov	al,0a6h
	call	Out_Chr
	jmp	Condition6
_State21:
	cmp	okGB,1
	jne	_State22	
	mov	al,0a7h
	call	Out_Chr
	jmp	Condition7
_State22:
	cmp	okRS,1
	jne	_State23
	mov	al,0a5h
	call	Out_Chr
	jmp	Condition5
_State23:
	cmp	state,3
	je	_State2and1
	cmp	okRD,1
	jne	_State2and1
	mov	al,0a3h
	call	Out_Chr
	mov	state,3
	jmp	_State1
	;;wait for 3a and go to the state 3

_State2and1:
	call	Get_Chr
	jc	_State1
	cmp	al,01h
	jne	_State2_3a
	mov	McountIn,0
	jmp	_State1
_State2_3a:
	cmp	state,3
	jne	_State2_a4
	cmp	wstate4,1
	je	_State2_a4
	cmp	al,03ah
	jne	_State2_a4
	mov	McountIn,0
	mov	wstate4,1
	;wait a4 from slave
	jmp	_State1
_State2_a4:
	cmp	wstate4,1
	jne	_State1_a6
	cmp	al,0a4h
	jne	_State1_a6
	mov	McountIn,0
	mov	al,04ah
	call	Out_Chr
	jmp	State4
_State1_a6:
	cmp	al,0a6h
	jne	_State1_a7
	mov	MCountIn,0
	mov	al,06ah
	call	Out_Chr
	jmp	Condition6
_State1_a7:
	cmp	al,0a7h
	jne	_State1_a8
	mov	MCountIn,0
	mov	al,07ah
	call	Out_Chr
	jmp	Condition7
_State1_a8:
	cmp	al,0a8h
	jne	_State1_2a
	mov	MCountIn,0
	mov	al,08ah
	call	Out_Chr
	jmp	Condition8
_State1_2a:
	cmp	state,0
	jne	_State1_b1
	cmp	al,02ah
	jne	_State1_b1
	jmp	_State2
_State1_b1:
	cmp	al,0b1h
	jne	_State12
	mov	McountIn,0
	mov	cansenda,0
_State1_b11:
	call	Get_Chr
	jc	_State1_b11
	mov	McountIn,0
	mov	lgth,al	
	xor	si,si
_State1_b12:
	call	Get_Chr
	jc	_State1_b12
	mov	opName[si],al
	mov	McountIn,0
	inc	si
	cmp	si,10
	jl	_State1_b13
	jmp	_State1_b14
_State1_b13:
	mov	dx,si
	cmp	dl,lgth
	jl	_State1_b12
_State1_b14:
	call	wrNic
	mov	al,01bh
	call	Out_Chr
	mov	cansenda,1
	jmp	_State1
_State12:
	cmp	al,01bh
	je	_State1_b2
_State1_2b:
	cmp	b2,0
	je	_State1
	cmp	b2,1
	jne	_State1
	cmp	state,0
	jne	_State1
	cmp	al,02bh
	jne	_State1
		
	mov	cansenda,0
	mov	McountIn,0
	xor	bx,bx	
_State1_2b1:
	call 	Get_Chr
	jc	_State1_2b1
	mov	McountIn,0
	mov	allPar[bx],al
	inc	bx
	cmp	bx,5
	jne	_State1_2b1
	mov	cansenda,1
	xor	si,si
_comp:
	mov	al,allPar[si]
	cmp	masp[si],al
	jne	Condition8
	inc	si
	cmp	si,5
	jne	_comp
	mov	al,0a2h
	call	Out_Chr
	
	mov	b2,2
	jmp	_State1
_State1_b2:
	mov	McountIn,0
	cmp	b2,0
	jne	_State1
	mov	b2,1
	mov	cansenda,0
	mov	al,0b2h
	call	Out_Chr
	mov	al,sizeField
	call	Out_Chr
	mov	al,ship4
	mov	hship4,al
	call	Out_Chr
	mov	al,ship3
	mov	hship3,al
	call	Out_Chr
	mov	al,ship2
	mov	hship2,al
	call	Out_Chr
	mov	al,ship1
	mov	hship1,al
	call	Out_Chr
	mov	cansenda,1
	
	jmp	_State1
	
_State2:
	
	mov	McountIn,0
	call 	drawField
	call	wrInf
	call	calcNShip

	mov	al,Nship
	mov	hNship,al

	mov	ax,01h
	int	33h
	mov	ax,000Ch
	mov	cx,02h
	mov	dx,offset ObrRasstS
	int 33h

;hang mouse ,state2,wait pushing button RD
	mov	state,2
	jmp	_State1
;###############++Game++############;	
State4:
	mov	ax,02h
	int 33h
	
	mov	ax,000Ch
	mov	cx,0
	int 33h

	mov	dl,70
	mov	dh,5
	mov	cx,10
	mov	pp,0
clean4:
	mov	cx,10
	add	dh,2
	mov	dl,70
	call	wrClean
	add	pp,1
	cmp	pp,9
	jl	clean4
	
	xor	ax, ax
	int	33h

	mov	ax,000Ch
	mov	cx,0002h
	mov	dx,offset Game
	int 33h
	
	mov	ax,01h
	int	33h

	call	wrHod

	mov	myHod,1
		
MCondition41:
	cmp	fyes,1
	jne	Mnext40
	
	call	calcAttackShip
	
	mov	ax,02h
	int	33h
	mov	cansenda,0
	
	mov	hidec,1
	
	mov	al,0c0h
	call	Out_Chr
	mov	al,x
	call	Out_Chr
	mov	al,y
	call	Out_Chr
	mov	cansenda,1
Mansw:
	call	Get_Chr
	jc	Mansw
	cmp	al,1
	jne	Mansww
	mov	McountIn,0
	jmp	Mansw
Mansww:
	mov	McountIn,0
	cmp	al,00ch
	jne	Mansw1
	mov	myHod,0
	mov	fyes,0
	call	wrWait
	xor	ah,ah
	mov	al,x
	mov	si,ax
	xor	ax,ax
	xor	bh,bh
	xor	dx,dx
	mov	bl,y
	mov	ax,12
	mul	bx
	mov	fieldOp[bx][si],2
	call	drawMissOpponent

	jmp	Mnext40	
Mansw1:	
	cmp	al,03ch
	jne	Mansw2
	mov	myHod,0
	mov	fyes,0
	call	wrWait

	jmp	Mnext40
Mansw2:
	cmp	al,01ch
	jne	Mansw3
	call	drawKillOpponent

	sub	Nship,1
	xor	ah,ah
	mov	al,x
	mov	si,ax
	xor	ax,ax
	xor	bh,bh
	xor	dx,dx
	mov	bl,y
	mov	ax,12
	mul	bx
	mov	bx,ax
	mov	fieldOp[bx][si],1	
	sub	bx,12
	sub	si,1
	sub	x,1
	sub	y,1
	cmp	fieldOp[bx][si],5
	je	Mansw21
	mov	fieldOp[bx][si],2
	call	drawMissOpponent
Mansw21:
	add	si,2
	add	x,2
	cmp	fieldOp[bx][si],5
	je	Mansw23
	mov	fieldOp[bx][si],2
	call	drawMissOpponent
Mansw23:
	add	bx,24
	add	y,2
	cmp	fieldOp[bx][si],5
	je	Mansw24
	mov	fieldOp[bx][si],2
	call	drawMissOpponent
Mansw24:
	sub	si,2
	sub	x,2
	cmp	fieldOp[bx][si],5
	je	hhh
	mov	fieldOp[bx][si],2
	call	drawMissOpponent
hhh:
	mov	myHod,1
	mov	fyes,0
	jmp	Mnext40
Mansw3:
	cmp	al,02ch
	jne	Mansw	;хотя по идее это ошибка	
	call	drawKillOpponent

	sub	Nship,1
	xor	ax,ax
	mov	al,x
	mov	si,ax
	xor	ax,ax
	xor	bx,bx
	xor	dx,dx
	mov	bl,y
	mov	ax,12
	mul	bx
	mov	bx,ax
	mov	fieldOp[bx][si],1	
	sub	bx,12
	sub	si,1
	sub	x,1
	sub	y,1
	cmp	fieldOp[bx][si],5
	je	Mansw31
	mov	fieldOp[bx][si],2
	call	drawMissOpponent
Mansw31:
	add	si,2
	add	x,2
	cmp	fieldOp[bx][si],5
	je	Mansw33
	mov	fieldOp[bx][si],2
	call	drawMissOpponent
Mansw33:
	add	bx,24
	add	y , 2
	cmp	fieldOp[bx][si] , 5
	je	Mansw34
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Mansw34:
	sub	si , 2
	sub	x , 2
	cmp	fieldOp[bx][si] , 5
	je	Mansw35
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Mansw35:
	add	si , 1
	add	x , 1
	sub	bx , 12
	sub	y , 1
	mov	ax , si
	mov	xxx , al
	mov	al , y
	mov	yyy , al 
Mansw36:	
	sub	bx , 12
	sub	y , 1
	cmp	fieldOp[bx][si] , 1
	je	Mansw36
	cmp	fieldOp[bx][si] , 0
	jne	Mansw37
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent	
Mansw37:
	xor	ax , ax
	mov	al , yyy
	mov	y , al
	mov	bx , 12
	mul	bx
	mov	bx , ax
Mansw371:
	add	bx , 12
	add	y , 1
	cmp	fieldOp[bx][si] , 1
	je	Mansw371
	cmp	fieldOp[bx][si] , 0
	jne	Mansw38
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Mansw38:
	xor	ax , ax
	mov	al , yyy
	mov	y , al
	mov	bx , 12
	mul	bx
	mov	bx , ax
Mansw381:
	add	si , 1
	add	x , 1
	cmp	fieldOp[bx][si] , 1
	je	Mansw381
	cmp	fieldOp[bx][si] , 0
	jne	Mansw39
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Mansw39:
	xor	ax , ax
	mov	al , xxx
	mov	x , al
	mov	si , ax
Mansw391:
	sub	si , 1
	sub	x , 1
	cmp	fieldOp[bx][si] , 1
	je	Mansw391
	cmp	fieldOp[bx][si] , 0
	jne	hhhh
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
hhhh:
	mov	myHod,1
	mov	fyes,0
Mnext40:
	cmp	hidec,1
	jne	Mnext40w
	mov	ax,01h
	int	33h

	mov	hidec,0
Mnext40w:	
	cmp	okFin,1
	jne	Mnext41	
	mov	al,0A6h
	call	Out_Chr
	jmp	Condition6
Mnext41:
	cmp	okGB,1
	jne	Mnext42	
	mov	al,0A7h
	call	Out_Chr
	jmp	Condition7
Mnext42:
	cmp	Nship, 0
	jne	Mnext43
	mov	myHod,0
	mov	al,0a9h
	call	Out_Chr
Mnext421:
	call	Get_Chr	
	jc	Mnext421;;;;;;;;;;;;;;&&&&или куда там все сольется
	cmp	al,1
	jne	Mnext421w
	mov	McountIn,0
	jmp	Mnext421
Mnext421w:
	cmp	al,9ah
	jne	Mnext421
	call	wrWin
	jmp	Condition9
Mnext43:
	call	Get_Chr
	jc	MCondition41
	cmp	al,01h
	jne	MnextS41
	mov	McountIn , 0
	jmp	MCondition41
MnextS41:
	cmp	al,0a6h
	jne	MnextS42
	mov	McountIn , 0	
	mov	al, 06ah
	call	Out_Chr
	jmp	Condition6
MnextS42:
	cmp	al, 0a7h
	jne	MnextS43
	mov	McountIn , 0	
	mov	al , 07ah
	call	Out_Chr
	jmp	Condition7
MnextS43:
	cmp	al, 0a8h
	jne	MnextS44
	mov	McountIn , 0	
	mov	al , 08ah
	call	Out_Chr
	mov	myErr , 1
	jmp	Condition8
MnextS44:	
	cmp	al, 0c0h
	jne	Mnext49
	mov	McountIn , 0
Mnext441:
	call	Get_Chr
	jc	Mnext441
	mov	xx , al
	mov	x , al
	mov	McountIn , 0
Mnext442:
	call	Get_Chr
	jc	Mnext442
	mov	yy , al	
	mov	y , al
	mov	McountIn , 0
	xor	ax , ax
	xor	bx , bx
	mov	ax , 12
	mov	bl , yy
	mul	bx
	mov	bx , ax
	xor	ax , ax
	mov	al , xx
	mov	si , ax
	cmp 	field[bx][si] , 0
	jne	Mnext443
	mov	myHod , 1
	call	wrHod
	mov	field[bx][si] , 3
	call	drawMissMy
	mov	al , 00ch
	call	Out_Chr
	jmp	MCondition41
Mnext443:
	cmp 	field[bx][si] , 2
	jne	Mnext444
	mov	myHod , 1
	call	wrHod
	xor	ax , ax
	mov	al , 03ch
	call	Out_Chr
	jmp	MCondition41
Mnext444:
	cmp 	field[bx][si] , 3
	jne	Mnext445
	mov	al , 03ch
	push	ax
	call	Out_Chr
	mov	myHod , 1	
	call	wrHod
	jmp	MCondition41
Mnext445:
	mov 	field[bx][si] , 2
	push	bx
	mov	bl , 00111100b
	call	drawKillMy	
	pop	bx
Mnext4451:
	sub	bx , 12
	cmp	field[bx][si] , 1
	je	Mnext48
	cmp	field[bx][si] , 2
	je	Mnext4451
Mnext446:
	xor	ax , ax
	xor	dx , dx
	mov	al , yy
	mov	bx , 12
	mul	bx
	mov	bx , ax
Mnext4461:
	add	bx , 12
	cmp	field[bx][si] , 1
	je	Mnext48
	cmp	field[bx][si] , 2
	je	Mnext4461
Mnext447:	
	xor	ax , ax
	xor	dx , dx
	mov	al , yy
	mov	bx , 12
	mul	bx
	mov	bx , ax
Mnext4471:
	dec	si
	cmp	field[bx][si] , 1
	je	Mnext48
	cmp	field[bx][si] , 2
	je	Mnext4471
Mnext448:
	xor	dx , dx
	mov	al , xx
	mov	si , ax
Mnext4481:
	inc	si
	cmp	field[bx][si] , 1
	je	Mnext48
	cmp	field[bx][si] , 2
	je	Mnext4481
	mov	al , 2ch
	call	Out_Chr
	jmp	MCondition41 

Mnext48:
	mov	al , 1ch
	call	Out_Chr
	jmp	MCondition41 

Mnext49:
	cmp	al, 0a9h
	jne	Mnext4a
	mov	al , 09ah
	call	Out_Chr
	call	wrWon
	jmp	Condition9
Mnext4a:
	cmp	al, 0b1h
	jne	Mnext4b
	mov	McountIn , 0
Mnext4a1:
	call	Get_Chr
	jc	Mnext4a1
	mov	McountIn , 0
	mov	pp , al
	mov	si , 0
Mnext4a2:
	call	Get_Chr
	jc	Mnext4a2
	mov	McountIn , 0
	mov	opName[si] , al
	inc	si
	cmp	si , 10
	jl	Mnext4a21
	call	wrNic
	mov	al , 01bh
	call	Out_Chr
	jmp	Mnext4b
Mnext4a21:
	xor	dx , dx
	mov	dx , si
	cmp	dl , pp
	jl	Mnext4a2
	call	wrNic
	mov	al , 01bh
	call	Out_Chr
Mnext4b:
	cmp	al, 1bh
	jne	Mnext4c	
	mov	McountIn,0
	jmp	MCondition41
Mnext4c:
	jc	MCondition41
	jmp	MCondition41

	
	
	
Condition9:
	mov	cx,0
	mov	ax,0Ch
	int	33h

	jmp	fin
Condition5:
	call	Get_Chr
	cmp	al,5ah
	jne	Condition5
	
	mov	ax , 0a000h
	mov	es , ax
	xor	ax , ax
	mov	al , 0h
	mov	cx , 07000h
	xor	di , di
	rep	stosb
	
	mov	okRS , 0
	mov	okRD , 0
	mov	OkFin , 0
	mov	OkGB , 0
	mov	fh4 , 0
	mov	fv4 , 0
	mov	fh3 , 0
	mov	fv3 , 0
	mov	fh2 , 0
	mov	fv2 , 0
	mov	f1 , 0

	mov	bx , 12
	mov	si , 1
	mov	cx , 9
cycle1:
	mov	field[bx][si] , 0
	mov	fieldOp[bx][si] , 0
	inc	si
	cmp	si , 11
	jl	cycle1
	sub	si , 10
	add	bx , 12
	cmp	bx , 120
	jle	cycle1
	
	mov	hidec,0
	mov wstate4,0
	mov	state,0
	mov cansenda,1
	mov	McountIn , 0
;снять старый обработчик мыши
	jmp	State1	
	
Condition6:
	mov 	ax , 000Ch
	mov 	cx , 0000h ; удалить обработчик событий мыши
	int 	33h

	mov	dl , 0
	mov	dh , 0
	mov	cx , 80
	call	wrClean	
	
	cmp	okFin , 1
	jne	noI
	lea	bp , msgShur1
	jmp	II
noI:
	lea	bp , msgShur
II:
	mov	ah, 13h
	mov	al , 01h
	mov	bh , 0
	mov	bl , 00111011b
	mov	cx , 26
	mov	dl , 0
	mov	dh , 0	
	int	10h
		mov	hidec,0
	mov wstate4,0
	mov	state,0
	mov cansenda,1
	mov	McountIn , 0
	jmp	Condition9

Condition7:
	mov 	ax , 000Ch
	mov 	cx , 0000h ; удалить обработчик событий мыши
	int 	33h

	cmp	okGB , 1
	je	fin 

	mov	ax , 0a000h
	mov	es , ax
	xor	ax , ax
	mov	al , 0h
	mov	cx , 07000h
	xor	di , di
	rep	stosb

	mov	ah, 13h
	mov	al , 01h
	mov	bh , 0
	mov	bl , 00111011b
	mov	cx , 26
	mov	dl , 0
	mov	dh , 0
	lea	bp , mGB	
	int	10h

	mov	okRS , 0
	mov	okRD , 0
	mov	OkFin , 0
	mov	OkGB , 0
	mov	fh4 , 0
	mov	fv4 , 0
	mov	fh3 , 0
	mov	fv3 , 0
	mov	fh2 , 0
	mov	fv2 , 0
	mov	f1 , 0

	mov	bx , 12
	mov	si , 1
	mov	cx , 9
cycle2:
	mov	field[bx][si] , 0
	mov	fieldOp[bx][si] , 0
	inc	si
	cmp	si , 11
	jl	cycle2
	sub	si , 10
	add	bx , 12
	cmp	bx , 120
	jle	cycle2

	mov	Mflagerr , 0
	mov	McountIn , 0

		mov	hidec,0
	mov wstate4,0
	mov	state,0
	mov cansenda,1
	mov	McountIn , 0
	jmp	_State0

Condition8:
	mov 	ax , 000Ch
	mov 	cx , 0000h ; удалить обработчик событий мыши
	int 	33h

	cmp	myErr , 1
	je	mr
	lea	bp , opErrProt
	jmp	nmr
mr:
	lea	bp , myErrProt
nmr:
	mov	ah, 13h
	mov	al , 01h
	mov	bh , 0
	mov	bl , 00111011b
	mov	cx , 26
	mov	dl , 0
	mov	dh , 0	
	int	10h
ohoho:	
	mov	ax , 03h
	int	33h
	and	bl , 0010b
	cmp	bl , 0010b
	jne	ohoho

	mov	ax , 0a000h
	mov	es , ax
	xor	ax , ax
	mov	al , 0h
	mov	cx , 07000h
	xor	di , di
	rep	stosb
	
	mov	okRS , 0
	mov	okRD , 0
	mov	OkFin , 0
	mov	OkGB , 0
	mov	fh4 , 0
	mov	fv4 , 0
	mov	fh3 , 0
	mov	fv3 , 0
	mov	fh2 , 0
	mov	fv2 , 0
	mov	f1 , 0

	mov	bx , 12
	mov	si , 1
	mov	cx , 9
cycle3:
	mov	field[bx][si] , 0
	mov	fieldOp[bx][si] , 0
	inc	si
	cmp	si , 11
	jl	cycle3
	sub	si , 10
	add	bx , 12
	loop	cycle3
mov 	hidec,0
	mov	Mflagerr , 0
		mov	hidec,0
	mov wstate4,0
	mov	state,0
	mov cansenda,1
	mov	McountIn , 0

	jmp	_State0
;=========================Slave===============
Slave0:;;;;;+++++++++++++++
	call	_intset
	call	_vset

	call	Ser_Ini

	call	vvodNic	
;#############Slave
;	mov	ah,09h
;	xor	al,al
;	mov	dx,offset str11
;	int	21h	
	
_Slave0:
	call	Get_Chr
	jnc	_Slave0
	cmp	al,0aah
	jne	_Slave_a1
	
	mov	ScountIn,0
	mov	al,01h
	call	Out_Chr
	jmp	_Slave0
_Slave_a1:
	cmp	al,0a1h
	jne	_Slave0
	mov	ScountIn,0
	mov	al,1ah
	call	Out_Chr
		
_Slave1:
	cmp	state,0
	je	_Slave2and1
	cmp	okFin,1
	jne	_Slave21
	mov	al,0a6h
	call	Out_Chr
	jmp	SCondition6
_Slave21:
	cmp	okGB,1
	jne	_Slave22	
	mov	al,0a7h
	call	Out_Chr
	jmp	SCondition7
_Slave22:
	cmp	okRS,1
	jne	_Slave23
	mov	al,0a5h
	call	Out_Chr
	jmp	SCondition5
_Slave23:
	cmp	state,4
	je	_Slave2and1
	cmp	okRD,1
	jne	_Slave2and1
	mov	slaveR,1
	cmp	state,3;нажали готов но мастер еще не прислал! переписать!!!
	jne	_Slave2and1
	mov	al,0a4h
	call	Out_Chr
	mov	state,4
;	wait for master 4a
;	xor	ax,ax
;	mov	ah,09h
;	mov	dx,offset s4a1
;	int	21h

	jmp	_Slave1
	;;wait for 3a and go to the state 3



_Slave2and1:
	call	Get_Chr
	jc	_Slave1
	cmp	al,0aah
	jne	_Slave3_4a
	mov	ScountIn,0
	mov	al,01h
	call	Out_Chr
	jmp	_Slave1
_Slave3_4a:
	cmp	state,4
	jne	_Slave2_a3
	cmp	al,04ah
	jne	_Slave2_a3
	mov	ScountIn,0
		xor	ax,ax
;	mov	ah,09h
;	mov	dx,offset sa4
;	int	21h
	jmp	Slave4
_Slave2_a3:
	cmp	state,2;;;;;;;;;;;;;;;;;;;;;;;;;;!!!!!!!!!!!!!!!!
	jne	_Slave1_a6
	cmp	al,0a3h
	jne	_Slave1_a6
	mov	ScountIn,0
	mov	al,03ah
	call	Out_Chr
	
	mov	state,3
	cmp	slaveR,1
	jne	_Slave1;wait for ready slave
	mov	al,0a4h
	call	Out_Chr
	mov	state,4
;	xor	ax,ax
;	mov	ah,09h
;	mov	dx,offset s4a2
;	int	21h
	jmp	_Slave1;wait for master answer 4a
	
_Slave1_a6:
	cmp	al,0a6h
	jne	_Slave1_a7
	mov	SCountIn,0
	mov	al,06ah
	jmp	SCondition6
_Slave1_a7:
	cmp	al,0a7h
	jne	_Slave1_a8
	mov	SCountIn,0
	mov	al,07ah
	jmp	SCondition7
_Slave1_a8:
	cmp	al,0a8h
	jne	_Slave1_b1
	mov	SCountIn,0
	mov	al,08ah
	jmp	SCondition8
_Slave1_b1:
	cmp	al,0b1h
	jne	_Slave12
	mov	ScountIn,0
_Slave1_b11:
	call	Get_Chr
	jc	_Slave1_b11
	mov	ScountIn,0
	mov	lgth,al	
	xor	si,si
_Slave1_b12:
	call	Get_Chr
	jc	_Slave1_b12
	mov	opName[si],al
	mov	ScountIn,0
	inc	si
	cmp	si,10
	jl	_Slave1_b13
	jmp	_Slave1_b14
_Slave1_b13:
	mov	dx,si
	cmp	dl,lgth
	jl	_Slave1_b12
_Slave1_b14:	
	call	wrNic
	mov	al,01bh
	
	call	Out_Chr
	mov	al,0b1h
	call	Out_Chr
	mov	al,10
	call	Out_Chr
	xor	si,si
_Slave11:
	mov	al,myName[si]
	call	Out_Chr
	inc	si
	cmp	si,10
	jne	_Slave11
	jmp	_Slave1
_Slave12:
	cmp	al,01bh
	jne	_Slave1_a2
	mov	ScountIn,0
	jmp	_Slave1
_Slave1_a2:
	cmp	state,0
	jne	_Slave1
	cmp	al,0a2h
	jne	_Slave1_b2
	mov	ScountIn,0
	mov	al,02ah
	call	Out_Chr
	jmp	_Slave2
_Slave1_b2:
	cmp	al,0b2h
	jne	_Slave1
	mov	ScountIn,0
	xor	bx,bx
_Slave1_b21:
	call Get_Chr
	jc	_Slave1_b21	
	mov	ScountIn,0
	mov	allPar[bx],al
	inc	bx
	cmp	bx,5
	jne	_Slave1_b21
	
	mov	al,allPar[0]
	mov	sizeField,al
	mov	al,allPar[1]
	mov	ship4,al
	mov	hship4 , al
	mov	al,allPar[2]
	mov	ship3,al
	mov	hship3 , al
	mov	al,allPar[3]
	mov	ship2,al
	mov	hship2 , al
	mov	al,allPar[4]
	mov	ship1,al
	mov	hship1 , al
	
	mov	al,02Bh
	call	Out_Chr
	mov	al,sizeField
	call	Out_Chr
	mov	al,ship4
	call	Out_Chr
	mov	al,ship3
	call	Out_Chr
	mov	al,ship2
	call	Out_Chr
	mov	al,ship1
	call	Out_Chr
	jmp	_Slave1
_Slave2:
	call 	drawField
	call	wrInf
	call	calcNShip

	mov	al,Nship
	mov	hNship,al

	mov	ax,0
	int	33h
	
	mov	ax,01h
	int	33h
	
	mov	ax,000Ch
	mov	cx,02h
	mov	dx,offset ObrRasstS
	int 33h
;wait a3 from master and rd
	mov	state,2
	jmp	_Slave1
Slave4:
	mov	ax,02h
	int 33h
	
	mov	ax,000Ch
	mov	cx,0
	int 33h

	mov	dl,70
	mov	dh,5
	mov	cx,10
	mov	pp,0
clean42:
	mov	cx,10
	add	dh,2
	mov	dl,70
	call	wrClean
	add	pp,1
	cmp	pp,9
	jl	clean42

	xor ax, ax
	int 33h
	
	mov	ax,000Ch
	mov	cx,0002h
	mov	dx,offset Game
	int 33h
	
	mov	ax,01h
	int	33h
;	call	wrHod
SCondition41:

	cmp	fyes,1
	jne	Snext40
	
	call	calcAttackShip
	mov	ax , 02h
	int	33h
	
	mov	hidec,1
	
	mov	al , 0c0h
	call	Out_Chr
	mov	al , x
	call	Out_Chr
	mov	al , y
	call	Out_Chr
Sansw:
	call	Get_Chr
	jc	Sansw
	cmp	al,0aah
	jne	Sansww
	mov	ScountIn,0
	mov	al,1
	call	Out_Chr
	jmp	SCondition41
Sansww:
	mov	ScountIn , 0
	cmp	al, 00ch
	jne	Sansw1
	mov	myHod , 0
	mov	fyes , 0
	call	wrWait
	xor	ax , ax
	mov	al , x
	mov	si , ax
	xor	ax , ax
	xor	bx , bx
	xor	dx , dx
	mov	bl , y
	mov	ax , 12
	mul	bx
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
	jmp	Snext40	
Sansw1:	
	cmp	al, 03ch
	jne	Sansw2
	mov	myHod , 0
	mov	fyes , 0
	call	wrWait
	jmp	Snext40
Sansw2:
	cmp	al, 01ch
	jne	Sansw3
	call	drawKillOpponent
	sub	Nship , 1
	xor	ax , ax
	mov	al , x
	mov	si , ax
	xor	ax , ax
	xor	bx , bx
	xor	dx , dx
	mov	bl , y
	mov	ax , 12
	mul	bx
	mov	bx , ax
	mov	fieldOp[bx][si] , 1	
	sub	bx , 12
	sub	si , 1
	sub	x , 1
	sub	y , 1
	cmp	fieldOp[bx][si] , 5
	je	Sansw21
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw21:
	add	si , 2
	add	x , 2
	cmp	fieldOp[bx][si] , 5
	je	Sansw23
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw23:
	add	bx , 24
	add	y , 2
	cmp	fieldOp[bx][si] , 5
	je	Sansw24
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw24:
	sub	si , 2
	sub	x , 2
	cmp	fieldOp[bx][si] , 5
	je	Shhh
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Shhh:
	mov	myHod , 1
	mov	fyes , 0
	jmp	Snext40
Sansw3:
	cmp	al, 02ch
	jne	Sansw	;хотя по идее это ошибка	
	call	drawKillOpponent
	sub	Nship , 1
	xor	ax , ax
	mov	al , x
	mov	si , ax
	xor	ax , ax
	xor	bx , bx
	xor	dx , dx
	mov	bl , y
	mov	ax , 12
	mul	bx
	mov	bx , ax
	mov	fieldOp[bx][si] , 1	
	sub	bx , 12
	sub	si , 1
	sub	x , 1
	sub	y , 1
	cmp	fieldOp[bx][si] , 5
	je	Sansw31
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw31:
	add	si , 2
	add	x , 2
	cmp	fieldOp[bx][si] , 5
	je	Sansw33
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw33:
	add	bx , 24
	add	y , 2
	cmp	fieldOp[bx][si] , 5
	je	Sansw34
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw34:
	sub	si , 2
	sub	x , 2
	cmp	fieldOp[bx][si] , 5
	je	Sansw35
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw35:
	add	si , 1
	add	x , 1
	sub	bx , 12
	sub	y , 1
	mov	ax , si
	mov	xxx , al
	mov	al , y
	mov	yyy , al 
Sansw36:	
	sub	bx , 12
	sub	y , 1
	cmp	fieldOp[bx][si] , 1
	je	Sansw36
	cmp	fieldOp[bx][si] , 0
	jne	Sansw37
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent	
Sansw37:
	xor	ax , ax
	mov	al , yyy
	mov	y , al
	mov	bx , 12
	mul	bx
	mov	bx , ax
Sansw371:
	add	bx , 12
	add	y , 1
	cmp	fieldOp[bx][si] , 1
	je	Sansw371
	cmp	fieldOp[bx][si] , 0
	jne	Sansw38
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw38:
	xor	ax , ax
	mov	al , yyy
	mov	y , al
	mov	bx , 12
	mul	bx
	mov	bx , ax
Sansw381:
	add	si , 1
	add	x , 1
	cmp	fieldOp[bx][si] , 1
	je	Sansw381
	cmp	fieldOp[bx][si] , 0
	jne	Sansw39
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Sansw39:
	xor	ax , ax
	mov	al , xxx
	mov	x , al
	mov	si , ax
Sansw391:
	sub	si , 1
	sub	x , 1
	cmp	fieldOp[bx][si] , 1
	je	Sansw391
	cmp	fieldOp[bx][si] , 0
	jne	Shhhh
	mov	fieldOp[bx][si] , 2
	call	drawMissOpponent
Shhhh:
	mov	myHod , 1
	mov	fyes , 0

Snext40:
	cmp	hidec,1
	jne	Snext40w
	mov	ax,01h
	int	33h
	mov	hidec,0
Snext40w:
	cmp	okFin , 1
	jne	next41	
	mov	al , 0A6h
	call	Out_Chr
	jmp	SCondition6
next41:
	cmp	okGB , 1
	jne	next42	
	mov	al , 0A7h
	call	Out_Chr
	jmp	SCondition7
next42:
	cmp	Nship, 0
	jne	next43
	mov	myHod , 0
	mov	al , 0a9h
	call	Out_Chr
next421:
	;cmp 	Sflagerr , 1
	;je	SCondition8
	call	Get_Chr	
	jc	next421
	cmp	al,0aah
	jne	next421w
	mov	al,1
	mov SCountIn,0
	call	Out_Chr
	jmp	next421
next421w:	
	mov	ScountIn , 0
	cmp	al , 9ah
	jne	next421 ; хотя по идее ошибка
	call	wrWin
	jmp	Condition9
next43:
	call	Get_Chr
	jc	SCondition41
	cmp	al, 0aah
	jne	nextS41
	mov	al , 01h
	call	Out_Chr
	mov	ScountIn , 0
	jmp	SCondition41
nextS41:
	cmp	al, 0a6h
	jne	nextS42
	mov	ScountIn , 0	
	mov	al , 06ah
	call	Out_Chr
	jmp	SCondition6
nextS42:
	cmp	al, 0a7h
	jne	nextS43
	mov	ScountIn , 0	
	mov	al , 07ah
	call	Out_Chr
	jmp	SCondition7
nextS43:
	cmp	al, 0a8h
	jne	nextS44
	mov	ScountIn , 0	
	mov	al , 08ah
	call	Out_Chr
	mov	myErr , 1
	jmp	SCondition8
nextS44:	
	cmp	al, 0c0h
	jne	next49
	mov	ScountIn , 0
next441:
	call	Get_Chr
	jc	next441
	
	mov	xx , al
	mov	x , al
	mov	ScountIn , 0
next442:
	call	Get_Chr
	jc	next442
	
	mov	yy , al	
	mov	y , al
	mov	ScountIn , 0
	xor	ax , ax
	xor	bx , bx
	mov	ax , 12
	mov	bl , yy
	mul	bx
	mov	bx , ax
	xor	ax , ax
	mov	al , xx
	mov	si , ax
	cmp 	field[bx][si] , 0
	jne	next443
	mov	myHod , 1
	call	wrHod
	mov	field[bx][si] , 3
	call	drawMissMy
	mov	al , 00ch
	call	Out_Chr
	jmp	SCondition41
next443:
	cmp 	field[bx][si] , 2
	jne	next444
	mov	myHod , 1
	call	wrHod
	mov	al , 03ch
	call	Out_Chr
	jmp	SCondition41
next444:
	cmp 	field[bx][si] , 3
	jne	next445
	mov	al , 03ch
	call	Out_Chr
	mov	myHod , 1
	call	wrHod
	jmp	SCondition41
next445:
	mov 	field[bx][si] , 2
	push	bx
	mov	bl , 00111100b
	call	drawKillMy
	pop	bx
next4451:
	sub	bx , 12
	cmp	field[bx][si] , 1
	je	next48
	cmp	field[bx][si] , 2
	je	next4451
next446:
	xor	ax , ax
	xor	dx , dx
	mov	al , yy
	mov	bx , 12
	mul	bx
	mov	bx , ax
next4461:
	add	bx , 12
	cmp	field[bx][si] , 1
	je	next48
	cmp	field[bx][si] , 2
	je	next4461
next447:	
	xor	ax , ax
	xor	dx , dx
	mov	al , yy
	mov	bx , 12
	mul	bx
	mov	bx , ax
next4471:
	dec	si
	cmp	field[bx][si] , 1
	je	next48
	cmp	field[bx][si] , 2
	je	next4471
next448:
	xor	dx , dx
	mov	al , xx
	mov	si , ax
next4481:
	inc	si
	cmp	field[bx][si] , 1
	je	next48
	cmp	field[bx][si] , 2
	je	next4481

	mov	al , 2ch
	call	Out_Chr
	jmp	SCondition41 

next48:
	mov	al , 1ch
	call	Out_Chr
	jmp	SCondition41 

next49:
	cmp	al, 0a9h
	jne	next4a
	mov	al , 09ah
	call	Out_Chr
	call	wrWon
	jmp	Condition9
next4a:
	cmp	al, 0b1h
	jne	next4b
	mov	ScountIn , 0
next4a1:
	call	Get_Chr
	jc	next4a1

	mov	ScountIn , 0
	mov	pp , al
	mov	si , 0
next4a2:
	call	Get_Chr
	jc	next4a2

	mov	ScountIn , 0
	mov	opName[si] , al
	inc	si
	cmp	si , 10
	jl	next4a21
	call	wrNic
	mov	al , 01bh
	call	Out_Chr
	jmp	next4b
next4a21:
	xor	dx , dx
	mov	dx , si
	cmp	dl , pp
	jl	next4a2
	call	wrNic
	mov	al , 01bh
	call	Out_Chr
next4b:
	cmp	al, 1bh
	jne	next4c
	mov	ScountIn , 0
	jmp	SCondition41
next4c:
	jc	SCondition41
	jmp	SCondition41
	
SCondition5:
		
	mov	ax , 0a000h
	mov	es , ax
	xor	ax , ax
	mov	al , 0h
	mov	cx , 07000h
	xor	di , di
	rep	stosb
	
	mov	okRS , 0
	mov	okRD , 0
	mov	OkFin , 0
	mov	OkGB , 0
	mov	fh4 , 0
	mov	fv4 , 0
	mov	fh3 , 0
	mov	fv3 , 0
	mov	fh2 , 0
	mov	fv2 , 0
	mov	f1 , 0

	mov	bx , 12
	mov	si , 1
	mov	cx , 9
Scycle1:
	mov	field[bx][si] , 0
	mov	fieldOp[bx][si] , 0
	inc	si
	cmp	si , 11
	jl	Scycle1
	sub	si , 10
	add	bx , 12
	loop	Scycle1

	mov	Sflagerr , 0
	mov	ScountIn , 0
	mov	hidec,0
	mov wstate4,0
	mov	state,0
	mov cansenda,1
	mov	McountIn , 0
	mov slaveR,0
	jmp	_Slave0	
	
SCondition6:
	mov 	ax , 000Ch
	mov 	cx , 0000h ; удалить обработчик событий мыши
	int 	33h

	mov	dl , 0
	mov	dh , 0
	mov	cx , 80
	call	wrClean	
	
	cmp	okFin , 1
	jne	SnoI
	lea	bp , msgShur1
	jmp	SII
SnoI:
	lea	bp , msgShur
SII:
	mov	ah, 13h
	mov	al , 01h
	mov	bh , 0
	mov	bl , 00111011b
	mov	cx , 26
	mov	dl , 0
	mov	dh , 0	
	int	10h
		mov	hidec,0
	mov wstate4,0
	mov	state,0
	mov cansenda,1
	mov	McountIn , 0
	mov slaveR,0
	jmp	Condition9


SCondition7:
	mov 	ax , 000Ch
	mov 	cx , 0000h ; удалить обработчик событий мыши
	int 	33h

	cmp	okGB , 1
	je	fin 

	mov	ax , 0a000h
	mov	es , ax
	xor	ax , ax
	mov	al , 0h
	mov	cx , 07000h
	xor	di , di
	rep	stosb

	mov	ah, 13h
	mov	al , 01h
	mov	bh , 0
	mov	bl , 00111011b
	mov	cx , 26
	mov	dl , 0
	mov	dh , 1
	lea	bp , mGB	
	int	10h

	
	
	mov	okRS , 0
	mov	okRD , 0
	mov	OkFin , 0
	mov	OkGB , 0
	mov	fh4 , 0
	mov	fv4 , 0
	mov	fh3 , 0
	mov	fv3 , 0
	mov	fh2 , 0
	mov	fv2 , 0
	mov	f1 , 0

	mov	bx , 12
	mov	si , 1
	mov	cx , 9
Scycle2:
	mov	field[bx][si] , 0
	mov	fieldOp[bx][si] , 0
	inc	si
	cmp	si , 11
	jl	Scycle2
	sub	si , 10
	add	bx , 12
	loop	Scycle2

	mov	Sflagerr , 0
	mov	ScountIn , 0
	mov	hidec,0
	mov wstate4,0
	mov	state,0
	mov cansenda,1
	mov	McountIn , 0
	mov slaveR,0
	jmp	_Slave0

SCondition8:
	mov 	ax , 000Ch
	mov 	cx , 0000h ; удалить обработчик событий мыши
	int 	33h

	cmp	myErr , 1
	je	Smr
	lea	bp , opErrProt
	jmp	Snmr
Smr:
	lea	bp , myErrProt
Snmr:
	mov	ah, 13h
	mov	al , 01h
	mov	bh , 0
	mov	bl , 00111011b
	mov	cx , 26
	mov	dl , 0
	mov	dh , 0	
	int	10h
Sohoho:	
	mov	ax , 03h
	int	33h
	and	bl , 0010b
	cmp	bl , 0010b
	jne	Sohoho

	mov	ax , 0a000h
	mov	es , ax
	xor	ax , ax
	mov	al , 0h
	mov	cx , 07000h
	xor	di , di
	rep	stosb
	
	mov	okRS , 0
	mov	okRD , 0
	mov	OkFin , 0
	mov	OkGB , 0
	mov	fh4 , 0
	mov	fv4 , 0
	mov	fh3 , 0
	mov	fv3 , 0
	mov	fh2 , 0
	mov	fv2 , 0
	mov	f1 , 0

	mov	bx , 12
	mov	si , 1
	mov	cx , 9
Scycle3:
	mov	field[bx][si] , 0
	mov	fieldOp[bx][si] , 0
	inc	si
	cmp	si , 11
	jl	Scycle3
	sub	si , 10
	add	bx , 12
	loop	Scycle3

	mov	Sflagerr , 0
	mov	ScountIn , 0
	mov	hidec,0
	mov wstate4,0
	mov	state,0
	mov cansenda,1
	mov	McountIn , 0
	mov slaveR,0
	jmp	_Slave0


;###############++Final and Err States++############;	
fin:
	call	Ser_Rst
	
	mov	ax, 0003h
	int	10h
	
	mov 	ax , 000Ch
	mov 	cx , 0000h ; удалить обработчик событий мыши
	int 	33h
	
	call	intun
	mov 	es , word ptr cs:[2Ch] ;Получим сегмент окружения DOS.
      	mov 	ah , 49h               ;Функция освобождения памяти.
     	int 	21h 
;	int 20h
;	mov	sp, 0FFFEh

@@d:

ret

_ms:
	mov	si,0082h
_2:	
	lodsb
	inc	si
	cmp	al,20h
	je	_2
	cmp	al,0dh
	je	_d1
	cmp	al,6dh
	jne	_d1
	inc	master
_d1:
ret
_intset:
	xor	ax,ax
	push	ax
	pop	ds
	mov	si,8h*4
	mov	di,offset Int_08h_old
	movsw
	movsw
	push	ds
	pop	es
	push	cs
	pop	ds
 
	mov	ax,offset Int_08h
	mov	di,8h*4
	cli
	stosw	
	push	cs
	pop	ax
	stosw
	sti	
ret	
_vset:
	mov	al,10h
	xor	ah,ah
	int	10h
	mov	al,ah
	mov	ah,05h
	int	10h
ret

_inp:
	xor	ah,ah
	mov	al,10h
	int	10h	

	mov	ah,13h
	mov	al,01h
	xor	bh,bh
	mov	bl,24h
;	mov	cx,14
;	mov	dx,0707h
;	mov	bp,offset namae
;	int	10h
	mov	bp,offset sheepField
	mov	cx,20
	mov	dx,0A11h
	int	10h
	mov	bp,offset sheep4
	mov	dh,0dh
	int	10h
	mov	bp,offset sheep3
	mov	dh,10h
	int	10h
	mov	bp,offset sheep2
	mov	dh,13h
	int	10h
	mov	bp,offset sheep1
	mov	dh,16h
	int	10h
	mov	ah,02h
	mov	dx,0922h
	int	10h
	mov	cx,1
	mov	ah,0Ah
	mov	al,1Eh
	int	10h
	mov	ah,02h
	mov	dh,0Ch
	int	10h
	mov	ah,0Ah
	int	10h
	mov	ah,02h
	mov	dh,0Fh
	int	10h
	mov	ah,0Ah
	int	10h
	mov	ah,02h
	mov	dh,12h
	int	10h
	mov	ah,0Ah
	int	10h
	mov	ah,02h
	mov	dh,15h
	int	10h
	mov	ah,0Ah
	int	10h	

	mov	ah,02h
	mov	dh,0Bh
	int	10h
	mov	al,1Fh
	mov	ah,0Ah
	int	10h
	mov	ah,02h
	mov	dh,0Eh
	int	10h
	mov	ah,0Ah
	int	10h
	mov	ah,02h
	mov	dh,11h
	int	10h
	mov	ah,0Ah
	int	10h
	mov	ah,02h
	mov	dh,14h
	int	10h
	mov	ah,0ah
	int	10h
	mov	ah,02h
	mov	dh,17h
	int	10h
	mov	ah,0Ah
	int	10h

ret
;;****	obr wrDAta data parametrs****;;
_obr1:
	push ds
	push cs
	pop ds
	push	ax
	push	bx
	push	cx
	push	dx

	test	ax, 00000010b
	jnz	_ndo
	jmp	_endo
_ndo:
	mov	ax, 2		
	int	33h		
	
	shr	cx, 3	
	mov	ax,dx
	mov	dl,14
	div	dl
	mov	dl,al
	mov	dh,0
	
	cmp	cx,22h
	je	_nd
	jmp	_endo
_nd:
	cmp	dx,09h
	jae	_nd1
	jmp	_endo
_nd1:
	cmp	dx,17h
	ja	_endo
	mov	bl,3
	mov	ax,dx
	div	bl
	cmp	ah,1
	je	_endo
	sub	al,bl
	mov	bl,al
	xor	bh,bh
	mov	cl,masp[bx]
	cmp	ah,0
	jne	_sub
	
	cmp	cl,maxp[bx]
	je	_endo
	
	inc	cl
	mov	masp[bx],cl
	pop	dx
	pop	cx
	push	cx
	push	dx
	push	bx

	mov	ax,dx
	mov	dl,14
	div	dl
	mov	dl,al
	mov	dh,0
	inc	dl
	jmp	_endo1
_sub:
	cmp	cl,minp[bx]
	je	_endo
	
	dec	cl
	mov	masp[bx],cl
	pop	dx
	pop	cx
	push	cx
	push	dx
	push	bx

	mov	ax,dx
	mov	dl,14
	div	dl
	mov	dl,al
	mov	dh,0
	dec	dl
_endo1:
	shr	cx,3
	mov	ah,02h
	mov	dh,dl
	mov	dl,cl
	xor	bh,bh
	int	10h

	pop	bx
	mov	al,masp[bx]
	add	al,30h
	cmp	al,3ah
	jne	_na
	mov	al,'a'
_na:
	mov	bl,4
	xor	bh,bh
	mov	ah,0Ah
	mov	cx,1
	int	10h
_endo:	

	mov	ax, 1		
	int	33h	
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	retf
	
;!!!!!!!!!!!!!!
ObrRasstS:

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	
	push	cx
	push	dx
	mov	al , 01h
	mov	bh , 0
	mov	ah , 13h
	mov	cx , 80
	mov	dl , 0
	mov	dh , 1
	lea	bp , clean
	int	10h
	pop	dx
	pop	cx
	;mov	cx , 80
	;mov	dl , 0
	;mov	dh , 1
	;call	wrClean 
	mov	x1 , cx
	mov	y1 , dx
	cmp	cx , rightBord1f
	jg	mm
	cmp	dx , topBord
	jl	uff
	cmp	dx , bottomBord
	jg	mm
	
	
	mov	x1 , cx
	mov	y1 , dx
	call	calcPlaceShip
	mov	ax , 02h
	int	33h
	cmp	fh4 , 1
	jne	g
	mov	ok , 0
	call calcCorrectHor4
	cmp	ok , 1
	jne	uncor
	call drawKillMy
	add	x , 1	
	call drawKillMy
	add	x , 1	
	call drawKillMy
	add	x , 1	
	call drawKillMy
	mov	fh4 , 0
	sub	hNship , 4
	sub	hship4 , 1
	jmp	uff
g:
	cmp	fv4 , 1
	jne	gg
	mov	ok , 0
	call calcCorrectVert4
	cmp	ok , 1
	jne	uncor
	call drawKillMy
	add	y , 1	
	call drawKillMy
	add	y , 1	
	call drawKillMy
	add	y , 1	
	call drawKillMy	
	mov	fv4 , 0
	sub	hNship , 4
	sub	hship4 , 1
	jmp	uff
gg:
	cmp	fh3 , 1
	jne	g3
	mov	ok , 0
	call calcCorrectHor3
	cmp	ok , 1
	jne	uncor
	call drawKillMy
	add	x , 1	
	call drawKillMy
	add	x , 1	
	call drawKillMy
	mov	fh3 , 0
	sub	hNship , 3
	sub	hship3 , 1
	jmp	uff
g3:
	cmp	fv3 , 1
	jne	gg3
	mov	ok , 0
	call calcCorrectVert3
	cmp	ok , 1
	jne	uncor
	call drawKillMy
	add	y , 1	
	call drawKillMy
	add	y , 1	
	call drawKillMy
	mov	fv3 , 0
	sub	hNship , 3
	sub	hship3 , 1
	jmp	uff
gg3:
	cmp	fh2 , 1
	jne	g2
	mov	ok , 0
	call calcCorrectHor2
	cmp	ok , 1
	jne	uncor
	call drawKillMy
	add	x , 1	
	call drawKillMy
	mov	fh2 , 0
	sub	hNship , 2
	sub	hship2 , 1
	jmp	uff
g2:
	cmp	fv2 , 1
	jne	gg2
	mov	ok , 0
	call calcCorrectVert2
	cmp	ok , 1
	jne	uncor
	call drawKillMy
	add	y , 1	
	call drawKillMy
	mov	fv2 , 0
	sub	hNship , 2
	sub	hship2 , 1
	jmp	uff
gg2:
	cmp	f1 , 1
	jne	mm
	mov	ok , 0
	call calcCorrect1
	cmp	ok , 1
	jne	uncor
	call drawKillMy
	mov	f1 , 0
	sub	hNship , 1
	sub	hship1 , 1
	jmp	uff	
mm:
	
	cmp	x1 , 560
	jl	uff
	cmp	y1 , 56
	jg	noGB
	mov	okGB , 1
	jmp	uff
noGB:
	cmp	y1 , 84
	jg	noFinn
	mov	okFin , 1
	jmp	uff
noFinn:
	cmp	y1 , 112
	jg	noRS
	mov	okRS , 1
	jmp	uff
noRS:
	cmp	y1 , 140
	jg	no4v
	cmp	hship4 , 0
	jle	uff
	mov	fv4 , 1
	mov	fh4 , 0
	mov	fv3 , 0
	mov	fh3 , 0
	mov	fv2 , 0
	mov	fh2 , 0
	mov	f1 , 0
	jmp	uff
no4v:	
	cmp	y1 , 168
	jg	no4h
	cmp	hship4 , 0
	jle	uff
	mov	fv4 , 0
	mov	fh4 , 1
	mov	fv3 , 0
	mov	fh3 , 0
	mov	fv2 , 0
	mov	fh2 , 0
	mov	f1 , 0 
	jmp	uff
no4h:
	cmp	y1 , 196
	jg	no3v
	cmp	hship3 , 0
	jle	uff
	mov	fv4 , 0
	mov	fh4 , 0
	mov	fv3 , 1
	mov	fh3 , 0
	mov	fv2 , 0
	mov	fh2 , 0
	mov	f1 , 0
	jmp	uff
no3v:
	cmp	y1 , 224
	jg	no3h
	cmp	hship3 , 0
	jle	uff
	mov	fv4 , 0
	mov	fh4 , 0
	mov	fv3 , 0
	mov	fh3 , 1
	mov	fv2 , 0
	mov	fh2 , 0
	mov	f1 , 0
	jmp	uff
no3h:
	cmp	y1 , 252
	jg	no2v
	cmp	hship2 , 0
	jle	uff
	mov	fv4 , 0
	mov	fh4 , 0
	mov	fv3 , 0
	mov	fh3 , 0
	mov	fv2 , 1
	mov	fh2 , 0
	mov	f1 , 0
	jmp	uff
no2v:
	cmp	y1 , 280
	jg	no2h
	cmp	hship2 , 0
	jle	uff
	mov	fv4 , 0
	mov	fh4 , 0
	mov	fv3 , 0
	mov	fh3 , 0
	mov	fv2 , 0
	mov	fh2 , 1
	mov	f1 , 0
	jmp	uff
no2h:
	cmp	y1 , 308
	jg	no11
	cmp	hship1 , 0
	jle	uff
	mov	fv4 , 0
	mov	fh4 , 0
	mov	fv3 , 0
	mov	fh3 , 0
	mov	fv2 , 0
	mov	fh2 , 0
	mov	f1 , 1
	jmp	uff
no11:
	cmp	y1 , 336
	jg	uff
	cmp	hNship , 0
	jne	uncor
	mov	okRD , 1
	jmp	uff
uncor:
	call	wrErrMsg
uff:
	mov	ax , 01h
	int	33h

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
retf

	;@@@@@@
Game:
push	ds
push	cs
pop		ds
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	cmp	cx,rightBord2f
	jg	mmg
	cmp	dx,topBord
	jl	uffg
	cmp	dx,bottomBord
	jg	mmg
	cmp	cx,leftBord2f
	jl	mmg

	cmp	myHod,1
	jne	uffg

	mov	fyes,1
	mov	myHod,0
	mov	x1,cx
	mov	y1,dx
	jmp	uffg


	jmp	uffg

mmg:
	cmp	cx,560
	jl	uffg
	cmp	dx,56
	jg	noGBg
	mov	okGB,1
	jmp	uff
noGBg:
	cmp	dx,84
	jg	uffg
	mov	okFin,1
	jmp	uffg
uffg:
	mov	ax,01h
	int	33h
	pop		ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
retf
;@@@@@@

intun:
;Timer uninstall
     xor      ax,ax
     mov      es,ax
     mov      si, offset Int_08h_old
     mov          di, 8h*4
     cli
     movsw
     movsw
     sti
	ret
end	_start