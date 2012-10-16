
; Click
;
; Click events.
; It's part of SeaWars game.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.


; Select - which of action
; will runs on this click.

click_route proc
    ; get click pos
    mov dl, mouse_status_position_x
    mov dh, mouse_status_position_y
    
    ; Which zone were clicked?
    ; Zones:
    ;	- My Name;
    ;   - Self game field;
    ;   - Enemy's game field;
    ;   - My ships.
    
    
    ; ANY STAGE
    ; My Name
        cmp dh, 3
        jne click_route_notName
        cmp dl, 19h
        jl click_route_notName
        cmp dl, 23h
        jg click_route_notName
        ; ACTION
        call click_route_changeName
        jmp click_route_exit
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;;  STAGE 10h
    ;;
    click_route_notName:
    ; Self field
        mov ax, ui_border_offsetYX
        mov bl, ui_border_sizeX
        mov bh, ui_border_sizeY
        add bx, ax
        
        cmp dl, al  ; left
        jle click_route_not_self
        cmp dl, bl  ; right
        jg click_route_not_self
        cmp dh, ah  ; top
        jle click_route_not_self
        cmp dh, bh  ; bottom
        jg click_route_not_self
        cmp game_stage, 10h
        jne click_route_not_self
        
        ; ACTION
        call click_route_selfField
        jmp click_route_exit
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;;  STAGE 0F4h
    ;;
    
    click_route_not_self:
    ; Enemy's field
        mov ax, ui_border_offsetYX
        mov bl, ui_border_sizeX
        mov bh, ui_border_sizeY
        add bx, ax
        add bx, 40
        add ax, 40
        
        cmp dl, al  ; left
        jle click_route_not_enemy
        cmp dl, bl  ; right
        jg click_route_not_enemy
        cmp dh, ah  ; top
        jle click_route_not_enemy
        cmp dh, bh  ; bottom
        jg click_route_not_enemy
        cmp game_stage, 0F4h
        jne click_route_not_enemy
        cmp action_fight, 1
        jne click_route_not_enemy
        
        ; ACTION
        call click_route_enemyField
        jmp click_route_exit
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;;  STAGE 00h
    ;;
    
    click_route_not_enemy:
    ; My ships
        cmp dl, 1    ; left
        jl click_route_not_ships
        cmp dl, 8    ; right
        jg click_route_not_ships
        cmp dh, 1    ; top
        jl click_route_not_ships
        cmp dh, 0ah  ; bottom
        jg click_route_not_ships
        cmp game_stage, 00h
        jne click_route_not_ships
        
        ; ACTION
        call click_route_selectShipType
        jmp click_route_exit
        
    click_route_not_ships:
    
        jmp click_route_exit
        
    click_route_exit:
    
    ret
click_route endp

click_route_selfField proc
    ; Get mouse pos
    mov dh, mouse_status_position_y
    mov dl, mouse_status_position_x
    
    push dx
    call ship_isFieldFree
    pop dx
    
    ; If cell is not free.
    cmp ax, 0
    je click_route_selfField_exit
    
    push dx
    call ship_addShipCell
    pop dx
    
    xor bx, bx
    mov ah, 2       ; set pos
    int 10h
    
    mov al, 6       ; ship char
    mov ah, 0ah     ; draw
    mov cx, 1
    int 10h
    
    click_route_selfField_exit:
    ret
click_route_selfField endp


; STAGE 00h
;
; Select ship type.
; How much cells we need.
;
; 00h -> 10h -> 00h
;         \---> 20h

click_route_selectShipType proc
    mov game_stage, 10h
    
    cmp dh, 2
    jne click_route_selectShipType_3
    ; 4 cells
        ; limit reached !
        cmp ship_self_4_count, 0
        jne click_route_selectShipType_ok4
            jmp click_route_selectShipType_exit
        click_route_selectShipType_ok4:
        
        ;
        mov game_tmp_shipSize, 4
        
        mov dx, offset game_message_shipSize
        call game_message
        
        
        mov dx, 000bh
        xor bx, bx
        mov ah, 2       ; set pos
        int 10h
        
        mov cx, 1
        mov dx, 000bh
        mov al, '4'
        mov ah, 0ah
        int 10h
        
        mov game_tmp_shipSize, 4
        
        ret
    click_route_selectShipType_3:
    cmp dh, 4
    jne click_route_selectShipType_2
    ; 3 cells
        ; limit reached !
        cmp ship_self_3_count, 0
        jne click_route_selectShipType_ok3
            jmp click_route_selectShipType_exit
        click_route_selectShipType_ok3:
        
        ;
        mov game_tmp_shipSize, 3
        
        mov dx, offset game_message_shipSize
        call game_message
        
        
        mov dx, 000bh
        xor bx, bx
        mov ah, 2       ; set pos
        int 10h
        
        mov cx, 1
        mov dx, 000bh
        mov al, '3'
        mov ah, 0ah
        int 10h
        
        mov game_tmp_shipSize, 3
        
        ret
    click_route_selectShipType_2:
    cmp dh, 6
    jne click_route_selectShipType_1
    ; 2 cells
        ; limit reached !
        cmp ship_self_2_count, 0
        je click_route_selectShipType_exit
        
        ;
        mov game_tmp_shipSize, 2
        
        mov dx, offset game_message_shipSize
        call game_message
        
        
        mov dx, 000bh
        xor bx, bx
        mov ah, 2       ; set pos
        int 10h
        
        mov cx, 1
        mov dx, 000bh
        mov al, '2'
        mov ah, 0ah
        int 10h
        
        mov game_tmp_shipSize, 2
        
        ret
    click_route_selectShipType_1:
    cmp dh, 8
    jne click_route_selectShipType_exit
    ; 1 cell
        ; limit reached !
        cmp ship_self_1_count, 0
        je click_route_selectShipType_exit
        
        ;
        mov game_tmp_shipSize, 1
        
        mov dx, offset game_message_shipSize
        call game_message
        
        
        mov dx, 000bh
        xor bx, bx
        mov ah, 2       ; set pos
        int 10h
        
        mov cx, 1
        mov dx, 000bh
        mov al, '1'
        mov ah, 0ah
        int 10h
        
        mov game_tmp_shipSize, 1
        
        ret
    click_route_selectShipType_exit:
        mov game_stage, 00h
        ret
