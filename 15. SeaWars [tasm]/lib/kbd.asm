
; KEYBOARD
;
; This is an include file for keyboard high-level interface using.
; It's part of SeaWars game.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.

kbd_buffer          db 8 dup (0), 13,10,36
kbd_buffer_size     db 8
kbd_buffer_start    db 0
kbd_buffer_end      db 0
kbd_buffer_isEmpty  db 1

; kbd_buffer -> reg AL
;
; Shift one byte from buffer to AL.

kbd_shiftKey proc

    push si
    push bx
    
    ; Exit with 0 on empty queue.
    mov al, 0
    mov bl, kbd_buffer_isEmpty
    cmp bl, 1
    je kbd_shiftKey_EXIT
    
    ; Get buffer address.
    mov si, offset kbd_buffer
    
    ; Get "first" cell address.
    xor bh, bh
    mov bl, kbd_buffer_start
    add si, bx            
    
    ; Insert key into AL.
    mov al, [si]
    mov bl, 0
    mov [si], bl
    
    ; Move right start's ptr.
    inc kbd_buffer_start
    
    ; start (mod size)
    mov bh, kbd_buffer_start
    mov bl, kbd_buffer_size
    
    cmp bh, bl
    jne kbd_shiftKey_skip
    
        mov kbd_buffer_start, 0
    
    kbd_shiftKey_skip:
    
    ; Is Empty
    mov bh, kbd_buffer_start
    mov bl, kbd_buffer_end
    
    cmp bh, bl
    jne kbd_shiftKey_EXIT
    
        mov kbd_buffer_isEmpty, 1
    
    kbd_shiftKey_EXIT:
        pop bx
        pop si

        ret

kbd_shiftKey endp


; reg AL -> kbd_buffer
;
; Move al to round-buffer 'kbd_buffer'.
; Buffer has 'kbd_buffer_size' cells.

kbd_pushKey proc

    push si
    push bx
    
    ; Get buffer address.
    mov si, offset kbd_buffer
    
    ; Get "free" cell address.
    xor bh, bh
    mov bl, kbd_buffer_end
    add si, bx            
    
    ; Insert key into buffer.
    mov [si], al
    
    ; Move right end's ptr.
    inc kbd_buffer_end
    
    ; end (mod size)
    mov bh, kbd_buffer_end
    mov bl, kbd_buffer_size
    
    cmp bh, bl
    jne kbd_pushKey_skip
    
        mov kbd_buffer_end, 0
    
    kbd_pushKey_skip:
    
    
    ; If buffer overflows
    mov bh, kbd_buffer_end
    mov bl, kbd_buffer_start
    
    cmp bh, bl
    jne kbd_pushKey_EXIT

        inc kbd_buffer_start
        
        ; start (mod size)
        mov bh, kbd_buffer_start
        mov bl, kbd_buffer_size
        
        cmp bh, bl
        jne kbd_pushKey_EXIT

            mov kbd_buffer_start, 0

    kbd_pushKey_EXIT:
        ; Queue is not empty now.
        mov kbd_buffer_isEmpty, 0
    
        pop bx
        pop si

        ret

kbd_pushKey endp
