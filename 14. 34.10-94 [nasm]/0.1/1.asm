; Nasm file

section .data
    len     equ 129
    buffer  times 128 db 0
            db 0x0A
    a       db 0x12
            db 0x25
            db 0x00
            times 61 db 0
    b       db 0x11
            db 0x12
            db 0x00
            times 61 db 0
            
    c       times 64 db 0
    d       times 64 db 0
    
    buf     db '   '
    buf_start	equ 0
    buf_end		equ 0

section .text

global _start

_start:
    ;mov rsi, c
    ;call longFlush
    ;mov al, 0x2
    mov rsi, a
    mov rdi, b
    
    ;call longGreater2
    ;mov al, dl
    ;call al2buf
    ;call printBuf
    
    call longMod
    mov rsi, c
    call print512bits

_exit0:
    mov eax, 1
    mov ebx, 0
    int 0x80
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readToBuffer:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, len
    int 0x80
    ret
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printBuffer:
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, len
    int 0x80
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printBuf:
    push rax
    push rbx
    push rcx
    push rdx
    
    mov eax, 4
    mov ebx, 1
    mov ecx, buf
    mov edx, 3
    int 0x80
    
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  @param rsi
;;
print512bits:
    push rax
    push rbx
    push rcx
    push rsi
    
    mov rcx, 64
    .loop:
        mov al, [rsi]
        call al2buf
        call printBuf
        inc rsi
    loop .loop
    
    pop rsi
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  uses c
;;  c = rsi + rdi
;;
longAdd:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    xor rdx, rdx
    
    mov rcx, 64
    .loop:
        mov al, [rsi + rdx]
        mov bl, [rdi + rdx]
        adc al, bl
        mov [c + rdx], al
        inc rdx
    loop .loop
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  uses a, b, c
;;  c = rsi - rdi
;;
longSub:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    xor rdx, rdx
    
    mov rcx, 64
    .loop:
        mov al, [rsi + rdx]
        mov bl, [rdi + rdx]
        sbb al, bl
        mov [c + rdx], al
        inc rdx
    loop .loop
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  uses a, b, c, d
;;  c = a * b
;;
longMul:
    push rax
    push rbx
    push rcx
    push rsi
    
    xor rbx, rbx
    
    mov rsi, c
    call longFlush
    
    mov rcx, 64
    .loop:
        mov rsi, c
        mov rdi, d
        call longMov
        
        mov al, [b + rbx]
        mov rsi, a
        call longShortMul
        
        ; cyclical shift
            push rcx
            
            mov rcx, rbx
            cmp rcx, 0
            je .if
                .shift:
                    mov rsi, c
                    call longShr
                loop .shift
            .if:
            
            pop rcx
        
        mov rsi, d
        mov rdi, c
        call longAdd
        
        inc rbx
    loop .loop
    
    pop rsi
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  c = [rsi] * al
;;
longShortMul:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov bl, al
    xor ah, ah
    xor rdx, rdx
    
    mov rcx, 64
    .loop:
        mov al, [rsi + rdx]
        mov [c + rdx], ah
        mul bl
        add [c + rdx], al
        inc rdx
    loop .loop
    
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  [rsi] = 0
;;
longFlush:
    push rcx
    
    mov rcx, 63
    .loop:
        mov byte [rsi + rcx], 0
    loop .loop
    
    pop rcx
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  >> [rsi]
;;
longShr:
    push rax
    push rbx
    push rcx
    push rsi
    
    xor ah, ah
    xor rbx, rbx
    
    mov rcx, 64
    .loop:
        mov al, [rsi + rbx]
        mov [rsi + rbx], ah
        mov ah, al
        inc rbx
    loop .loop
    
    pop rsi
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  [rdi] = [rsi]
;;
longMov:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    
    xor rdx, rdx
    
    mov rcx, 64
    .loop:
        mov al, [rsi + rdx]
        mov [rdi + rdx], al
        inc rdx
    loop .loop
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  c = [rsi] mod [rdi]
;;
longMod:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    
    xor rdx, rdx
    
    .while:
    
        call longGreater2
        cmp rdx, 0
        jne .if
        ; rdx == 0
            mov rdi, c
            call longMov
            jmp .endwhile
        .if:
        ;cmp rdx, 1
        ;jne .elsif
        ; rdx != 0
            push rdi
            
            call longSub
            
            mov rdi, rsi,
            mov rsi, c
            
            pop rdi
            jmp .endif
        ;.elsif:
        ; rdx > 1
        ;    push rdi
        ;    push rsi
        ;        
        ;        call longShr
        ;    
        ;    pop rsi
        ;    pop rdi
        .endif:
        
    jmp .while
    .endwhile:
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  How much [rsi] greater than [dsi]
;;  @return rdx (0|1)
;;
longGreater2:
    push rax
    push rcx
    push rsi
    push rdi
    
    xor rdx, rdx
    
    mov rcx, 64
    .loop:
        mov al, [rsi + rcx - 1]
        mov ah, [rdi + rcx - 1]
        
        cmp al, 0
        jne .if
        ; al == 0
            cmp ah, 0
            jne .if1
            ; ah == 0
                jmp .endif
            .if1:
                xor rdx, rdx
                jmp .endloop
        
            jmp .endif
        .if:
        ; al != 0
            cmp ah, 0
            jne .if2
            ; ah == 0
                mov rdx, 1
                jmp .endloop
            .if2:
                cmp al, ah
                jl .if21
                    mov rdx, 1
                    jmp .endloop
                .if21:
                    mov rdx, 0
                    jmp .endloop
        
            jmp .endif
            
        .endif:
        
    loop .loop
    .endloop:
    
    pop rdi
    pop rsi
    pop rcx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  How much [rsi] greater than [dsi]
