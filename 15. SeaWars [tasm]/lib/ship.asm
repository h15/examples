
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
; di    - direction 0 - for north
;                   1 - for east
;                   2 - for south
;                   3 - for west
; L     - live
; X pos - X position
;
; Is NULL when it's dead.

ship_self_count db 0
ship_self dw 100 dup(0)
ship_enemy dw 100 dup(0)

; Check field's cell for free.
; @param dx - YX
; @return ax

ship_isFieldFree proc
    mov si, offset ship_self
    sub si, 2
    
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
            cmp cx, 0
            je ship_isFieldFree_loop
            
            dec cx
            ship_isFieldFree_loop_second:
            push cx
                cmp ax, 0 ; north
                jne ship_isFieldFree_loop_second_not_north
                    sub bx, 0100h
                    jmp ship_isFieldFree_loop_second_cmp
                ship_isFieldFree_loop_second_not_north:
                cmp ax, 1 ; east
                jne ship_isFieldFree_loop_second_not_east
                    add bx, 0001h
                    jmp ship_isFieldFree_loop_second_cmp
                ship_isFieldFree_loop_second_not_east:
                cmp ax, 2 ; south
                jne ship_isFieldFree_loop_second_not_south
                    add bx, 0100h
                    jmp ship_isFieldFree_loop_second_cmp
                ship_isFieldFree_loop_second_not_south:
                    sub bx, 0001h; west
                    jmp ship_isFieldFree_loop_second_cmp
                
                ; Compare this cell.
                ship_isFieldFree_loop_second_cmp:
                    cmp bx, dx
                    jne ship_isFieldFree_loop
                    ; Equal!
                        mov ax, 0
                        ret
                
            pop cx
            loop ship_isFieldFree_loop_second
            
            
    jmp ship_isFieldFree_loop
    
    ship_isFieldFree_exit:
    
    mov ax, 1 ; FREE
    ret
ship_isFieldFree endp


; Add cell. Set ship cell by cell.
; @param dx - YX

; game_tmp_shipSize   db 0
; game_tmp_shipDone   db 0
; game_tmp_shipPos    dw 4 dup(0)

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
    mul bl, 2
    add si, bl
    mov [si], dx ; moved!
    mov bl, game_tmp_shipDone
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
    ; Generate ship from pos array.
    call ship_posToShip
    
    ret
ship_movTmpToArray endp


; Make ship from pos array.
; @return dx - ship
;
; +-+--+-----+--+-+-----+ 
; |s|si|  Y  |di|L|  X  |  DWORD
; +-+--+-----+--+-+-----+

