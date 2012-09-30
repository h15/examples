
; Com
;
; Com-port interface.
; It's part of SeaWars game.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.

com_base dw 0
com_type db 0 ; slave, master = 0, 1

; Install com int handler.

com_install proc
    mov ax, 40h
    push es
    mov es, ax
    mov dx, es:[bx]
    mov com_base, dx
    add dx, 3
    mov al, 128
    out dx, al
    sub dx, 2
    mov al, 0
    out dx, al
    dec dx
    mov al, 0Ch
    out dx, al
    mov al, 0
    or al, 01111B
    add dx, 3
    out dx, al
    sub dx, 2
    mov al, 0
    out dx, al
    pop es
    ret
com_install endp

com_get proc
    mov dx, com_base
    in al, dx
    ret
com_get endp

com_send proc
    mov dx, com_base
    out dx, al
    ret
com_send endp
    
com_isReceived proc
    mov dx, com_base
    add dx, 5
    in al, dx
    ret
com_isReceived endp
