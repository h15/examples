
; File
;
; Write to log file.
;
; Tasm file.
; Charset utf-8.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.

log_file_s  db 'slave.log'
log_file_m  db 'master.log'
log_handler dw 0


; Open file.

log_install proc
    ret ; disable
    push cs
    pop ds
    
    ; slave / master file
    mov al, com_type
    cmp al, 0
    jne log_install_slave
        lea dx, log_file_m
        jmp log_install_open
    log_install_slave:
        lea dx, log_file_s
        jmp log_install_open
    
    log_install_open:
        ; open file
        mov ax, 3d00h
        int 21h         ; dx - file
    
    mov bx, ax           ; copy handler to bx
    xor cx, cx
    xor dx, dx
    mov ax, 4200h
    int 21h             ; seek 0 offset

    ret
log_install endp


; AH = 40H
; BX = описатель файла
; DS:DX = адрес буфера, содержащего записываемые данные
; CX = число записываемых байт

log_write proc
    
    mov ah, 40h
    mov bx, log_handler
    mov cx, 12h
    int 21h
    
    ret
log_write endp
