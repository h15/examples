
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
