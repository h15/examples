
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
        include lib/kbd.asm
        include lib/hooks.asm
        include lib/mouse.asm
        include lib/video.asm
        include lib/game.asm
        include lib/ui.asm
        include lib/ship.asm
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
