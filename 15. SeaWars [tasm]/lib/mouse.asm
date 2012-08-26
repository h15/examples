
; MOUSE
;
; This is an include file for mouse support.
; It's part of SeaWars game.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.


mouse_status_isPressed  db 0
mouse_status_button     db 0
mouse_status_position_x db 0
mouse_status_position_y db 0


; Install mouse.
;
; Install our mouse handler.
;
; Use mouse_uninstall to uninstall
; this mouse handler.

mouse_install proc

    push cs
    pop es
    
    ; Init mouse.
    mov ax,0001h    
    int 33h
    
    ; Install handler.
    mov ax, 0ch
    mov cx, 1010b
    lea dx, mouse_onClick
    int 33h
    
    ret

mouse_install endp


; Uninstall mouse.
;
; Uninstall our mouse handler.
    
mouse_uninstall proc
    
    ; Disable our handler.
    mov ax, 0ch
    mov cx, 0
    int 33h
    
    ret

mouse_uninstall endp


; Mouse handler.
;

mouse_onClick:

    shr cx, 3    ; X
    shr dx, 3    ; Y
    mov dh, dl
    mov dl, cl
    
    mov mouse_status_position_x, dl
    mov mouse_status_position_y, dh

    mov ah, 0fh
    int 10h

    mov ah, 2
    int 10h
    
    ; Hide cursor.
    mov ax, 2
    int 33h
    
    ; If right mouse-button.
    cmp bx, 2
    jne mouse_onClick_left
    
        mov mouse_status_isPressed, 1       ; BUTTON PRESSED
        mov mouse_status_button, 3          ; RIGHT BUTTON PRESSED
        
        ; Clear click status.
        call click_flushStatus
        call mouse_flushStatus
        
        jmp mouse_onClick_EXIT
    
    mouse_onClick_left:
    
        mov mouse_status_isPressed, 1       ; BUTTON PRESSED
        mov mouse_status_button, 1          ; LEFT BUTTON PRESSED
        
        ; !!! GOTO CLICK ROUTER
        ; !!! TO SELECT EVENT
        call click_route
        call mouse_flushStatus
    
    mouse_onClick_EXIT:
        
        ; Show cursor
        mov ax, 1
        int 33h
    
    retf


; Clean status data fields
; of mouse.

mouse_flushStatus proc

    mov mouse_status_isPressed, 0
    mov mouse_status_button, 0
    mov mouse_status_position_x, 0
    mov mouse_status_position_y, 0
    
    ret

mouse_flushStatus endp

