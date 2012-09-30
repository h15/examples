
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


; Install com int handler.

com_install proc
    ret
com_install endp 

proc com_init
    mov    ax,40h
    push es
    mov    es,ax
    mov    dx,es:[bx]
    mov    com_base,dx
    add    dx,3
    mov    al,128
    out    dx,al
    sub    dx,2
    mov    al,0
    out    dx,al
    dec    dx
    mov    al,0Ch
    out    dx,al
    mov    al,0
    or    al,01111B
    add    dx,3
    out    dx,al
    sub    dx,2
    mov    al,0
    out    dx,al
    pop es
    ret
endp com_init

proc com_get
    mov    dx,com_base
    in    al,dx
    ret
endp com_get

proc com_send
    mov    dx,com_base
    out dx,al
    ret
endp com_send
    
proc com_send
    mov    dx,com_base
    add    dx,5
    in    al,dx
    ret
endp com_send

com_base    dw    0
