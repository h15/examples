
; Action
;
; Do something when enemy sends command.
; It's part of SeaWars game.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.


action_status   db 0 ; 0 - send, 1 - get
action_isOnline db 0 ; At least one sync comes.
action_message  db 'Another user connected!$'

action_masterReady  db 0 ; All ships afloats.
action_slaveReady   db 0 ; All ships afloats.

action_fight        db 0 ; Does it my round?
action_attack_cell  dw 0 ; Which cell I attacked?

action_sync_skip    db 0

action_lastSerialSendTime dw 0

; Get message from other side / send delayed message.
action_dispatch proc
    ; Check recv buffer.
    mov al, action_status
    cmp al, 1
    jne action_dispatch_sendMessage
        ; Recv
        call action_getMessage
        ret
    action_dispatch_sendMessage:
        ; Send
        call action_sendMessage
        ret
action_dispatch endp

action_sendMessage proc
    inc action_status
    
    mov ax, serial_bufCount
    cmp ax, 0
    je action_sendMessage_sync
        ; Buffer is not empty.
        call serial_send
        ret
    
    action_sendMessage_sync:
        mov bx, action_lastSerialSendTime
        mov ax, game_curTime    ; Send sync only if other commands did not send
        cmp bx, ax              ; in this time period AND ->
        jge action_sendMessage_sync_exit
        mov ax, serial_bufCount
        cmp ax, 0
        jg action_sendMessage_sync_exit ; -> if bufCount = 0
        
            ; SKIP SYNC on demand.
            ;mov al, action_sync_skip
            ;cmp al, 0
            ;jne action_sendMessage_sync_dec
            
                
                ; Buffer is empty.
                mov al, serial_type
                cmp al, 0
                je action_sendMessage_sync_slave
                    mov al, 0AAh    ; ping
                    call serial_alToBuf
                    call serial_send
                    ret
                action_sendMessage_sync_slave:
                    mov al, 01h     ; pong
                    call serial_alToBuf
                    call serial_send
                    ret
            ;action_sendMessage_sync_dec:
            ;    dec al
            ;    mov action_sync_skip, al
                
    action_sendMessage_sync_exit:
        ret
action_sendMessage endp


; Waiting for opponent.
;

action_online proc
    push ax
    push bx
    push dx
    
    mov bl, action_isOnline
    cmp bl, 0
    jne action_online_exit
        mov action_isOnline, 1
        lea dx, action_message
        call game_log
        
        cmp serial_type, 0
        je action_online_slave
            lea dx, game_message_fieldSize
            call game_message
            
            mov al, 0a1h
            call serial_alToBuf ; SEND SEND SEND A1!!!!!
            call serial_alToBuf
            call serial_alToBuf
            call serial_alToBuf
            call serial_alToBuf
            call serial_alToBuf
            call serial_send
            
            jmp action_online_slave_end
        
        action_online_slave:
            lea dx, game_message_waitGameParams
            call game_message
        
        action_online_slave_end:
        
        mov game_stage, 0F1h
    
    action_online_exit:
        pop dx
        pop bx
        pop ax
    
        ret
action_online endp


