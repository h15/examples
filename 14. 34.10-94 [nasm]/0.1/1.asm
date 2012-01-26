; Nasm file

section .data
    len     equ 129
    buffer  times 128 db 0
            db 0x0A
    a       times 64 db 0x11
    b       times 63 db 0x0
            db 0x2
            
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
    ;mov rsi, b
    call longMulABC
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
    mov edx, 2
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
longAddABC:
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
;;  c = a - b
;;
longSubABC:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    xor rdx, rdx
    
    mov rcx, 64
    .loop:
        mov al, [a + rdx]
        mov bl, [b + rdx]
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
;;  uses a, b, c
;;  c = a * b
;;
longMulABC:
    push rax
    push rbx
    push rcx
    push rsi
    
    xor rbx, rbx
    
    mov rcx, 64
    .loop:
        mov al, [b + rbx]
        mov rsi, a
        call longMulRefAlC
        mov rsi, c
        call longShr
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
longMulRefAlC:
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
    push rcx
    push rdx
    push rsi
    
    xor rdx, rdx
    
    mov rcx, 64
    .loop:
        mov al, [rsi + rdx]
        mov [rdi + rdx], ah
        inc rdx
    loop .loop
    
    pop rsi
    pop rdx
    pop rcx
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
