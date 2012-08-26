
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
    
    ; Which zone was clicked?
    ; Zones:
    ;   - Self game field;
    ;   - Enemy's game field;
    ;   - My ships.
    
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
    
    click_route_not_self:
    ; Enemy's field
        mov ax, ui_border_offsetYX
        mov bl, ui_border_sizeX
        mov bh, ui_border_sizeY
        add bx, ax
        add bx, 40
        
        cmp dl, al  ; left
        jle click_route_not_enemy
        cmp dl, bl  ; right
        jg click_route_not_enemy
        cmp dh, ah  ; top
        jle click_route_not_enemy
        cmp dh, bh  ; bottom
        jg click_route_not_enemy
        cmp game_stage, 50h
        jne click_route_not_enemy
        
        ; ACTION
        call click_route_enemyField
        jmp click_route_exit
    
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
    
    
    xor bx, bx
    mov ah, 2       ; set pos
    int 10h
    
    mov al, 5       ; ship char
    mov ah, 0ah     ; draw
    mov cx, 1
    int 10h
    
    ret
click_route_selfField endp

click_route_enemyField proc
    ; inside
    xor bx, bx
    mov ah, 2       ; set pos
    int 10h
    
    mov al, 4       ; miss char
    mov ah, 0ah     ; draw
    mov cx, 1
    int 10h
    
    ret
click_route_enemyField endp

click_route_selectShipType proc
    mov game_stage, 10h
    
    cmp dh, 2
    jne click_route_selectShipType_3
    ; 4 cells
        mov game_shipSize, 4
        
        mov dx, 0
        xor bx, bx
        mov ah, 2       ; set pos
        int 10h
        
        mov ah, 9
        mov dx, offset game_message_shipSize
        int 21h
        
        mov cx, 1
        mov dx, 000bh
        mov al, '4'
        mov ah, 0ah
        int 10h
        
        ret
    click_route_selectShipType_3:
    cmp dh, 4
    jne click_route_selectShipType_2
    ; 3 cells
        mov game_shipSize, 3
        
        mov dx, 0
        xor bx, bx
        mov ah, 2       ; set pos
        int 10h
        
        mov ah, 9
        mov dx, offset game_message_shipSize
        int 21h
        
        mov cx, 1
        mov dx, 000bh
        mov al, '3'
        mov ah, 0ah
        int 10h
        
        ret
    click_route_selectShipType_2:
    cmp dh, 6
    jne click_route_selectShipType_1
    ; 2 cells
        mov game_shipSize, 2
        
        mov dx, 0
        xor bx, bx
        mov ah, 2       ; set pos
        int 10h
        
        mov ah, 9
        mov dx, offset game_message_shipSize
        int 21h
        
        mov cx, 1
        mov dx, 000bh
        mov al, '2'
        mov ah, 0ah
        int 10h
        
        ret
    click_route_selectShipType_1:
    cmp dh, 8
    jne click_route_selectShipType_exit
    ; 1 cell
        mov game_shipSize, 1
        
        mov dx, 0
        xor bx, bx
        mov ah, 2       ; set pos
        int 10h
        
        mov ah, 9
        mov dx, offset game_message_shipSize
        int 21h
        
        mov cx, 1
        mov dx, 000bh
        mov al, '1'
        mov ah, 0ah
        int 10h
        
        ret
    click_route_selectShipType_exit:
        mov game_stage, 00h
        ret
click_route_selectShipType endp

click_flushStatus proc
    ret
click_flushStatus endp
