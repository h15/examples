
; Ship
;
; Ships data and logic.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.


; Data
ship_self_1_count   db 4
ship_self_2_count   db 2
ship_self_3_count   db 1
ship_self_4_count   db 0

ship_enemy_1_count  db 0
ship_enemy_2_count  db 1
ship_enemy_3_count  db 2
ship_enemy_4_count  db 4


; Ship format:
;   One ship is 2*dword (16*4 bytes).
;   byte,byte: Y,X
;
; Example:
;   push cs
;   pop ds
;   lea si, ship_self
;   lodsw
;   mov dx, ax ; <- get first cell

ship_self_count db 0
ship_self       dd 100 dup(0) ; 50 ships
ship_enemy      dd 100 dup(0) ; 50 ships


; Check field's cell for free.
; @param dx - YX
; @return ax

ship_isFieldFree proc
    push cs
    pop ds
    lea si, ship_self
    
    xor cx, cx
    mov cl, ship_self_count
    
    ; If ship-set is empty.
    cmp cl, 0
    je ship_isFieldFree_exit
    
    ; For all cells.
    ship_isFieldFree_loop:
        lodsw
        
        ; If ax==dx : return false;
        cmp ax, dx
        jne ship_isFieldFree_loop_end
            mov ax, 0 ; false
            ret
        ship_isFieldFree_loop_end:
    loop ship_isFieldFree_loop
    
    ship_isFieldFree_exit:
        mov ax, 1 ; true
        ret
ship_isFieldFree endp


; Add cell. Set ship cell by cell.
; @param dx - YX
;
; Temp ship:
;   game_tmp_shipSize   db 0
;   game_tmp_shipDone   db 0
;   game_tmp_shipPos    dw 4 dup(0)

ship_addShipCell proc
    mov bh, game_tmp_shipSize
    mov bl, game_tmp_shipDone
    
    cmp bh, bl
    jne ship_addShipCell_addCell
        call ship_movTmpToArray     ; all done
        jmp ship_addShipCell_exit
    ship_addShipCell_addCell:
    
    ; add cell
    mov si, offset game_tmp_shipPos
    
    push bx
        xor bh, bh
        add bl, bl
        add si, bx
    pop bx
    
    mov [si], dx ; moved!
    inc bl
    mov game_tmp_shipDone, bl
    
    cmp bh, bl
    jne ship_addShipCell_exit
        call ship_movTmpToArray     ; all done
        jmp ship_addShipCell_exit
    
    ship_addShipCell_exit:
    ret
ship_addShipCell endp


; When ship cell was selected - add it to ship's array.
;
; ship_tmp_shipPos array
;   -> new ship
;       -> PUSH(ship -> ship_self) 

ship_movTmpToArray proc
    push cs
    pop  ds
    push cs
    pop  es
    lea si, game_tmp_shipPos
    lea di, ship_self
    
    xor cx, cx
    mov cl, ship_self_count
    shl cx, 2
    add di, cx
    
    xor cx, cx
    mov cl, game_tmp_shipSize
    
    ; Ship -> array ship_self
    ship_movTmpToArray_loop:
        lodsw
        stosw
    loop ship_movTmpToArray_loop
    
    ; Clean up
    mov game_tmp_shipSize, 0
    mov game_tmp_shipDone, 0
    mov ax, 0
    mov cx, 4
    lea di, game_tmp_shipPos
    
    ship_movTmpToArray_loop2:
        stosw
    loop ship_movTmpToArray_loop2
    
    ; ship_self_count++
    mov bl, ship_self_count
    inc bl
    mov ship_self_count, bl
    
    mov game_stage, 00h
    
    ret
ship_movTmpToArray endp
