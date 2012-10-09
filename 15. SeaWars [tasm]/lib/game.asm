
; Game
;
; Game's logic.
;
; Tasm file.
; Charset utf-8.
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



; Stages from proto description (game_stage=0FXh):
; 0 - запуск игры
; 1 - встретились и синхронизировались, мастер вводит и передает условия игры, слейв ждет
; 2 - начинаем расстановку
; 3 - мастер расставил корабли
; 4 - слейв расставил корабли, началась игра
; 5 - рестарт, после подтверждения слейва оба переходят в состояние 1
; 6 - сдаюсь , оба переходят в состояние 9
; 7 - гуд бай, отправитель выходит из игры. Соперник сидит и ждет(слейв) или шлет [AA](мастер)
;     до появления нового соперника или до выхода по команде своего игрока.
; 8 - ошибка протокола со стороны соперника, сообщение, ждать нажатия клавиши, переход в состояние 0 после получения ответа.
;     Принимающая сторона - сообщение, ждать нажатия клавиши, переход в состояние 0.
;     Неполучение ответа [8A] более чем за 60 тиков ошибкой не является, соперник может сомневаться в вашем [A8]
; 9 - партия окончена


game_message_longEmptyString    db '                                                                                $';
game_message_longEmptyString40  db '                                        $';
game_message_shipSize           db 'Ship type: $'
game_message_shipSticksBorders  db 'ERROR: Too much ships sticks border!$';
game_message_shipAfloat         db 'Ship afloat!$';
game_message_shipWrongStruct    db 'Ship must be solid and straight!$'

game_message_selectGameParams	db 'Define game params! (params splits by Enter)$'
game_message_waitGameParams		db 'Waiting for game params...$'

game_message_fieldSize 			db 'Input game field size [6-10]:$'
game_message_ship4				db 'Input count of 4-cells ships [0-1]:$'
game_message_ship3				db 'Input count of 3-cells ships [0-2]:$'
game_message_ship2				db 'Input count of 2-cells ships [0-5]:$'
game_message_ship1				db 'Input count of 1-cells ships [0-10]:$'

game_message_installYourShips	db 'Select good position for your ships!$'

game_message_fight				db 'Let`s battle begin!$'

game_message_hit				db 'Hit!$'
game_message_kill				db 'Dead!$'
game_message_miss				db 'Miss!$'

game_log_line db 13h

; Main Loop.
; Will runs all time.
; Escape from loop by Esc press.

game_mainloop proc
    game_LOOP:
        
        cmp game_stage, 0F1h
        jne game_LOOP_skip_stage_1
        cmp serial_type, 1
        jne game_LOOP_skip_stage_1
			call game_stage1
		game_LOOP_skip_stage_1:
        
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
            call action_dispatch
            ;call com_action_recvCmd
            ;call com_action_sendSync
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


; @param al - kbd key code 2 .. 0Bh
game_stage1 proc
	; Does key pressed ?
	cmp al, 2
	jl game_stage1_exit
	cmp al, 0bh
	jg game_stage1_exit
		
		; Get input
		
		; Key-code to cipher
		cmp al, 0Bh
		je game_stage1_zero
			dec al
			jmp game_stage1_zero_end
		game_stage1_zero:
			mov al, 0
		game_stage1_zero_end:
		
		; set vars
		cmp ui_border_sizeX, 6
		jge game_stage1_notField
			inc al
			mov ui_border_sizeX, al
			mov ui_border_sizeY, al
			dec al
			
			lea dx, game_message_ship4
            call game_message
            
			jmp game_stage1_exit
		game_stage1_notField:
		
		cmp ship_self_4_count, 22
		jne game_stage1_not4
			mov ship_self_4_count, al
			lea dx, game_message_ship3
            call game_message
			jmp game_stage1_exit
		game_stage1_not4:
		
		cmp ship_self_3_count, 22
		jne game_stage1_not3
			mov ship_self_3_count, al
			lea dx, game_message_ship2
            call game_message
			jmp game_stage1_exit
		game_stage1_not3:
		
		cmp ship_self_2_count, 22
		jne game_stage1_not2
			mov ship_self_2_count, al
			lea dx, game_message_ship1
            call game_message
			jmp game_stage1_exit
		game_stage1_not2:
		
		cmp ship_self_1_count, 22
		jne game_stage1_not1
			mov ship_self_1_count, al
			
			call action_sendGameParams
			
			jmp game_stage1_exit
		game_stage1_not1:

    game_stage1_exit:
		
    
	ret
game_stage1 endp
