.code

Ser_Ini proc near 
	push ax ; сохранить регистры 
	push dx 
	push bx 
	push es 
	in al,21h ; IMR 1-го контролера прерываний 
	or al,08h ; запретить прерывание IRQ3 от COM1 ;;;;
	out 21h,al 
	mov al,0Bh 
	mov ah,35h 
	int 21h ; вз€ть вектор Int 0Bh в es:bx 
	mov Ser_ip,bx ; и сохранить его 
	mov Ser_cs,es 
	mov al,0Bh 
	mov dx,offset Ser_int 
	push ds 
	mov bx,cs 
	mov ds,bx 
	mov ah,25h 
	int 21h ; установить Int 0Bh = ds:dx 
	pop ds 
	pop es 
	pop bx 
	cli ; запретить прерывани€ 
	in al,21h ; IMR 1-го контроллера прерываний 
	and al,not 08h 
	out 21h,al ; разрешить прерывани€ от COM1 
	mov dx,2FBh ; регистр управлени€ линией 
	in al,dx 
	or al,80h ; установить бит DLAB 
	out dx,al 
	mov dx,2F8h 
	mov al,0Bh 
	out dx,al ; младший байт дл€ скорости 1200 бод 
	inc dx 
	mov al,0 
	out dx,al ; старший байт скорости 
	mov dx,2FBh ; регистр управлени€ линией 
	mov al,00011111b ; 8 бит, 2 стоп-бита, без четности 
	out dx,al 
	mov dx,2F9h ; регистр разрешени€ прерываний 
	mov al,1 ; разрешить прерывани€ по приему 
	out dx,al 
	nop ; и чуть-чуть подождать 
	nop 
	mov dx,2FCh ; регистр управлени€ модемом 
	mov al,00001011b ; установить DTR, RTS и OUT2 
	out dx,al 
	sti ; разрешить прерывани€ 
	mov dx,2F8h ; регистр данных 
	in al,dx ; сбросить буфер приема 
	pop dx 
	pop ax 
ret 
Ser_Ini endp 
;…ЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌї 
;Ї ѕодпрограмма отключени€ стыка COM1. Ї 
;»ЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЉ 
Ser_Rst proc near 
	push ax ; сохранить регистры 
	push dx 
Wait_Free: 
	mov dx,2FDh ; регистр состо€ни€ линии 
	in al,dx 
	jmp short $+2 ; коротка€ задержка 
	test al,60h ; передача окончена? 
	jz Wait_Free ; ждем, если нет 
	mov dx,2F9h ; регистр разрешени€ прерываний 
	mov al,0 ; запретить прерывани€ 
	out dx,al 
	jmp short $+2 ; еще подождем... 
	jmp short $+2 
	mov dx,2FCh ; регистр управлени€ модемом 
	mov al,00000011b ; активировать DTR и RTS 
	out dx,al 
	jmp short $+2 
	jmp short $+2 
	push bx 
	mov al,0Bh 
	mov dx,Ser_ip 
	push ds 
	mov bx,Ser_cs 
	mov ds,bx 
	mov ah,25h 
	int 21h ; восстановить вектор Int 0Ch 
	pop ds 
	pop bx 
	cli ; запрет прерываний 
	in al,21h ; читать маску прерываний 
	jmp short $+2 
	or al,10h ; запретить IRQ4 
	out 21h,al 
	sti ; разрешение прерываний 
	pop dx 
	pop ax 
ret 
Ser_Rst endp 
;…ЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌї 
;Ї ѕодпрограмма обработки прерываний от COM1. Ї 
;»ЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЉ 
Ser_Int proc far 
	push ax 
	push dx 
	push ds 
	movpp	ds,cs 
	mov dx,2FAh ; регистр идентификации прерываний 
	in al,dx 
	mov Int_Sts,al; сохраним его содержимое 
	test al,1 ; есть отложенные прерывани€? 
	jz Is_Int ; да 
	pop Save_ds ; нет, передаем управление 
	pop dx ; старому обработчику Int 0Ch 
	pop ax 
	push Ser_cs 
	push Ser_ip 
	push Save_ds 
	pop ds 
