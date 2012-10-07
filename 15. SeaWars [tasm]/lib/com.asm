
; Com
;
; Com-port interface.
; It's part of SeaWars game.
;
; Tasm file.
; Charset utf-8.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.

; UART registries:
;   адрес  DLAB чтение/запись   Название регистра 
;   00h    0    WR              THR(Transmit Holding Register)-регистр данных ожидающих передачи
;   00h    0    RD              RBR(Receiver Buffer Register)- буферный регистр приемника
;   00h    1    RD/WR           DLL(Divisor Latch LSB)-младший байт делителя частоты
;   01h    1    RD/WR           DIM(Divisor Latch MSB)-старший байт делителя частоты
;   01h    0    RD/WR           IER(Interrupt Enable Register)-регистр разрешения прерывания
;   02h    х    RD              IIR(Interrupt Identification Register)-регистр идентифицирующий прерывания
;   02h    х    WR              FCR(FIFO Control Register)-регистр управления режимом FIFO
;   03h    x    RD/WR           LCR(Line Control Register)-регистр управления линией связи
;   04h    x    RD/WR           MCR(Modem Control Register)-регистр управления модемом
;   05h    x    RD/WR           LSR(Line Status Register)-регистр состояния линии связи
;   06h    x    RD/WR           MSR(Modem Status Register)-регистр состояния модема
;   07h    x    RD/WR           SCR(Scratch Pad Register)-регистр временного хранения 

com_base    dw 0
com_type    db 0 ; slave, master = 0, 1
com_number  db 0 ; 0 - com1
                 ; 2 - com2

com_log_recvCmd db 'Received command$'

; Install com int handler.

com_install proc
    ; Get base addr and save it.
    mov ax, 40h
    mov es, ax
    xor ax, ax
    mov al, com_number
    mov si, ax
    mov dx, es:[si]
    mov com_base, dx
    
    ; 10000000b -> LCR
    ; *-------b -> DLAB
    add dx, 3
    mov al, 128
    out dx, al
    
    ; Interrupt Enable Register
    ; Don't interrupt me!
    sub dx, 2
    mov al, 0
    out dx, al
    
    ; Set Divisor Latch LSB
    dec dx
    mov al, 0ch
    out dx, al
    
    ; Set LCR
    ; Бит 0. SDB_ID0(Serial Data Bits ID0)- нулевой бит идентификатора
    ;        количества бит в передаваемом символе.
    ; Бит 1. SDB_ID1(Serial Data Bits ID1)- первый бит идентификатора
    ;        количества бит в передаваемом символе.
    ;        С помощью этих битов задают количество бит в передаваемом
    ;        или принимаемом символе.
    ;
    ; SDB_ID1    SDB_ID0    количество бит в символе
    ;   0           0               5
    ;   0           1               6
    ;   1           0               7
    ;   1           1               8
    ;
    ; Бит 2. STOP_B(Stop Bits)- Этот бит определяет число стоповых
    ;        битов, переданных или полученных в каждом последовательном
    ;        символе. Если бит STOP_B=0, то передается один стоповый
    ;        бит. Если бит STOP_B=1, то стоповый бит равен двум для
    ;        6,7,8 битовых символов и полтора стоповых бита для 5-ти
    ;        битовых символов. Приемник проверяет только первый стоповый
    ;        бит, независимо от выставленных стоповых битов.
    ;
    ; Бит 3. PAREN(Parity Enable) -Если PAREN=1, то разрешено использование
    ;        бита паритета и данный бит вставляется между последним битом
    ;        данных и стоповым битом. Если PAREN=0, то бит паритета
    ;        не выставляется и не входит в состав передаваемого символа.
    ;
    ; Бит 4. EVENPAR(Even Parity Select) - Бит выбора типа контроля
    ;        паритета. Если EVENPAR=1, то происходит проверка на четность.
    ;        Если EVENPAR=0, то происходит проверка на нечетность.
    ;
    ; Бит 5. STICPAR (Sticky Parity)- Если STICPAR=0, то бит паритета
    ;        бит генерируется в соответствии с паритетом выводимого
    ;        символа. Если STICPAR=1, то постоянное значение контрольного
    ;        бита: при EVENPAR=1 — нулевое, при EVENPAR=0 — единичное.
    ;
    ; Бит 6. BRCON(Break Control)- Управляющий бит обрыва связи.
    ;        Если BRCON=1, то вслучае возникновения перерыва в приеме
    ;        данных, передатчик UART начнёт передавать в линию нули.
    ;
    ; Бит 7. DLAB(Divisor Latch Access Bit)- Этот бит доступа к делителю
    ;        частоты. Если DLAB=1, то можно обратиться к регистрам DIM,
    ;        DLL в которых хранятся младший и старший байт делителя
    ;        частоты :16.Если DLAB=0, то можно обратиться к регистрам
    ;        THR,RBR,IER.
    
    mov al, 0b
    or  al, 11b
    or  al, 100b
    or  al, 1000b
    or  al, 10000b
    
    add dx, 3
    out dx, al
    
    ; IER
    sub dx, 2
    mov al, 0
    out dx, al
    
    ; restore es
    push ss
    pop es
com_install endp


; Get char from com-port.
; @return al - byte from com-port

com_get proc
    mov dx, com_base
    in al, dx
    ret
com_get endp


; Send char by com.
; @param al - byte for sending

com_send proc
    mov dx, com_base
    out dx, al
    ret
com_send endp


; Does transmittor regestry free?
; Look at 5th bit(Transmitter Holding Register Empty) of LSR.
; Empty if THRE=1.
;
; @return ax - (LSR&10000b)>>45. Busy on 0, empty on 1.

com_isReceived proc
    mov dx, com_base
    add dx, 5
    in al, dx
    
    and ax, 10000b
    shr ax, 4
    
    ret
com_isReceived endp

com_action_recvCmd proc
    call com_get
    call util_alToBuf
    
    lea dx, com_log_recvCmd
    call game_log
    lea dx, util_buf
    call game_log
    
    ret
com_action_recvCmd endp

com_action_sendSync proc
    mov al, 0aah
    call com_send
    
    ret
com_action_sendSync endp
