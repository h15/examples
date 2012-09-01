
; Game
;
; Game's logic.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.

; DATA
game_seconds    dw 0
game_curTime    dw 0
game_stage      db 0
; game_stage:
; 00 -> select ship type
; 10 -> select ship position
game_tmp_shipSize   db 0
game_tmp_shipDone   db 0
game_tmp_shipPos    dw 4 dup(0)
; 20 -> check ("show OK button")
; 30 -> OK pressed

game_message_shipSize db 'Ship type: $'


; Main Loop.
; Will runs all time.
; Escape from loop by Esc press.

game_mainloop proc
    game_LOOP:
        
        ; One time per second.
        ;
        mov ax, game_curTime
        mov bx, game_seconds
        cmp ax, bx
        je game_mainloop_second_skip
            mov game_curTime, bx
            ; Action.
            call ui_render
        game_mainloop_second_skip:
        
        ; Exit if ESC pressed.
        ;
        call kbd_shiftKey
        cmp al, 1
        jne game_LOOP
    game_exit:
        ret
game_mainloop endp

    ;~ proc in_range_1
        ;~ cmp dl, field_size
        ;~ jge in_range_1_exit
        ;~ cmp dh, field_size
        ;~ jge in_range_1_exit
        ;~ 
        ;~ ret
        ;~ 
    ;~ in_range_1_exit:
        ;~ mov bad_click, 1
        ;~ ret
    ;~ endp in_range_1
    ;~ 
    ;~ proc chk_click
        ;~ call in_range_1
        ;~ call ship_around
        ;~ call border_around
        ;~ call is_need_accept
        ;~ 
        ;~ ret
    ;~ endp chk_click
    ;~ 
    ;~ proc ship_around
        ;~ push dx
    ;~ ;;
    ;~ ;;    Look around
    ;~ ;;
        ;~ mov cx, 2
        ;~ 
        ;~ cmp dh, 0
        ;~ je ship_around_dh_not_0
            ;~ inc cx
            ;~ dec dh
        ;~ ship_around_dh_not_0:
        ;~ 
        ;~ cmp dl, 0
        ;~ je ship_around_dl_not_0
            ;~ dec dl
        ;~ ship_around_dl_not_0:
        ;~ 
        ;~ call dl_dh_2_si
            ;~ 
        ;~ ship_around_loop2:
            ;~ push cx
            ;~ 
            ;~ mov cx, 2
            ;~ 
            ;~ cmp dl, 0
            ;~ je ship_around_dl_not_0_2
                ;~ inc cx
            ;~ ship_around_dl_not_0_2:
            ;~ 
            ;~ ship_around_loop:
                ;~ cmp [si], 0505h
                ;~ jne ship_around_not_here
                    ;~ mov bad_click, 1
                    ;~ pop cx
                    ;~ pop dx
                    ;~ ret
                ;~ ship_around_not_here:
                ;~ 
                ;~ add si, 2
                ;~ 
            ;~ loop ship_around_loop
                ;~ 
            ;~ inc dh
            ;~ call dl_dh_2_si
            ;~ 
            ;~ pop cx    
        ;~ loop ship_around_loop2
        ;~ 
        ;~ pop dx
        ;~ 
        ;~ ret
    ;~ endp ship_around
    ;~ 
    ;~ proc is_need_accept
        ;~ cmp need_accept, 1
        ;~ jne is_need_accept_1
            ;~ mov bad_click,1
        ;~ is_need_accept_1:
        ;~ ret
    ;~ endp is_need_accept
    ;~ ;;
    ;~ ;;    ON GOOD LEFT CLICK
    ;~ ;;
    ;~ proc chg_map
        ;~ mov cell_around, 0
    ;~ ;;
    ;~ ;;    Is it part of ship?
    ;~ ;;
        ;~ mov al, size_of_ship
        ;~ cmp cell_count, al
        ;~ jne chg_map_its_not_first_cell
            ;~ jmp chg_map_its_first_cell
        ;~ chg_map_its_not_first_cell:
        ;~ ;;
        ;~ ;;    Look around
        ;~ ;;
            ;~ cmp dh, 0
            ;~ je chg_map_on_top
                ;~ dec dh
                ;~ call dl_dh_2_si
            ;~ 
                ;~ cmp dl, 0
                ;~ je chg_map_on_left
                    ;~ sub si, 2
                    ;~ 
                    ;~ cmp [si], 05b0h
                    ;~ jne chg_map_not_top_left
                        ;~ ret
                    ;~ chg_map_not_top_left:
                    ;~ 
                    ;~ add si, 2
                ;~ chg_map_on_left:
                ;~ 
                ;~ cmp [si], 05b0h
                ;~ jne chg_map_not_top_center
                    ;~ inc cell_around
                ;~ chg_map_not_top_center:
                ;~ 
                ;~ add si, 2
                ;~ 
                ;~ cmp [si], 05b0h
                ;~ jne chg_map_not_top_right
                    ;~ ret
                ;~ chg_map_not_top_right:
                ;~ 
                ;~ inc dh
            ;~ chg_map_on_top:
            ;~ 
            ;~ call dl_dh_2_si
            ;~ 
            ;~ cmp dl, 0
            ;~ je chg_map_on_left2
                ;~ sub si, 2
                ;~ cmp [si], 05b0h
                ;~ jne chg_map_not_middle_left
                    ;~ inc cell_around
                ;~ chg_map_not_middle_left:
                ;~ 
                ;~ add si, 2
            ;~ chg_map_on_left2:
            ;~ 
            ;~ cmp [si], 05b0h
            ;~ jne chg_map_not_middle_center
                ;~ ret
            ;~ chg_map_not_middle_center:
            ;~ 
            ;~ add si, 2
            ;~ 
            ;~ cmp [si], 05b0h
            ;~ jne chg_map_not_middle_right
                ;~ inc cell_around
            ;~ chg_map_not_middle_right:
            ;~ 
            ;~ inc dh
            ;~ call dl_dh_2_si
            ;~ 
            ;~ cmp dl, 0
            ;~ je chg_map_on_left3
                ;~ sub si, 2
                ;~ cmp [si], 05b0h
                ;~ jne chg_map_not_bottom_left
                    ;~ ret
                ;~ chg_map_not_bottom_left:
                ;~ 
                ;~ add si, 2
            ;~ chg_map_on_left3:
            ;~ 
            ;~ cmp [si], 05b0h
            ;~ jne chg_map_not_bottom_center
                ;~ inc cell_around
            ;~ chg_map_not_bottom_center:
            ;~ 
            ;~ add si, 2
            ;~ 
            ;~ cmp [si], 05b0h
            ;~ jne chg_map_not_bottom_right
                ;~ ret
            ;~ chg_map_not_bottom_right:
            ;~ 
            ;~ cmp cell_around, 1
            ;~ je chg_map_good_cell
                ;~ ret
            ;~ chg_map_good_cell:
            ;~ 
            ;~ dec dh
            ;~ 
        ;~ chg_map_its_first_cell:
        ;~ 
        ;~ call dl_dh_2_si
    ;~ ;;
        ;~ cmp cell_count, 0
        ;~ je chg_map_count_is_null
        ;~ ;;
        ;~ ;;    Draw this f*cking pixel
        ;~ ;;
            ;~ mov [si], 05b0h
        ;~ ;;
            ;~ mov al, cell_count
            ;~ dec al
            ;~ mov cell_count, al
            ;~ 
            ;~ cmp cell_count, 0
            ;~ jne chg_map_need_accept
                ;~ mov need_accept, 1
                ;~ call accept
                ;~ call no_highlight_ship_counter
            ;~ chg_map_need_accept:
        ;~ 
        ;~ chg_map_count_is_null:
        ;~ 
        ;~ call draw_iface
        ;~ 
        ;~ ret
    ;~ endp chg_map
    ;~ 
    ;~ proc dl_dh_2_si
        ;~ mov al, dh
        ;~ mov bl, field_size
        ;~ add bl, field_size
        ;~ mul bl
        ;~ add al, dl
        ;~ add al, dl
        ;~ xor ah, ah
        ;~ 
        ;~ lea si, map1
        ;~ add si, ax
        ;~ 
        ;~ ret
    ;~ endp dl_dh_2_si
    ;~ 
    ;~ proc accept
        ;~ push dx
        ;~ 
        ;~ mov ah, 2
        ;~ mov dx, 0c02h
        ;~ int 10h
        ;~ 
        ;~ mov ah, 9
        ;~ lea dx, print_need_accept
        ;~ int 21h
        ;~ 
        ;~ mov ah, 9h
        ;~ xor bh,bh
        ;~ mov al, 0fbh
        ;~ mov cx, 1
        ;~ mov bl, 2
        ;~ int 10h
        ;~ 
        ;~ pop dx
        ;~ ret
    ;~ endp accept
    ;~ 
    ;~ proc dec_ship_counter
        ;~ lea si, _1
        ;~ mov al, size_of_ship
        ;~ dec al 
        ;~ mov bl, 2
        ;~ mul bl
        ;~ xor ah, ah
        ;~ add si, ax
        ;~ 
    ;~ ;    inc si
        ;~ mov ax, [si]
        ;~ dec ax
        ;~ mov [si], ax
    ;~ 
        ;~ ret
    ;~ endp dec_ship_counter
