
; User Interface
;
; Draws user interface.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.

; DATA
ui_border           db 0
ui_border_sizeX     db 2
ui_border_sizeY     db 2

; game field position
; (2nd field will draw with 40 cols offset)
ui_border_offsetYX  dw 0108h

ui_user_selfName_len  db 6
ui_user_selfName_str  db 'NoName          '

ui_user_enemyName_len db 6
ui_user_enemyName_str db 'NoName          '


; Draw user interface.
; Main proc, calls other rendering procedures.

ui_render proc
    call ui_render_border
    call ui_shipCount
    call ui_ships
    call ui_tmp_ships
    ;call ui_testFont
    call ui_userNames
    call ui_attacks
    ret
ui_render endp

ui_attacks proc
	mov ax, ui_border_offsetYX
	mov bl, ui_border_sizeX
	mov bh, ui_border_sizeY
	add bx, ax
	add bx, 40
	
	; ATTACK
	
	lea si, ship_attack
	mov cx, 100
	ui_attacks_attacks:
	push bx
		mov dx, [si]
		cmp dx, 0
		je ui_attacks_attacks_next
			add dx, bx
			
			mov ah, 2   ; set pos
			xor bx, bx
			int 10h
			mov ah, 0ah   ; draw
			mov al, 6
			mov cx, 1
			int 10h
    ui_attacks_attacks_next:
    pop bx
	loop ui_attacks_attacks
	
	; MISS
	
	lea si, ship_miss
	mov cx, 100
	ui_attacks_miss:
	push bx
		mov dx, [si]
		cmp dx, 0
		je ui_attacks_miss_next
			add dx, bx
			
			mov ah, 2   ; set pos
			xor bx, bx
			int 10h
			mov ah, 0ah   ; draw
			mov al, 4
			mov cx, 1
			int 10h
    ui_attacks_miss_next:
    pop bx
	loop ui_attacks_miss
	
	
	ret
ui_attacks endp

ui_userNames proc
	xor cx, cx
	
	mov dx, 0319h
	mov ah, 2
	int 10h
	
	lea si, ui_user_selfName_str
	mov cl, ui_user_selfName_len
	cmp cl, 0
	je ui_userNames_enemy
	
	ui_userNames_self_loop:
		mov dl, [si]
		mov ah, 2
		int 21h
		
		inc si
	loop ui_userNames_self_loop
	
	ui_userNames_enemy:
		; enemy
		mov dx, 0341h
		mov ah, 2
		int 10h
		
		lea si, ui_user_enemyName_str
		mov cl, ui_user_enemyName_len
		cmp cl, 0
		je ui_userNames_exit
		
		ui_userNames_enemy_loop:
			mov dl, [si]
			mov ah, 2
			int 21h
			
			inc si
		loop ui_userNames_enemy_loop
		
	ui_userNames_exit:
		ret
ui_userNames endp


; Test font.
; Print font set.
; DOES NOT USE IN PRODUCTION

ui_testFont proc
    xor bh, bh
    xor al, al
    mov cx, 10h
    ui_testFont_loop:
        mov dl, cl  ; x
        push cx
        mov cx, 10h
        ui_testFont_loop_loop:
            mov dh, cl  ; y
            push cx
            
                mov ah, 2   ; set pos
                int 10h
                
                mov ah, 0ah   ; draw
                mov cx, 1
                int 10h
            
            pop cx
            inc al
        loop ui_testFont_loop_loop
        pop cx
    loop ui_testFont_loop
    
    ret
ui_testFont endp


; Interface borders. 
; Draw two game fields: self and enemy's.