ret ; длинный переход 
Is_Int: 
	mov al,63h ; послать EOI дл€ IRQ4 
	out 20h,al ; в 1-й контроллер прерываний 
	test Int_Sts,4 ; прерывание по приему? 
	jnz Read_Char ; да 
No_Char: 
	sti ; нет, разрешить прерывани€ 
	jmp Int_Ret ; и закончить обработку Int 0Ch 
Read_Char: 
	mov dx,2FDh ; регистр состо€ни€ линии 
	in al,dx 
	and al,2 
	mov Overrun,al; ovvrrun<>0, если была потер€ символа 
	mov dx,2F8h ; регистр данных 
	in al,dx ; вводим символ 
;or al,al ; если прин€т нуль, 
;jz No_Char ; то игнорируем его 
	push bx 
	mov ah,Overrun 
	or ah,ah ; предыдущий символ потер€н? 
	jz Save_Char ; нет 
	mov ah,al ; да, 
;mov al,7 ; замен€ем его на звонок (07h) 
Save_Char: 
	mov bx,Src_ptr; заносим символ в буфер 
	mov [bx],al 
	inc Src_ptr ; и обновл€ем счетчики 
	inc bx 
	cmp bx,offset Src_ptr-2 ; если конец буфера 
	jb Ser_Int_1 
	mov Src_ptr,offset Source ; то "зацикливаем" на начало 
Ser_Int_1: 
	cmp Count,Buf_Size ; буфер полон? 
	jae Ser_Int_2 ; да 
	inc Count ; нет, учесть символ 
Ser_Int_2: 
	or ah,ah ; если была потер€ символа 
	jz Ser_Int_3 
	mov al,ah ; то занести в буфер сам символ 
	xor ah,ah 
	jmp short Save_Char 
Ser_Int_3: 
	pop bx 
	sti ; разрешить прерывани€ 
Int_Ret: 
	pop ds 
	pop dx 
	pop ax 
iret 
Ser_Int endp 
;…ЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌї 
;Ї ѕодпрограмма вывода символа AL в порт. Ї 
;Ї ѕри ошибке возвращает CF=1, иначе CF=0. Ї 
;»ЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЉ 
Out_Chr proc near 
	push ax 
	push cx 
	push dx 
	mov ah,al 
	sub cx,cx 
Wait_Line: 
	mov dx,2FDh ; регистр состо€ни€ линии 
	in al,dx 
	test al,20h ; стык готов к передаче? 
	jnz Output ; да 
	jmp short $+2 
	jmp short $+2 
	loop Wait_Line ; нет, ждем 
	pop dx 
	pop cx 
	pop ax 
	stc ; нет готовности порта 
ret 
Output: 
	mov al,ah 
	mov dx,2F8h ; регистр данных 
	jmp short $+2 
	out dx,al ; вывести символ 
	pop dx 
	pop cx 
	pop ax 
	clc ; нормальный возврат 
ret 
Out_Chr endp 
;…ЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌЌї 
;Ї ѕодпрограмма ввода символа из порта в AL. Ї 
;Ї ≈сли буфер пуст, возвращает CF=1, иначе CF=0. Ї 

Get_Chr proc near 
	cmp Count,0 ; буфер пуст? 
	jne loc_1729 ; нет 
	stc ; да, возврат по ошибке 
ret 
loc_1729: 
	push si 
	cli ; запретим прерывани€ 
	mov si,Src_ptr 
	sub si,Count 
	cmp si,offset Source 
	jae loc_1730 
	add si,Buf_Size 
loc_1730: 
	mov al,[si] ; выберем символ 
	dec Count ; и уменьшим счечик 
	sti ; разрешение прерываний 
	pop si 
	clc ; и нормальный возврат 
ret 
Get_Chr endp 

