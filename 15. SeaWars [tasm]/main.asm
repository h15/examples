
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
        ; Ship "object"
        include lib/ship.asm
        ; Click routing events.
        include lib/click.asm
    ;   include lib/com.asm
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
    
end main
