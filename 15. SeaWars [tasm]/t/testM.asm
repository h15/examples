   .model tiny
   .code
   .186
    org 100h

main:
    jmp main_1
    
    include ../lib/kbd.asm
    include ../lib/com.asm
    include ../lib/hooks.asm
    include ../lib/video.asm
    
game_seconds    dw 0f188h
game_curTime    dw 0f188h

log_message_get         db 'Get$'
log_message_send        db 'Send$'
log_message_comInit     db 'Com Init$'
log_message_videoInit   db 'Video init$'

main_1:
    call com_install
    lea dx, log_message_comInit
    call game_log
    
    call video_install
    lea dx, log_message_videoInit
    call game_log
    
    call hooks_install
    
    game_LOOP:
        
        ; One time per game "second".
        ;
        mov ax, game_curTime
        mov bx, game_seconds
        cmp ax, bx
        je game_mainloop_second_skip
            mov game_curTime, bx
            
            ;call com_isReceived
            ;cmp al, 0
            ;je game_mainloop_second_skip
            
            mov ax, game_seconds
            
            call com_send
            lea dx, log_message_send
            call game_log
            
            ;call com_get
            ;lea dx, log_message_get
            ;call game_log
            
            call util_alToBuf
            lea dx, util_buf
            call game_log
            
        game_mainloop_second_skip:
        
        ; Exit if ESC pressed.
        ;
        call kbd_shiftKey
        cmp al, 1
        jne game_LOOP
    game_exit:
        call video_uninstall
        call hooks_uninstall
    
    ret

    ;;
    ;; UTILs
    ;;

    util_buf db '               ',13,10,36

    ; ax -> buf
    util_alToBuf proc
        push ax
        push bx
        push cx
        push dx
        
        lea si, util_buf
        
        mov cx, 4
        util_alToBuf_loop:
        push si
            add si, cx
            dec si
            
            mov dx, ax
            and dx, 1111b
            call util_toChr
            mov [si], dl
            
            shr ax, 4
        pop si
        loop util_alToBuf_loop
        
        pop dx
        pop cx
        pop bx
        pop ax
    util_alToBuf endp    

    ; Cipher -> Char
    util_toChr proc
        cmp dx, 10
        jl util_toChr_decim
            sub dx, 10
            add dx, 'a'
            ret
        util_toChr_decim:
            add dx, '0'
            ret
    util_toChr endp
    
    game_message_longEmptyString40  db '                                        $';
    game_log_line db 0h
    
    game_log proc
        push bx
        push ax
        push dx
        
        mov al, game_log_line
        inc al
        
        cmp al, 48
        jne game_log_skip
            mov al, 1h
        game_log_skip:
        
        mov game_log_line, al
        
        mov dl, 0h  ; pos
        mov dh, game_log_line
        xor bh, bh  ; video mode
        mov ah, 2   ; set pos func
        int 10h
        
        ; clean up
        lea dx, game_message_longEmptyString40
        mov ah, 9
        int 21h
        
        mov dl, 0h  ; pos
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

end main
