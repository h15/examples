; Nasm file

section .data
    len     equ 129
    buffer  times 128 db 0
            db 0x0A
    a       times 64 db 0x11
    b       times 63 db 0
            db 0x2
    c       times 64 db 0
    buf     db '   '
    buf_start	equ 0
    buf_end		equ 0

section .text

global _start

_start:
    mov rsi, a
    mov al, 0x11
    call longShl
    mov rsi, a
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
    
    mov rcx, 63
    .loop:
        inc rsi
        mov al, [rsi]
        call al2buf
        call printBuf
    loop .loop
    
    pop rsi
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  uses a, b, c
;;  c = a + b
;;
longAddABC:
    push rax
    push rbx
    push rcx
    push rsi
    
    mov rcx, 63
    .loop:
        mov al, [a + rcx]
        mov bl, [b + rcx]
        adc al, bl
        mov [c + rcx], al
    loop .loop
    
    pop rsi
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
    push rsi
    
    mov rcx, 63
    .loop:
        mov al, [a + rcx]
        mov bl, [b + rcx]
        sbb al, bl
        mov [c + rcx], al
    loop .loop
    
    pop rsi
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
    
    xor ah, ah
    
    mov rcx, 63
    .loop:
        mov al, [a + rcx]
        mov bl, [b + rcx]
        mov [c + rcx], ah
        mul bl
        add [c + rcx], al
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
    push rsi
    
    mov bl, al
    xor ah, ah
    
    mov rcx, 63
    .loop:
        mov al, [rsi + rcx]
        mov [c + rcx], ah
        mul bl
        add [c + rcx], al
    loop .loop
    
    pop rsi
    pop rcx
    pop rbx
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  << [rsi]
;;
longShl:
    push rax
    push rbx
    push rcx
    push rsi
    
    xor ah, ah
    
    mov rcx, 63
    .loop:
        mov al, [rsi + rcx]
        mov [rsi + rcx], ah
        mov ah, al
    loop .loop
    
    pop rsi
    pop rcx
    pop rbx
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
