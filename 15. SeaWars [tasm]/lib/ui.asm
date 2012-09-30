
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
ui_border_sizeX     db 30
ui_border_sizeY     db 16

; game field position
; (2nd field will draw with 40 cols offset)
ui_border_offsetYX  dw 0108h


; Draw user interface.
; Main proc, calls other rendering procedures.

ui_render proc
    call ui_render_border
    call ui_shipCount
    call ui_ships
    ;call ui_testFont
    ret
ui_render endp


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
    mov si, offset ship_self_1_count
    
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
    mov si, offset ship_enemy_1_count
    
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
    lea si, ship_self
    
    ; FOR ship_self
    ui_ships_loop:
    push cx
    push si
        ; Get next ship.
        add cx, cx
        add si, cx
        sub si, 2
        mov ax, [si]
        
        ; Render this ship.
        call ui_ships_render
    pop si
    pop cx
    loop ui_ships_loop
    
    ret
ui_ships endp


; Render ship.
; @param ax - ship
;
; +-+--+-----+--+-+-----+ 
; |s|si|  Y  |di|L|  X  |  DWORD
; +-+--+-----+--+-+-----+

ui_ships_render proc
    mov bx, ax
    mov cx, bx
    
    and cx, 0110000000000000b ; size
    shr cx, 13
    and ax, 0000000011000000b ; direction
    shr ax, 6
    and bx, 0001111100011111b ; YX
    
    ui_ships_render_loop:
    push cx
    push ax
    push bx
        cmp ax, 0 ; north
        jne ui_ships_render_loop_not_north
            sub bx, 0100h
            jmp ui_ships_render_loop_draw
        ui_ships_render_loop_not_north:
        
        cmp ax, 1 ; east
        jne ui_ships_render_loop_not_east
            add bx, 0001h
            jmp ui_ships_render_loop_draw
        ui_ships_render_loop_not_east:
        
        cmp ax, 2 ; south
        jne ui_ships_render_loop_not_south
            add bx, 0100h
            jmp ui_ships_render_loop_draw
        ui_ships_render_loop_not_south:
        
            sub bx, 0001h; west
            jmp ui_ships_render_loop_draw
        
        ui_ships_render_loop_draw:
            mov dx, bx
            xor ax, ax
            xor bx, bx  ; video mode
            mov ah, 2   ; set pos
            int 10h

            mov al, 5   ; draw al char
            mov ah, 0ah
            mov cx, 1
            int 10h
            
        mov bx, dx
    pop bx
    pop ax
    pop cx
    loop ui_ships_render_loop
    
    ret
ui_ships_render endp
