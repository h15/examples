
; VIDEO
;
; This is an include file for video high-level interface using.
; It's part of SeaWars game.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.


; Data
video_oldmod    db 0
video_oldpage   db 0
video_font: ; Change font for nice pseudographic.
    r_border    db 8 dup(1)
    b_border    db 7 dup(0)
                db 0ffh
    rb_border   db 7 dup(1)
                db 0ffh
    
    cells       db 8 dup(01111110b)
    miss        db 2 dup(1)
                db 00010001b
                db 00111001b
                db 00010001b
                db 2 dup(1)
                db 0ffh
    ship        db 8 dup(0ffh)
    crude_ship  dw 4 dup(0101010110101010b)

; Install 2 video mod.
;

video_install proc

    mov ah, 0fh
    int 10h

    mov video_oldmod, al
    mov video_oldpage, bh
    
    mov al, 2
    mov ah, 0
    int 10h
    
    mov ax, 1112h
    int 10h
    
    ret

video_install endp


; Install system video mod.
;

video_uninstall proc

    mov al, video_oldmod
    xor ah, ah
    int 10h

    mov al, video_oldpage
    mov ah, 5
    int 10h
    
    ret

video_uninstall endp


; Load another charset.
;

; AL = 0: load user-defined text-mode display font
; ES:BP => user font table
; CX = count of character patterns to store
; DX = character offset (font load starts at this ASCII value)
; BL = font block to load (0 to 4; 4 if 256K EGA memory)
; BH = count of bytes per character pattern (eg, 8 or 14)

video_loadFont proc

    push cs
    pop es
    push offset video_font
    pop bp
    
    mov cx, 7
    mov dx, 0
    mov bx, 0800h
    mov ax, 1100h
    int 10h
    
    ret

video_loadFont endp

