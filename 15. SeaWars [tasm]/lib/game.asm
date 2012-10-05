
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

game_message_longEmptyString    db '                                                                                $';
game_message_longEmptyString40  db '                                        $';
game_message_shipSize           db 'Ship type: $'
game_message_shipSticksBorders  db 'ERROR: Too much ships sticks border!$';
game_message_shipAfloat         db 'Ship afloat!$';
game_message_shipWrongStruct    db 'Ship must be solid and straight!$'

game_log_line db 13h

; Main Loop.
; Will runs all time.
; Escape from loop by Esc press.

game_mainloop proc
    game_LOOP:
        
        ; One time per game "second".
        ;
        mov ax, game_curTime
        mov bx, game_seconds
        cmp ax, bx
        je game_mainloop_second_skip
            mov game_curTime, bx
            
            lea dx, game_message_longEmptyString40
            call game_log
            ; Action.
            call ui_render
            call com_action_recvCmd
            call com_action_sendSync
        game_mainloop_second_skip:
        
        ; Exit if ESC pressed.
        ;
        call kbd_shiftKey
        cmp al, 1
        jne game_LOOP
    game_exit:
        ret
game_mainloop endp


; Print message to user
; @param dx - offset of the message

game_message proc
    push bx
    push ax
    
    push dx
    xor dx, dx  ; pos
    xor bh, bh  ; video mode
    mov ah, 2   ; set pos func
    int 10h
    
    ; clean up
    lea dx, game_message_longEmptyString
    mov ah, 9
    int 21h
    
    xor dx, dx  ; pos
    xor bh, bh  ; video mode
    mov ah, 2   ; set pos func
    int 10h
    pop dx
    
    ; write message
    mov ah, 9
    int 21h
    
    pop ax
    pop bx
    ret
game_message endp

game_log proc
    push bx
    push ax
    push dx
    
    mov al, game_log_line
    inc al
    
    cmp al, 48
    jne game_log_skip
        mov al, 14h
    game_log_skip:
    
    mov game_log_line, al
    
    mov dl, 28h  ; pos
    mov dh, game_log_line
    xor bh, bh  ; video mode
    mov ah, 2   ; set pos func
    int 10h
    
    ; clean up
    lea dx, game_message_longEmptyString40
    mov ah, 9
    int 21h
    
    mov dl, 28h  ; pos
    mov dh, game_log_line
    xor bh, bh  ; video mode
    mov ah, 2   ; set pos func
    int 10h
    pop dx
    
    ; write message
    mov ah, 9
    int 21h
    
    pop ax
    pop bx
    ret
game_log endp