action_getMessage proc
    dec action_status
    
    mov cx, serial_recvCount
    cmp cx, 0
    jne action_getMessage_skip
        jmp action_getMessage_exit
    action_getMessage_skip:
    
    ; Online
    call action_online
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    action_getMessage_getCmd:
        call serial_recvBufToAl
    
    cmp al, 00
    jne action_getMessage_00
        jmp action_getMessage_exit
    action_getMessage_00:
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;;  Commands parsing
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    cmp al, 0aah ; ping
    jne action_getMessage11
        jmp action_getMessage_exit
    action_getMessage11:
    
    cmp al, 01h  ; pong
    jne action_getMessage12
        jmp action_getMessage_exit
    action_getMessage12:
    
    cmp al, 0b1h ; change name
    jne action_getMessage_1
        call action_changeEnemysName
        jmp action_getMessage_exit
    action_getMessage_1:
    
    cmp al, 01bh ; name changed (who cares?)
    jne action_getMessage_13
        jmp action_getMessage_exit
    action_getMessage_13:
    
    cmp al, 0b2h    ; Get game params
    jne action_getMessage_2
        call action_recvGameParams
        
        mov ax, 0efefh
        call util_alToBuf
        lea dx, util_buf
        call game_debug
        
        jmp action_getMessage_exit
    action_getMessage_2:
    
    cmp al, 2bh ; Ok(game params) from enemy
    jne action_getMessage10
        mov ax, 0eeeeh
        call util_alToBuf
        lea dx, util_buf
        call game_debug
        
        mov al, 0a2h
        call serial_alToBuf ; SEND SEND SEND A2!!!!!
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_send
        
        jmp action_getMessage_exit
    action_getMessage10:
    
    cmp al, 0a3h
    jne action_getMessage_3
        mov action_masterReady, 1
        
        mov al, 3ah
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_send
        
        call action_checkSelf
        jmp action_getMessage_exit
    action_getMessage_3:
    
    cmp al, 3ah
    jne action_getMessage_15
        mov action_masterReady, 1
        jmp action_getMessage_exit
    action_getMessage_15:
    
    cmp al, 0a4h
    jne action_getMessage_4
        mov game_stage, 0F4h
        
        mov al, 4ah
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_send
        
        lea dx, game_message_fight
        call game_message
        mov action_fight, 1
        jmp action_getMessage_exit
    action_getMessage_4:
    
    cmp al, 4ah
    jne action_getMessage_14
        mov action_slaveReady, 1
        mov game_stage, 0F4h
        lea dx, game_message_fight
        call game_message
        
        jmp action_getMessage_exit
    action_getMessage_14:
    
    
        push dx
        push ax
        mov ax, 0ededh
        call util_alToBuf
        lea dx, util_buf
        call game_debug
        pop ax
        pop dx
        
    
        push dx
        push ax
        call util_alToBuf
        lea dx, util_buf
        call game_debug
        pop ax
        pop dx
        
    cmp al, 0C0h
    jne action_getMessage_5
        call action_attack
        jmp action_getMessage_exit
    action_getMessage_5:
    
    cmp al, 0Ch
    jne action_getMessage_6
        call action_miss
        
        lea dx, game_message_IMiss
        call game_log
        
        jmp action_getMessage_exit
    action_getMessage_6:
    
    cmp al, 1Ch
    jne action_getMessage_7
        call action_hit
        
        lea dx, game_message_IHit
        call game_log
        
        jmp action_getMessage_exit
    action_getMessage_7:
    
    cmp al, 2Ch
    jne action_getMessage_8
        call action_hit
        
        lea dx, game_message_IKill
        call game_log
        
        jmp action_getMessage_exit
    action_getMessage_8:
    
    cmp al, 3Ch
    jne action_getMessage_81
        call action_miss
        lea dx, game_message_kill
        call game_log
        
        jmp action_getMessage_exit
    action_getMessage_81:
    
    cmp al, 0A9h
    jne action_getMessage_0A9h
        mov al, 9ah
        call serial_alToBuf
        call serial_send
        
        mov al, 0
        call game_endOfGame
        
        jmp action_getMessage_exit
    action_getMessage_0A9h:
    
    action_getMessage_exit:
       ; mov serial_recvCount, 0
        ret
action_getMessage endp


; Sync ping
; MASTER

action_syncPing proc
    mov al, 0AAh
    call serial_alToBuf
    call serial_send
    ret
action_syncPing endp


; Sync pong
; SLAVE

action_syncPong proc
    mov al, 01h
    call serial_alToBuf
    call serial_send
    ret
action_syncPong endp


action_changeEnemysName proc
    call serial_recvBufToAl
    mov cl, al
    
    cmp cl, 0
    je action_changeEnemysName_exit
    
    push si
    push cx
        ; Clean up
        mov cl, ui_user_enemyName_len
        lea di, ui_user_enemyName_str
        
        xor cx, cx
        mov dx, 0341h
        mov ah, 2
        int 10h
        
        action_changeEnemysName_loop:
            mov dl, 20h
            mov ah, 2
            int 21h
            
            inc di
        loop action_changeEnemysName_loop
    pop cx
    pop si
    
    ; Set new name
    mov ui_user_enemyName_len, cl
    lea di, ui_user_enemyName_str
    
    action_changeEnemysName_loop1:
        call serial_recvBufToAl
        mov [di], al
        inc di
    loop action_changeEnemysName_loop1
    
    action_changeEnemysName_exit:
        ret
