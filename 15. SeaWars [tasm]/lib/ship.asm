
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
ship_self_cells     db 0
ship_enemy_cells    db 0

ship_self_counts:
    ship_self_4_count   db 22
    ship_self_3_count   db 22
    ship_self_2_count   db 22
    ship_self_1_count   db 22

ship_enemy_counts:
    ship_enemy_4_count  db 0
    ship_enemy_3_count  db 0
    ship_enemy_2_count  db 0
    ship_enemy_1_count  db 0


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

ship_self_alive	db 100 dup(0) ; how much cells are living
ship_self       dd 200 dup(0) ; 50 ships
ship_enemy      dd 200 dup(0) ; 50 ships

ship_attack 	dw 100 dup(0) ; YX
ship_miss 		dw 100 dup(0) ; YX

ship_selfAttack 	dw 100 dup(0) ; YX
ship_selfMiss 		dw 100 dup(0) ; YX

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
    push dx
    call ship_check_cellArea
    pop dx
    cmp ax, 0
    je ship_addShipCell_exit
    
    ;
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
    ; If tests failed - clean up and get out.
    call ship_check
    cmp ax, 1
    je ship_movTmpToArray_checked
    
        lea dx, game_message_shipWrongStruct
        call game_message
        
        jmp ship_movTmpToArray_cleanup
    
    ship_movTmpToArray_checked:
    
    push cs
    pop  ds
    push cs
    pop  es
    lea si, game_tmp_shipPos
    lea di, ship_self
    
    xor cx, cx
    mov cl, ship_self_count
    shl cx, 3
    add di, cx
    
    xor cx, cx
    mov cl, game_tmp_shipSize
    
    ;
    ; Cell Count++
    ;
    push ax
        mov al, ship_self_cells
        add al, cl
        mov ship_self_cells, al
        mov ship_enemy_cells, al
    pop ax
    
    ; Ship -> array ship_self
    ship_movTmpToArray_loop:
        lodsw
        stosw
    loop ship_movTmpToArray_loop
    
    ; --ship_self_*_count
    push ax
    push si
        mov ax, 4
        sub al, game_tmp_shipSize
        lea si, ship_self_counts
        add si, ax
        mov ax, [si]
        dec ax
        mov [si], ax
    pop si
    pop ax
    
    ; Save size.
    xor bx, bx
    mov bl, ship_self_count
    lea si, ship_self_alive
    add si, bx
    mov bl, game_tmp_shipSize
    mov [si], bl
    
    
    ; DEBUG
    push ax
		mov ax, 0
		call util_alToBuf
		lea dx, util_buf
		call game_log
		
		mov al, bl
		mov bl, ship_self_count
		mov ah, bl
		
		call util_alToBuf
		lea dx, util_buf
		call game_log
    pop ax
    
    
    ; ship_self_count++
    mov bl, ship_self_count
    inc bl
    mov ship_self_count, bl
    
    ; Print message to user
    lea dx, game_message_shipAfloat
    call game_message
    
    ship_movTmpToArray_cleanup:
        ; Clean up
        mov game_tmp_shipSize, 0
        mov game_tmp_shipDone, 0
        mov ax, 0
        mov cx, 4
        lea di, game_tmp_shipPos
        
        ship_movTmpToArray_loop2:
            stosw
        loop ship_movTmpToArray_loop2
        
        mov game_stage, 00h
    
        call ship_movTmpToArray_afterHook
    
    ret
ship_movTmpToArray endp


; Check cell's area.
; Does space enought?
; @param dx - YX
; @return ax - 0|1 - false|true

ship_check_cellArea proc
    xor cx, cx
    mov cl, ship_self_count
        
    ; If ship-set is empty.
    cmp cl, 0
    je ship_check_cellArea_exit
    
    lea si, ship_self
    push cs
    pop ds
    
    shl cx, 4   ; 4 cells
    ship_check_cellArea_loop:
    push cx
        lodsw
        sub ax, dx
        
        ; dx - ax =
        ;
        ;  0101 | 0100 | 00ff
        ; ------+------+------
        ;  0001 |   *  | 0fff
        ; ------+------+------
        ;  ff01 | ff00 | feff
        
        cmp ax, 0101h
        je ship_check_cellArea_loop_tooClose
        cmp ax, 0100h
        je ship_check_cellArea_loop_tooClose
        cmp ax, 00ffh
        je ship_check_cellArea_loop_tooClose
        cmp ax, 0001h
        je ship_check_cellArea_loop_tooClose
        cmp ax, 0ffffh
        je ship_check_cellArea_loop_tooClose
        cmp ax, 0ff01h
        je ship_check_cellArea_loop_tooClose
        cmp ax, 0ff00h
        je ship_check_cellArea_loop_tooClose
        cmp ax, 0feffh
        je ship_check_cellArea_loop_tooClose
        
        jmp ship_check_cellArea_loop_normal
        ship_check_cellArea_loop_tooClose:
            pop cx      ; BAD
            mov ax, 0
            ret
        ship_check_cellArea_loop_normal:
    pop cx
    loop ship_check_cellArea_loop
    
    ship_check_cellArea_exit:
        mov ax, 1
        ret