ui_render_border proc
    mov dx, ui_border_offsetYX
    call ui_render_field
    
    mov dx, ui_border_offsetYX
    add dx, 40   ; + 40 cols (half of window's width)
    call ui_render_field
    
    ret
ui_render_border endp


; Show ships' count
;

ui_shipCount proc
    
    ; Self
    mov dx, 0201h
    mov cx, 4
    lea si, ship_self_counts
    
    ui_shipCount_loop_self:
    push cx
        ; count
        push cx
            xor bx, bx
            mov ah, 2
            int 10h
            mov ah, 0ah
            mov al, [si]
            add al, '0'
            mov cx, 1
            int 10h
        pop cx
        inc dx
        
        ; cube lines
        ui_shipCount_loop_self_ship:
        push cx
        inc dx
            xor bx, bx
            mov ah, 2
            int 10h
            mov ax, 0a05h
            mov cx, 1
            int 10h
        pop cx
        loop ui_shipCount_loop_self_ship
    add dh, 2
    inc si
    mov dl, 1
    pop cx
    loop ui_shipCount_loop_self
    
    ; Enemy
    mov dx, 0229h
    mov cx, 4
    lea si, ship_enemy_counts
    
    ui_shipCount_loop_enemy:
    push cx
        ; count
        push cx
            xor bx, bx
            mov ah, 2
            int 10h
            mov ah, 0ah
            mov al, [si]
            add al, '0'
            mov cx, 1
            int 10h
        pop cx
        inc dx
        
        ; cube lines
        ui_shipCount_loop_enemy_ship:
        push cx
        inc dx
            xor bx, bx
            mov ah, 2
            int 10h
            mov ax, 0a05h
            mov cx, 1
            int 10h
        pop cx
        loop ui_shipCount_loop_enemy_ship
    add dh, 2
    inc si
    mov dl, 29h
    pop cx
    loop ui_shipCount_loop_enemy
    
    ret
ui_shipCount endp


; Draw game field.
; Draw in pseudo graphic game field.
;
; ui_border_sizeX - X size
; ui_border_sizeY - Y size
; dh - Y window offset
; dl - X window offset

ui_render_field proc
    
    ; Draw |
    ;      |
    ;      |
    
    push dx
        xor cx, cx
        mov cl, ui_border_sizeY
        ui_render_field_loopY_left:
            push cx
            inc dh
                xor bh, bh  ; video mode
                mov ah, 2   ; set pos
                int 10h
                
                mov al, 0   ; draw al char
                mov ah, 0ah
                mov cx, 1
                int 10h
            pop cx
        loop ui_render_field_loopY_left
    pop dx

    ; Draw ------
    
    push dx
        xor cx, cx
        mov cl, ui_border_sizeX
        ui_render_field_loopX_top:
            push cx
            inc dl
                xor bh, bh  ; video mode
                mov ah, 2   ; set pos
                int 10h
                
                mov al, 1   ; draw al char
                mov ah, 0ah
                mov cx, 1
                int 10h
            pop cx
        loop ui_render_field_loopX_top
    pop dx
    
    ; Draw
    ;     |  |  |
    ;   --+--+--+
    ;     |  |  |
    ;   --+--+--+
    
    mov bx, dx      ; save yx
    xor cx, cx
    mov cl, ui_border_sizeX  ; times
    ui_render_field_loopX:
        push cx
        inc dl
        mov dh, bh
        mov cl, ui_border_sizeY
        ui_render_field_loopY:
            push cx
            push ax
            push bx
            inc dh
                
                xor bh, bh  ; video mode
                mov ah, 2   ; set pos
                int 10h
                
                mov al, 2   ; draw al char
                mov ah, 0ah
                mov cx, 1
                int 10h
            pop bx
            pop ax
            pop cx
        loop ui_render_field_loopY
        pop cx
    loop ui_render_field_loopX
    
    ret
    
ui_render_field endp


; Draw ships.
; Render for ship_self.

ui_ships proc
    xor cx, cx
    mov cl, ship_self_count
    
    ; If ship-set is empty.
    cmp cl, 0
    je ui_ships_exit
    
    lea si, ship_self
    push cs
    pop  ds
    
    xor bx, bx  ; video mode
    
    shl cl, 4   ; 4 cells
    ui_ships_loop:
    push cx
        lodsw
        mov dx, ax
        
        cmp dx, 0
        je ui_ships_loop_next
        
            xor ax, ax
            mov ah, 2   ; set pos
            int 10h

            mov al, 5   ; draw al char
            mov ah, 0ah
            mov cx, 1
            int 10h
            
        ui_ships_loop_next:
    pop cx
    loop ui_ships_loop
    
    ui_ships_exit:
        ret
ui_ships endp

ui_tmp_ships proc
    xor cx, cx
    mov cl, game_tmp_shipDone
    
    ; If ship is empty.
    cmp cl, 0
    je ui_tmp_ships_exit
    
    lea si, game_tmp_shipPos
    push cs
    pop  ds
    
    xor bx, bx  ; video mode
    
    ui_tmp_ships_loop:
    push cx
        lodsw
        mov dx, ax
        
        xor ax, ax
        mov ah, 2   ; set pos
        int 10h

        mov al, 6   ; draw al char
        mov ah, 0ah
        mov cx, 1
        int 10h
    pop cx
    loop ui_tmp_ships_loop
    
    ui_tmp_ships_exit:
        ret
ui_tmp_ships endp
