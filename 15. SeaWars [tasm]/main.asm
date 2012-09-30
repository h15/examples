
; SeaWars MAIN file
;
; This application provides classical sea-wars game with multi-player
; support. Players can use COM for computer connection.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.


; Simple com file.
   .model tiny
   .code
   .186
    org 100h

main:
    jmp main_1
    
    ; Preload libs.
    
        ; High-level interface for keyboard.
        ; Using buffer for 8 chars.
        include lib/kbd.asm
        ; Hooks for hardware timer and keyboard access.
        include lib/hooks.asm
        ; Mouse interface.
        ; Get mouse position, which button was pressed.
        include lib/mouse.asm
        ; Change current video mode to our prefer mode.
        include lib/video.asm
        ; Game main loop and other general game-info + logic.
        include lib/game.asm
        ; Draw UserInterface.
        ; Also click events are here too.
        include lib/ui.asm
        ; Ship "object".
        include lib/ship.asm
        ; Click routing events.
        include lib/click.asm
        ; Com-port interface.
        include lib/com.asm
    ; Data.
        main_log_init db 'Init: DONE', 13,10,36
        main_log_exit db 'Exit: DONE', 13,10,36

    main_1:
        ; Init devices.
        main_init:
            call hooks_install
            call video_install
            call video_loadFont
            call mouse_install
            call com_install
            
            mov ah, 9
            mov dx, offset main_log_init
            int 21h
        
        ; Game is here.
        call game_mainloop
        
        ; Back to dos default modes.
        main_exit:
            call mouse_uninstall
            call video_uninstall
            call hooks_uninstall
            
            mov ah, 9
            mov dx, offset main_log_exit
            int 21h
    ret

    ;;
    ;; UTILs
    ;;

    util_buf db '    ',13,10,36

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
    
end main