ship_check_cellArea endp


; Check ship.
; Does it solid, does it in line.
; @return ax - 0|1 - false|true

ship_check proc
    xor cx, cx
    mov cl, game_tmp_shipSize
    lea si, game_tmp_shipPos
    
    ; Just one cell.
    cmp cx, 1
    jne ship_check_multicell
    ; All right! Just do it.
        mov ax, 1
        ret
    
    ; Many cells
    ship_check_multicell:
    ; Test: All cells in one line.
    
        ship_check_multicell_lineTest:
            ship_check_multicell_lineTest_X:
                push cx
                ship_check_multicell_TestXLoop: ; Test X-line. FOR x in cells.
                push cx
                    ; IF cell is last in list of cells (first in loop).
                    cmp cl, game_tmp_shipSize
                    jne ship_check_multicell_TestXLoop_notFirst
                        ; First cell
                        push si
                            add cx, cx
                            add si, cx
                            sub si, 2
                            mov ax, [si]
                            mov bx, [si - 2]
                            
                            ; IF first and next cell's x-pos are equal.
                            cmp al, bl
                            jne ship_check_multicell_TestXLoop_firstFAIL1
                                ; all fine - move to next cell
                                ; CONTINUE
                                jmp ship_check_multicell_TestXLoop_firstFAIL_end1
                            
                            ; ELSE
                            ship_check_multicell_TestXLoop_firstFAIL1:
                                ; not horizontal - goto vertacal test.
                                ; GOTO Y TEST
                                pop si
                                pop cx
                                pop cx
                                jmp ship_check_multicell_lineTest_Y
                            
                            ; ENDIF
                            ship_check_multicell_TestXLoop_firstFAIL_end1:
                            
                        pop si
                        jmp ship_check_multicell_TestXLoop_end
                    
                    ; ELSE
                    ship_check_multicell_TestXLoop_notFirst:
                        ; Other cells
                        push si
                            add cx, cx
                            add si, cx
                            sub si, 2
                            mov ax, [si]
                            mov bx, [si + 2]
                            
                            ; IF first and next cell's x-pos are equal.
                            cmp al, bl
                            jne ship_check_multicell_TestXLoop_firstFAIL2
                                ; all fine - move to next cell
                                jmp ship_check_multicell_TestXLoop_firstFAIL_end2
                            
                            ; ELSE
                            ship_check_multicell_TestXLoop_firstFAIL2:
                                ; not horizontal - goto vertacal test.
                                pop si
                                pop cx
                                pop cx
                                jmp ship_check_multicell_lineTest_Y
                            
                            ; ENDIF
                            ship_check_multicell_TestXLoop_firstFAIL_end2:
                            
                        pop si
                        jmp ship_check_multicell_TestXLoop_end
                    
                    ship_check_multicell_TestXLoop_end:
                pop cx
                loop ship_check_multicell_TestXLoop
                pop cx
            
                ; It's horizontal.
                ; Goto solid test.
                jmp ship_check_solidTest
            
            ship_check_multicell_lineTest_Y:
                push cx
                ship_check_multicell_TestYLoop: ; Test Y-line. FOR y in cells.
                push cx
                    ; IF cell is last in list of cells (first in loop).
                    cmp cl, game_tmp_shipSize
                    jne ship_check_multicell_TestYLoop_notFirst
                        ; First cell
                        push si
                            add cx, cx
                            add si, cx
                            sub si, 2
                            mov ax, [si]
                            mov bx, [si - 2]
                            
                            ; IF first and next cell's y-pos are equal.
                            cmp ah, bh
                            jne ship_check_multicell_TestYLoop_firstFAIL1
                                ; all fine - move to next cell
                                ; CONTINUE
                                jmp ship_check_multicell_TestYLoop_firstFAIL_end1
                            
                            ; ELSE
                            ship_check_multicell_TestYLoop_firstFAIL1:
                                ; not horizontal & not vertacal - FAIL.
                                ; return 0
                                pop si
                                pop cx
                                pop cx
                                mov ax, 0
                                ret
                            
                            ; ENDIF
                            ship_check_multicell_TestYLoop_firstFAIL_end1:
                            
                        pop si
                        jmp ship_check_multicell_TestYLoop_end
                    
                    ; ELSE
                    ship_check_multicell_TestYLoop_notFirst:
                        ; Other cells
                        push si
                            add cx, cx
                            add si, cx
                            sub si, 2
                            mov ax, [si]
                            mov bx, [si + 2]
                            
                            ; IF first and next cell's y-pos are equal.
                            cmp ah, bh
                            jne ship_check_multicell_TestYLoop_firstFAIL2
                                ; all fine - move to next cell
                                jmp ship_check_multicell_TestYLoop_firstFAIL_end2
                            
                            ; ELSE
                            ship_check_multicell_TestYLoop_firstFAIL2:
                                ; not horizontal & not vertacal - FAIL.
                                ; return 0
                                pop si
                                pop cx
                                pop cx
                                mov ax, 0
                                ret
                            
                            ; ENDIF
                            ship_check_multicell_TestYLoop_firstFAIL_end2:
                            
                        pop si
                        jmp ship_check_multicell_TestYLoop_end
                    
                    ship_check_multicell_TestYLoop_end:
                pop cx
                loop ship_check_multicell_TestYLoop
                pop cx
                
                ; It's vertical.
                ; Goto solid test.
                jmp ship_check_solidTest
                
        ; This ship is horizontal (or vertical) - move to solid test.
        ship_check_solidTest:
            push cx
                ; Find first cell (smallest).
                mov bx, 07f7fh ; MIN will be saved in bx.
                mov dx, 0000h  ; MAX will be saved in dx.
                
                ship_check_solidTest_loop:
                push cx
                    push si
                        shl cx, 1
                        add si, cx
                        sub si, 2
                        mov ax, [si]
                        
                        ; bx >= ax ? bx = ax : 1 for shipCells
                        cmp bx, ax
                        jl ship_check_solidTest_loop_greater
                            mov bx, ax
                        ship_check_solidTest_loop_greater:
                        
                        ; dx <= ax ? dx = ax : 1 for shipCells
                        cmp dx, ax
                        jg ship_check_solidTest_loop_less
                            mov dx, ax
                        ship_check_solidTest_loop_less:
                    pop si
                pop cx
                loop ship_check_solidTest_loop    
            pop cx ; restore SIZE
            
            ; Use only different parts
            cmp dl, bl
            jne ship_check_solidTest_X_eq
                ; If it's vertical - use Y
                shr dx, 8
                shr bx, 8
                jmp ship_check_solidTest_X_eq_end
            ship_check_solidTest_X_eq:
                ; If it's horizontal - use X
                xor dh, dh
                xor bh, bh
            ship_check_solidTest_X_eq_end:
            
            ; SIZE == 1 + MAX - MIN ; - solid condition
            sub dx, bx
            inc dx
            
            cmp cx, dx
            je ship_check_solidTest_isSolid
                ; not solid
                mov ax, 0
                ret
            ship_check_solidTest_isSolid:
        
    mov ax, 1
    ret