action_changeEnemysName endp


; m[B2,X,4x,3x,2x,1x]=>s[2B,X,4x,3x,2x,1x]
; передача параметров игры (размер поля и количество кораблей)

action_sendGameParams proc
    nop ; WAIT
    
    mov al, 0b2h
    call serial_alToBuf
    mov al, ui_border_sizeX
    call serial_alToBuf
    mov al, ship_self_4_count
    or al, 1000000b
    call serial_alToBuf
    mov al, ship_self_3_count
    or al, 110000b
    call serial_alToBuf
    mov al, ship_self_2_count
    or al, 100000b
    call serial_alToBuf
    mov al, ship_self_1_count
    or al, 10000b
    call serial_alToBuf
    
    call serial_send
    
    lea dx, game_message_installYourShips
    call game_message
    
    mov game_stage, 00
    
    ret
action_sendGameParams endp


; B2 gotcha! Setup game params,
; send answer 2B.
;
; @param si - ref to command data.

action_recvGameParams proc
    mov al, 02bh
    call serial_alToBuf
    
    call serial_recvBufToAl
    call serial_alToBuf
    mov ui_border_sizeX, al
    mov ui_border_sizeY, al
    
    call serial_recvBufToAl
    call serial_alToBuf
    and al, 1111b
    mov ship_self_4_count, al
    
    call serial_recvBufToAl
    call serial_alToBuf
    and al, 1111b
    mov ship_self_3_count, al
    
    call serial_recvBufToAl
    call serial_alToBuf
    and al, 1111b
    mov ship_self_2_count, al
    
    call serial_recvBufToAl
    call serial_alToBuf
    and al, 1111b
    mov ship_self_1_count, al
    
    call serial_send
    
    lea dx, game_message_installYourShips
    call game_message
    
    mov game_stage, 00
    
    ret
action_recvGameParams endp


action_shipsAfloats proc
    cmp serial_type, 1
    je action_shipsAfloats_master
    ; Slave
        mov action_slaveReady, 1
        
        cmp action_masterReady, 1
        je action_shipsAfloats_sendReady
            ret
        action_shipsAfloats_sendReady:
            mov al, 0a4h
            
            call serial_alToBuf
            call serial_alToBuf
            call serial_alToBuf
            call serial_alToBuf
            call serial_alToBuf
            call serial_send
            
            mov game_stage, 0F4h
            lea dx, game_message_fight
            call game_message
            
            ret
    action_shipsAfloats_master:
    ; Master
        mov action_masterReady, 1
        mov al, 0a3h
        
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_send
        
        ret
action_shipsAfloats endp

action_checkSelf proc
    cmp action_slaveReady, 1
    jne action_checkSelf_notReady
        mov action_masterReady, 1
        mov al, 0a4h
        
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_alToBuf
        call serial_send
        
        mov game_stage, 0F4h
        lea dx, game_message_fight
        call game_message
    action_checkSelf_notReady:
    ret
action_checkSelf endp


; We are under attack!

