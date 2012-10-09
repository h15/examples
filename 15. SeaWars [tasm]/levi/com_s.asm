.code

Ser_Ini proc near 
	push ax ; ��������� �������� 
	push dx 
	push bx 
	push es 
	in al,21h ; IMR 1-�� ���������� ���������� 
	or al,08h ; ��������� ���������� IRQ3 �� COM1 ;;;;
	out 21h,al 
	mov al,0Bh 
	mov ah,35h 
	int 21h ; ����� ������ Int 0Bh � es:bx 
	mov Ser_ip,bx ; � ��������� ��� 
	mov Ser_cs,es 
	mov al,0Bh 
	mov dx,offset Ser_int 
	push ds 
	mov bx,cs 
	mov ds,bx 
	mov ah,25h 
	int 21h ; ���������� Int 0Bh = ds:dx 
	pop ds 
	pop es 
	pop bx 
	cli ; ��������� ���������� 
	in al,21h ; IMR 1-�� ����������� ���������� 
	and al,not 08h 
	out 21h,al ; ��������� ���������� �� COM1 
	mov dx,2FBh ; ������� ���������� ������ 
	in al,dx 
	or al,80h ; ���������� ��� DLAB 
	out dx,al 
	mov dx,2F8h 
	mov al,0Bh 
	out dx,al ; ������� ���� ��� �������� 1200 ��� 
	inc dx 
	mov al,0 
	out dx,al ; ������� ���� �������� 
	mov dx,2FBh ; ������� ���������� ������ 
	mov al,00011111b ; 8 ���, 2 ����-����, ��� �������� 
	out dx,al 
	mov dx,2F9h ; ������� ���������� ���������� 
	mov al,1 ; ��������� ���������� �� ������ 
	out dx,al 
	nop ; � ����-���� ��������� 
	nop 
	mov dx,2FCh ; ������� ���������� ������� 
	mov al,00001011b ; ���������� DTR, RTS � OUT2 
	out dx,al 
	sti ; ��������� ���������� 
	mov dx,2F8h ; ������� ������ 
	in al,dx ; �������� ����� ������ 
	pop dx 
	pop ax 
ret 
Ser_Ini endp 
;������������������������������������������������������������ͻ 
;� ������������ ���������� ����� COM1. � 
;������������������������������������������������������������ͼ 
Ser_Rst proc near 
	push ax ; ��������� �������� 
	push dx 
Wait_Free: 
	mov dx,2FDh ; ������� ��������� ����� 
	in al,dx 
	jmp short $+2 ; �������� �������� 
	test al,60h ; �������� ��������? 
	jz Wait_Free ; ����, ���� ��� 
	mov dx,2F9h ; ������� ���������� ���������� 
	mov al,0 ; ��������� ���������� 
	out dx,al 
	jmp short $+2 ; ��� ��������... 
	jmp short $+2 
	mov dx,2FCh ; ������� ���������� ������� 
	mov al,00000011b ; ������������ DTR � RTS 
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
	int 21h ; ������������ ������ Int 0Ch 
	pop ds 
	pop bx 
	cli ; ������ ���������� 
	in al,21h ; ������ ����� ���������� 
	jmp short $+2 
	or al,10h ; ��������� IRQ4 
	out 21h,al 
	sti ; ���������� ���������� 
	pop dx 
	pop ax 
ret 
Ser_Rst endp 
;������������������������������������������������������������ͻ 
;� ������������ ��������� ���������� �� COM1. � 
;������������������������������������������������������������ͼ 
Ser_Int proc far 
	push ax 
	push dx 
	push ds 
	movpp	ds,cs 
	mov dx,2FAh ; ������� ������������� ���������� 
	in al,dx 
	mov Int_Sts,al; �������� ��� ���������� 
	test al,1 ; ���� ���������� ����������? 
	jz Is_Int ; �� 
	pop Save_ds ; ���, �������� ���������� 
	pop dx ; ������� ����������� Int 0Ch 
	pop ax 
	push Ser_cs 
	push Ser_ip 
	push Save_ds 
	pop ds 
