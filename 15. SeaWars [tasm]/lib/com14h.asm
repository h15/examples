
; Com
;
; Com-port interface.
; More info about COM at http://softelectro.ru/rs232prog.html
;
; It's part of SeaWars game.
;
; Tasm file.
; Charset utf-8.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.

;com_base    dw 0
com_type    db 0 ; slave, master = 0, 1
com_number  db 2 ; 0 - com1
                 ; 2 - com2


; Install com int handler.
; @return ax - ah=LSR; al=MSR

com_install proc
    mov ah, 00h ; initialize
    
; config byte:
;
; 7 6 5 4 3 2 1 0       описание            допустимые значения
; x x x                 скорость, бод       000 - 110
;                                           001 - 150
;                                           010 - 300
;                                           011 - 600
;                                           100 - 1200
;                                           101 - 2400
;                                           110 - 4800
;                                           111 - 9600
;       x x             проверка паритета   00  - нет
;                                           01  - нечетность
;                                           10  - нет
;                                           11  - четность
;           x           длина стопового бита0   - 1
;                                           1   - 2
;             x x       кол. бит в символе  10  - 7
;                                           11  - 8

    mov al, 0ffh ; 9600 бод, четность, 2 стоп, 8 бит
    xor dx, dx
    mov dl, com_number ; (n-1), где n-номер COM порта 
    shr dx, 1
    
    int 14h
    
    ret
com_install endp


; Get char from com-port.
; @return al - byte from com-port

com_get proc
    mov ah, 02h
    xor dx, dx
    mov dl, com_number ; (n-1), где n-номер COM порта 
    shr dx, 1
    
    int 14h
    
    ret
com_get endp


; Send char by com.
; @param al - byte for sending

com_send proc
    mov ah, 01h
    xor dx, dx
    mov dl, com_number ; (n-1), где n-номер COM порта 
    shr dx, 1
    
    int 14h
    
    ret
com_send endp

; Does transmittor regestry free?
;
; @return ax - Busy on 0, empty on 1.

com_isReceived proc
    mov ah, 03h
    xor dx, dx
    mov dl, com_number ; (n-1), где n-номер COM порта 
    shr dx, 1
    
    int 14h
    ; ah = LSR
    ; al = MSR
    
    ; Look at 5th bit(Transmitter Holding Register Empty) of LSR.
    ; Empty if THRE=1.
    shr ax, 8
    and ax, 10000b
    shr ax, 4
    
    ret
com_isReceived endp