;;  @return rbx
;;
longGreater:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    
    xor rdx, rdx
    xor rbx, rbx
    
    mov rcx, 64
    .loop:
        mov al, [rsi + rdx]
        mov ah, [rdi + rdx]
        
        cmp rdx, 0
        jne .if
        ; rdx == 0
            cmp al, 0
            jne .if1
            ; rdx == 0, al == 0
                cmp ah, 0
                jne .if12
                ; rdx == 0, al ==0, ah == 0 -> try again
                    jmp .endif
                
                .if12:
                ; rdx == 0, al ==0, ah != 0 -> gotcha! return 0
                    jmp .endloop
            
            .if1:
            ; rdx == 0, al != 0
                cmp ah, 0
                jne .if2
                ; rdx == 0, al != 0, ah == 0 -> rdx++
                    inc rdx
                    jmp .endif
                .if2:
                ; rdx == 0, al != 0, ah != 0
                    cmp al, ah
                    jl .if21
                    ; rdx == 0, al != 0, ah != 0, al >= ah -> rdx++ and return
                        inc rdx
                        jmp .endloop
                    .if21:
                    ; rdx == 0, al != 0, ah != 0, al < ah -> return 0
                        jmp .endloop
                    
            jmp .endif ; never reached
        .if:
        ; rdx != 0
            cmp ah, 0
            jne .if_2
            ; rdx != 0, ah == 0 -> rdx++
                inc rdx
                jmp .endif
            .if_2:
            ; rdx != 0, ah != 0
                cmp al, ah
                jl .if_21
                ; rdx != 0, ah != 0, al >= ah -> rdx++ and return
                    inc rdx
                    jmp .endloop
                .if_21:
                ; rdx != 0, ah != 0, al < ah -> return rdx
                    jmp .endloop
            
        .endif:
        
    loop .loop
    .endloop:
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  From reg AL to BUF (byte)
;;
al2buf:
	push rsi
	push rax
	push rbx
	push rcx
	push rdx
	
	mov rsi, [buf]	; get buffer address
    mov dl, al
    and dl, 0b1111_0000
    and al, 0b0000_1111
    shr dl, 4
    
    ; if / else
    ; rdx to first byte of buf
    cmp dl, 10
    jl .dec1
        add dl, 'A' - 10
        jmp .write1
    .dec1:
        add dl, '0'
    .write1:
    
    mov [buf], dl
    
    ; if / else
    ; rax to first byte of buf
    cmp al, 10
    jl .dec2
        add al, 'A' - 10
        jmp .write2
    .dec2:
        add al, '0'
    .write2:
    
    mov [buf+1], al
	
.out:
    pop rdx
	pop rcx
	pop rbx
	pop rax
	pop rsi
	
	ret