ship_posToShip proc
    mov cx, game_tmp_shipSize
    mov si, offset game_tmp_shipPos
    
    ; Just one cell.
    cmp cx, 1
    jne ship_posToShip_multicell
    ; All right! Just do it.
        mov dx, [si]                ; set YX
        or dx, 0000000000100000b    ; set Live bit
        ret
    
    ; Many cells
    ship_posToShip_multicell:
    ; Test: All cells in one line.
    
        ship_posToShip_multicell_lineTest:
            ship_posToShip_multicell_lineTest_X:
                push cx
                ship_posToShip_multicell_TestXLoop: ; Test X-line. FOR x in cells.
                push cx
                    ; IF cell is last in list of cells (first in loop).
                    cmp cx, game_tmp_shipSize
                    jne ship_posToShip_multicell_TestXLoop_notFirst
                        ; First cell
                        push si
                            mul cx, 2
                            add si, cx
                            sub si, 2
                            mov ax, [si]
                            mov bx, [si - 2]
                            
                            ; IF first and next cell's x-pos are equal.
                            cmp al, bl
                            jne ship_posToShip_multicell_TestXLoop_firstFAIL
                                ; all fine - move to next cell
                                ; CONTINUE
                                jmp ship_posToShip_multicell_TestXLoop_firstFAIL_end
                            
                            ; ELSE
                            ship_posToShip_multicell_TestXLoop_firstFAIL:
                                ; not horizontal - goto vertacal test.
                                ; GOTO Y TEST
                                pop si
                                pop cx
                                jmp ship_posToShip_multicell_lineTest_Y
                            
                            ; ENDIF
                            ship_posToShip_multicell_TestXLoop_firstFAIL_end:
                            
                        pop si
                        jmp ship_posToShip_multicell_TestXLoop_end
                    
                    ; ELSE
                    ship_posToShip_multicell_TestXLoop_notFirst:
                        ; Other cells
                        push si
                            mul cx, 2
                            add si, cx
                            sub si, 2
                            mov ax, [si]
                            mov bx, [si + 2]
                            
                            ; IF first and next cell's x-pos are equal.
                            cmp al, bl
                            jne ship_posToShip_multicell_TestXLoop_firstFAIL
                                ; all fine - move to next cell
                                jmp ship_posToShip_multicell_TestXLoop_firstFAIL_end
                            
                            ; ELSE
                            ship_posToShip_multicell_TestXLoop_firstFAIL:
                                ; not horizontal - goto vertacal test.
                                pop si
                                pop cx
                                jmp ship_posToShip_multicell_lineTest_Y
                            
                            ; ENDIF
                            ship_posToShip_multicell_TestXLoop_firstFAIL_end:
                            
                        pop si
                        jmp ship_posToShip_multicell_TestXLoop_end
                    
                    ship_posToShip_multicell_TestXLoop_end:
                pop cx
                loop ship_posToShip_multicell_TestXLoop
                pop cx
            
                ; It's horizontal.
                mov dx, 0000000001100000b    ; set direction bit & live bit
                ; Goto solid test.
                jmp ship_posToShip_solidTest
            
            ship_posToShip_multicell_lineTest_Y:
                push cx
                ship_posToShip_multicell_TestYLoop: ; Test Y-line. FOR y in cells.
                push cx
                    ; IF cell is last in list of cells (first in loop).
                    cmp cx, game_tmp_shipSize
                    jne ship_posToShip_multicell_TestYLoop_notFirst
                        ; First cell
                        push si
                            mul cx, 2
                            add si, cx
                            sub si, 2
                            mov ax, [si]
                            mov bx, [si - 2]
                            
                            ; IF first and next cell's y-pos are equal.
                            cmp ah, bh
                            jne ship_posToShip_multicell_TestYLoop_firstFAIL
                                ; all fine - move to next cell
                                ; CONTINUE
                                jmp ship_posToShip_multicell_TestYLoop_firstFAIL_end
                            
                            ; ELSE
                            ship_posToShip_multicell_TestYLoop_firstFAIL:
                                ; not horizontal & not vertacal - FAIL.
                                ; return 0
                                pop si
                                pop cx
                                mov dx, 0
                                ret
                            
                            ; ENDIF
                            ship_posToShip_multicell_TestYLoop_firstFAIL_end:
                            
                        pop si
                        jmp ship_posToShip_multicell_TestYLoop_end
                    
                    ; ELSE
                    ship_posToShip_multicell_TestYLoop_notFirst:
                        ; Other cells
                        push si
                            mul cx, 2
                            add si, cx
                            sub si, 2
                            mov ax, [si]
                            mov bx, [si + 2]
                            
                            ; IF first and next cell's y-pos are equal.
                            cmp ah, bh
                            jne ship_posToShip_multicell_TestYLoop_firstFAIL
                                ; all fine - move to next cell
                                jmp ship_posToShip_multicell_TestYLoop_firstFAIL_end
                            
                            ; ELSE
                            ship_posToShip_multicell_TestYLoop_firstFAIL:
                                ; not horizontal & not vertacal - FAIL.
                                ; return 0
                                pop si
                                pop cx
                                mov dx, 0
                                ret
                            
                            ; ENDIF
                            ship_posToShip_multicell_TestYLoop_firstFAIL_end:
                            
                        pop si
                        jmp ship_posToShip_multicell_TestYLoop_end
                    
                    ship_posToShip_multicell_TestYLoop_end:
                pop cx
                loop ship_posToShip_multicell_TestYLoop
                pop cx
                
                ; It's vertical.
                mov dx, 0000000010100000b    ; set direction bit & live bit
                ; Goto solid test.
                jmp ship_posToShip_solidTest
                
        ; This ship is horizontal (or vertical) - move to solid test.
        ship_posToShip_solidTest:
            push cx
                ; Find first cell (smallest).
                xor bx, bx ; It will be saves in bx.
                ship_posToShip_solidTest_loop:
                push cx
                    push si
                        mul cx, 2
                        add si, cx
                        sub si, 2
                        mov ax, [si]
                        mov bx, [si - 2]
                pop cx
                loop ship_posToShip_solidTest_loop
            pop cx
    
    ret
ship_posToShip endp
