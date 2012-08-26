
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
;
; +-+--+-----+--+-+-----+ 
; |s|si|  Y  |di|L|  X  |  DWORD
; +-+--+-----+--+-+-----+
;
; s     - side (self / enemy)
; si    - cells in ship + 1 (size)
; Y     - Y position
; di    - direction 0 - for south
;                   1 - for east
;                   2 - for north
;                   3 - for west
; L     - live
; X pos - X position
;
; Is NULL when it's dead.

ship_self dw 100 dup(0)
ship_enemy dw 100 dup(0)

; Check field's cell for free.
; @param dx - YX
; @return ax

ship_isFieldFree proc
    mov si, offset ship_self
    sub si, 2
    mov ax, 1
    
    ship_isFieldFree_loop:
        add si, 2
        mov bx, [si]
        cmp bx, 0
        je ship_isFieldFree_exit
        ; Check is here:
            mov cx, bx
            mov ax, bx
            
            and cx, 0110000000000000b ; size
            shr cx, 13
            and ax, 0000000011000000b ; direction
            shr ax, 6
            and bx, 0001111100011111b ; YX
            ; first cell
                cmp bx, dx
                jne ship_isFieldFree_loop
                ; Equal!
                    mov ax, 0
                    ret
            ; second and more
            
            
            
    jmp ship_isFieldFree_loop
    
    ship_isFieldFree_exit:
    ret
ship_isFieldFree endp