action_attack proc

    ; Get cell XY
    action_attack_getch1:
        call serial_recvBufToAl
        cmp al, 0
    je action_attack_getch1
    
    mov dl, al
    
    action_attack_getch2:
        call serial_recvBufToAl
        cmp al, 0
    je action_attack_getch2
    
    mov dh, al
    
	mov bx, ui_border_offsetYX
    add dx, bx
    
    ; DEBUG
    push dx
    mov ax, dx
    call util_alToBuf
    lea dx, util_buf
    call game_debug
    pop dx
    
    ;
    ;   FIND ATTACKED CELL
    ;
    lea si, ship_self
    mov cx, 100
    action_attack_loop:
        mov ax, [si]
        cmp dx, ax
        je action_attack_gotcha
        add si, 2
    loop action_attack_loop
    
    jmp action_attack_exit
    action_attack_gotcha:
        ; Save attack for rendering.
        push cx
        push si
            lea si, ship_selfAttack
            
            mov cx, 100
            action_attack_hit:
            push cx
                
                mov bx, [si]
                cmp bx, 0
                jne action_attack_hit_next
                
                    mov [si], dx
                    jmp action_attack_hit_end
                
            action_attack_hit_next:
            add si, 2
            pop cx
            loop action_attack_hit
            jmp action_attack_hit_end1
            action_attack_hit_end:
            pop cx
            action_attack_hit_end1:
        pop si
        pop cx
        
        
        ; Mark attacked cell as empty field (broken).
        mov bx, 0
        mov [si], bx
        
        push si
        push ax
            lea ax, ship_self
            sub si, ax
            shr si, 3 ; <- Ship number!
            mov cx, si
        pop ax
        pop si
        
        ; HIT or KILL
        lea si, ship_self_alive ; dec living-cells' count
        add si, cx
        mov al, [si]
        dec al
        mov [si], al
        mov ah, cl
        
        ; DEBUG
        push ax
		mov ax, 0
		call util_alToBuf
		lea dx, util_buf
		call game_debug
        
        mov ah, cl
        call util_alToBuf
        lea dx, util_buf
        call game_debug
        pop ax
        ;
        cmp al, 0
        je action_attack_gotcha_dead
        jmp action_attack_gotcha_notDead
        
        action_attack_gotcha_dead:
            ; Send 'dead'
            mov al, 2Ch
            call serial_alToBuf
            call serial_send
            
            lea dx, game_message_ImDead
            call game_log
            
            ret
        action_attack_gotcha_notDead:
            ; Send 'hit'
            mov al, 1Ch
            call serial_alToBuf
            call serial_send
            
            lea dx, game_message_IHurt
            call game_log
        
            ret
    action_attack_exit:
        ; Save strike
        lea si, ship_selfMiss
        
        mov cx, 100
        action_attack_miss:
        push cx
            
            mov bx, [si]
            cmp bx, 0
            jne action_attack_miss_next
            
                mov [si], dx
                jmp action_attack_miss_end
            
        action_attack_miss_next:
        add si, 2
        pop cx
        loop action_attack_miss
        jmp action_attack_miss_end1
        action_attack_miss_end:
        pop cx
        action_attack_miss_end1:
        
        
        ; Send 'miss'
        mov al, 0Ch
        call serial_alToBuf
        call serial_send
        
        lea dx, game_message_ImOk
        call game_log
        
        mov action_fight, 1
        
        ret
action_attack endp


action_hit proc
    mov action_fight, 1
    mov dx, action_attack_cell
    
    push ax
        mov al, ship_enemy_cells
        dec al
        mov ship_enemy_cells, al
        
        cmp al, 0
        jne action_hit_doesnotLast
            mov al, 1
            call game_endOfGame
        action_hit_doesnotLast:
    pop ax
    
    lea si, ship_attack
    action_hit_loop:
        mov ax, [si]
        
        cmp ax, 0 ; Free cell.
        je action_hit_loop_save
        ; Next step.
            add si, 2
            jmp action_hit_loop_next
        action_hit_loop_save:
        ; Save cell.
            mov [si], dx
            jmp action_hit_loop_end
    action_hit_loop_next:
    jmp action_hit_loop
    action_hit_loop_end:
    
    ret
action_hit endp


action_miss proc
    mov action_fight, 0
    mov dx, action_attack_cell
    
    lea si, ship_miss
    action_miss_loop:
        mov ax, [si]
        
        cmp ax, 0 ; Free cell.
        je action_miss_loop_save
        ; Next step.
            add si, 2
            jmp action_miss_loop_next
        action_miss_loop_save:
        ; Save cell.
            mov [si], dx
            jmp action_miss_loop_end
    action_miss_loop_next:
    jmp action_miss_loop
    action_miss_loop_end:
    
    ret
action_miss endp