ret ; ������� ������� 
Is_Int: 
	mov al,63h ; ������� EOI ��� IRQ4 
	out 20h,al ; � 1-� ���������� ���������� 
	test Int_Sts,4 ; ���������� �� ������? 
	jnz Read_Char ; �� 
No_Char: 
	sti ; ���, ��������� ���������� 
	jmp Int_Ret ; � ��������� ��������� Int 0Ch 
Read_Char: 
	mov dx,2FDh ; ������� ��������� ����� 
	in al,dx 
	and al,2 
	mov Overrun,al; ovvrrun<>0, ���� ���� ������ ������� 
	mov dx,2F8h ; ������� ������ 
	in al,dx ; ������ ������ 
;or al,al ; ���� ������ ����, 
;jz No_Char ; �� ���������� ��� 
	push bx 
	mov ah,Overrun 
	or ah,ah ; ���������� ������ �������? 
	jz Save_Char ; ��� 
	mov ah,al ; ��, 
;mov al,7 ; �������� ��� �� ������ (07h) 
Save_Char: 
	mov bx,Src_ptr; ������� ������ � ����� 
	mov [bx],al 
	inc Src_ptr ; � ��������� �������� 
	inc bx 
	cmp bx,offset Src_ptr-2 ; ���� ����� ������ 
	jb Ser_Int_1 
	mov Src_ptr,offset Source ; �� "�����������" �� ������ 
Ser_Int_1: 
	cmp Count,Buf_Size ; ����� �����? 
	jae Ser_Int_2 ; �� 
	inc Count ; ���, ������ ������ 
Ser_Int_2: 
	or ah,ah ; ���� ���� ������ ������� 
	jz Ser_Int_3 
	mov al,ah ; �� ������� � ����� ��� ������ 
	xor ah,ah 
	jmp short Save_Char 
Ser_Int_3: 
	pop bx 
	sti ; ��������� ���������� 
Int_Ret: 
	pop ds 
	pop dx 
	pop ax 
iret 
Ser_Int endp 
;������������������������������������������������������������ͻ 
;� ������������ ������ ������� AL � ����. � 
;� ��� ������ ���������� CF=1, ����� CF=0. � 
;������������������������������������������������������������ͼ 
Out_Chr proc near 
	push ax 
	push cx 
	push dx 
	mov ah,al 
	sub cx,cx 
Wait_Line: 
	mov dx,2FDh ; ������� ��������� ����� 
	in al,dx 
	test al,20h ; ���� ����� � ��������? 
	jnz Output ; �� 
	jmp short $+2 
	jmp short $+2 
	loop Wait_Line ; ���, ���� 
	pop dx 
	pop cx 
	pop ax 
	stc ; ��� ���������� ����� 
ret 
Output: 
	mov al,ah 
	mov dx,2F8h ; ������� ������ 
	jmp short $+2 
	out dx,al ; ������� ������ 
	pop dx 
	pop cx 
	pop ax 
	clc ; ���������� ������� 
ret 
Out_Chr endp 
;������������������������������������������������������������ͻ 
;� ������������ ����� ������� �� ����� � AL. � 
;� ���� ����� ����, ���������� CF=1, ����� CF=0. � 

Get_Chr proc near 
	cmp Count,0 ; ����� ����? 
	jne loc_1729 ; ��� 
	stc ; ��, ������� �� ������ 
ret 
loc_1729: 
	push si 
	cli ; �������� ���������� 
	mov si,Src_ptr 
	sub si,Count 
	cmp si,offset Source 
	jae loc_1730 
	add si,Buf_Size 
loc_1730: 
	mov al,[si] ; ������� ������ 
	dec Count ; � �������� ������ 
	sti ; ���������� ���������� 
	pop si 
	clc ; � ���������� ������� 
ret 
Get_Chr endp 