click_route_selectShipType endp

click_flushStatus proc
    ret
click_flushStatus endp


click_route_changeName proc
	xor cx, cx
	mov dx, 0319h
	mov ah, 2
	int 10h
	
	mov cl, ui_user_selfName_len
	cmp cl, 0
	je click_route_changeName_newName
	
	; Clean up
	click_route_changeName_loop:
		mov dl, 20h
		mov ah, 2
		int 21h
		
		inc si
	loop click_route_changeName_loop
	
	mov ui_user_selfName_len, 0
	
	lea si, ui_user_selfName_str
	
	; Make new name
	click_route_changeName_newName:
		call kbd_shiftKey ; Done when enter pressed
		cmp al, 1ch
		je click_route_changeName_exit
		
		cmp al, 0
		je click_route_changeName_newName ; 0 byte means empty kbd
		
		
		cmp al, 10h
		jl click_route_changeName_newName
		cmp al, 19h
		jg click_route_changeName_newName_not1L
			; 1st kbd line (qwerty...)
			push si
			lea si, kbd_keyChars1
			sub al, 10h 
			xor ah, ah
			add si, ax
			mov al, [si]
			pop si
			jmp click_route_changeName_newName_saveChar
		click_route_changeName_newName_not1L:
		
		
		cmp al, 1eh
		jl click_route_changeName_newName
		cmp al, 26h
		jg click_route_changeName_newName_not2L
			; 2nd kbd line (asdf...)
			push si
			lea si, kbd_keyChars2
			sub al, 1eh 
			xor ah, ah
			add si, ax
			mov al, [si]
			pop si
			jmp click_route_changeName_newName_saveChar
		click_route_changeName_newName_not2L:
		
		
		cmp al, 2ch
		jl click_route_changeName_newName
		cmp al, 32h
		jg click_route_changeName_newName
			; 3rd kbd line (zxc...)
			push si
			lea si, kbd_keyChars3
			sub al, 2ch 
			xor ah, ah
			add si, ax
			mov al, [si]
			pop si
		
		
		click_route_changeName_newName_saveChar:
			mov [si], al
			inc si
			inc ui_user_selfName_len
			mov bl, ui_user_selfName_len
			cmp bl, 10
			je click_route_changeName_exit ; 10 letters are enought
		
	jmp click_route_changeName_newName
		
	click_route_changeName_exit:
		; Push change name command to buffer.
		mov al, 0b1h	; command code
		call serial_alToBuf
		mov al, ui_user_selfName_len
		call serial_alToBuf
		
		xor cx, cx
		mov cl, ui_user_selfName_len
		lea si, ui_user_selfName_str
		
		cmp cl, 0
		je click_route_changeName_pushStr_end
		
		click_route_changeName_pushStr:
			mov al, [si]
			call serial_alToBuf
			inc si
		loop click_route_changeName_pushStr
		click_route_changeName_pushStr_end:
	
		ret
click_route_changeName endp


click_route_enemyField proc
    ; Lock
    mov action_fight, 0
    
    ; Get YX without field offset.
	mov bx, ui_border_offsetYX
	add bx, 40
	
	mov action_attack_cell, dx
	
	sub dx, bx ; get "local" Y, X
	
		push dx
			; Log
			mov ax, dx
			call util_alToBuf
			lea dx, util_buf
			call game_debug
        pop dx
    
    ; AGRH
    ;call serial_bufFlush
    
    ; Send
	mov al, 0C0h
	call serial_alToBuf
	mov al, dl
	call serial_alToBuf
	mov al, dh
	call serial_alToBuf
	
	call serial_send
    
	ret
click_route_enemyField endp