ship_check endp


; ship_movTmpToArray after-hook.
; Look around!

ship_movTmpToArray_afterHook proc
    ;
    ; Does all ships are installed?
    ;
    push cs
    pop ds
    lea si, ship_self_counts
    mov cx, 4
    ship_movTmpToArray_afterHook_loop:
        lodsb
        cmp al, 0
        jne ship_movTmpToArray_afterHook_notEmpty
    loop ship_movTmpToArray_afterHook_loop
        ; Ship set is empty
        mov game_stage, 20h
        
        call action_shipsAfloats
        ;call ship_checkBorderSticked
        ;call ui_showAcceptButton
    ship_movTmpToArray_afterHook_notEmpty:
    
    ret
ship_movTmpToArray_afterHook endp


; Only half of ships can stay
; near from border.
; @return ax - 0|1

ship_checkBorderSticked proc
    ; Counter
    xor bx, bx
    
    ; For ships
    xor cx, cx
    mov cl, ship_self_count
    
    push cx
    ship_checkBorderSticked_loop:
    push cx
    push si
        ; Get ship offset
        dec cx
        shl cx, 2
        add si, cx
        
        ; For current-ship's cells
        mov cx, 4
        ship_checkBorderSticked_loop_loop:
        push cx
            dec cx
            shl cx, 1
            add si, cx
            
            mov dx, [si]
            
            ; Self field
            mov ax, ui_border_offsetYX
            mov cl, ui_border_sizeX
            mov ch, ui_border_sizeY
            add cx, ax
            add ax, 0101h
            
            ; If one cell on border
            ; - does not necessary check other.
            cmp dl, al  ; left
            je ship_checkBorderSticked_onBorder
            cmp dl, cl  ; right
            je ship_checkBorderSticked_onBorder
            cmp dh, ah  ; top
            je ship_checkBorderSticked_onBorder
            cmp dh, ch  ; bottom
            je ship_checkBorderSticked_onBorder
        pop cx
        loop ship_checkBorderSticked_loop_loop
        ; Do "onBorder" code
        ; or skip it.
        jmp ship_checkBorderSticked_onBorder_end
        ship_checkBorderSticked_onBorder:
            pop cx
            inc bx
        ship_checkBorderSticked_onBorder_end:
    pop si
    pop cx
    loop ship_checkBorderSticked_loop
    pop cx
    
    ; 2*sticked > ship_self_count ?
    shl bx, 1
    cmp cx, bx
    jge ship_checkBorderSticked_exit
    
        lea dx, game_message_shipSticksBorders
        call game_message
        
        ; WIPE!!!
        ;;call game_wipe
    
    ship_checkBorderSticked_exit:
        ret
ship_checkBorderSticked endp
