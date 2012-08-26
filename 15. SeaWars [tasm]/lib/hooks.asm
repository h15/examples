
; HOOKS
;
; This is an include file for timer and keyboard support.
; It's part of SeaWars game.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.


hooks_int8_count    db 0
hooks_int8_slow     dw 18   ; Speed of count change.
                            ; Now is each 18 PIC tick.


; HOOKS for INT 8 (timer)
;
; Our timer implementation.
; It provides high-level interface
; to low-level PIC's timer.

hooks_int8:
    push ax
    
    inc hooks_int8_count
    
    mov ax, hooks_int8_slow
    
    cmp hooks_int8_count, al
    jne hooks_int8_jump8
    
        inc game_seconds            ; $SECONDS++
        mov hooks_int8_count, 0
        mov hooks_int8_flag, 1
    
    hooks_int8_jump8:
    
        pop ax
        
        db 0eah                     ; FAR JUMP
        hooks_int8_old8     dd 0    ; TO OLD HOOK

    hooks_int8_flag     db 0


; HOOKS for INT 9 (keyboard)
;
; It provides high-level interface
; for PIC's interface to keyboard.
; All pressed buttons will saves into
; round-buffer.

hooks_int9:
    push ax
    pushf
    
    in al, 60h
    ;cmp al,1                ; esc
    ;je hooks_int9_pressed
    ;cmp al,1ch              ; enter
    ;je hooks_int9_pressed
    ;
    ;    jmp hooks_int9_jump9
    ;
    ;hooks_int9_pressed:
    
        call kbd_pushKey
        
        in  al,61H
        mov ah,al
        or  al,80h
        out 61H,al
        xchg ah,al
        xor al,al
        out 61H,al
        mov al,20H
        out 20H,al
        
        popf
        pop ax
        
        iret

    hooks_int9_jump9:
        popf
        pop ax
        
        db 0eah                 ; FAR JUMP
        hooks_int9_old9 dd 0    ; TO OLD INT 9 HOOK


    hooks_int9_buf_start   db 0
    hooks_int9_buf_end     db 0
    hooks_int9_key_buf     db 8 dup (0)


; Install hooks.
;
; This procedure provides installation of
; INT 8 and INT 9 hooks with saving old
; hooks.
;
; Use hooks_uninstall to uninstall hooks.

hooks_install proc

    ; Save old 8th vector
    push 32
    pop di
    push 0
    pop es

    mov ax, [es:di]                         ; ip
    mov word ptr hooks_int8_old8, ax
    mov ax, [es:di + 2]                     ; cs
    mov word ptr hooks_int8_old8 + 2, ax
    
    ; Set new 8th vector
    mov ax, offset hooks_int8   ; get ip
    mov cx, ds                  ; get cs

    CLI
        stosw
        push 34
        pop di
        
        mov ax, cx
        stosw
    STI
    
    ; Save old 9th vector
    push 36
    pop di
    push 0
    pop es

    mov ax, [es:di]                         ; ip
    mov word ptr hooks_int9_old9, ax
    mov ax, [es:di + 2]                     ; cs
    mov word ptr hooks_int9_old9 + 2, ax
    
    ; Set new 8th vector
    mov ax, offset hooks_int9   ; get ip
    mov cx, cs                  ; get cs

    CLI
        stosw
        push 38
        pop di
        
        mov ax, cx
        stosw
    STI
    
    ; Remove ENV-data
    mov di, 02ch
    mov es, [di]
    mov ah, 49h
    int 21h

    ret

hooks_install endp


; Uninstall hooks.
;
; This procedure provides deinstalation
; of hooks INT8 & INT9.

hooks_uninstall proc
    
    ; Uninstall INT8
    mov bx, cs:word ptr hooks_int8_old8
    mov di, cs:word ptr hooks_int8_old8 + 2 
    
    push ds
    xor ax, ax
    push ax
    pop ds
    
    CLI
        mov word ptr ds:32, bx
        mov word ptr ds:34, di
    STI
    
    pop ds
        
    ; Uninstall INT9
    mov bx, cs:word ptr hooks_int9_old9
    mov di, cs:word ptr hooks_int9_old9 + 2 
        
    push ds
    xor ax, ax
    push ax
    pop ds
        
    CLI
        mov word ptr ds:36, bx
        mov word ptr ds:38, di
    STI
        
    pop ds
        
    ret

hooks_uninstall endp

