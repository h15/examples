;	Nasm file
global sum:function

%define a ebp+08h
%define b ebp+0Ch

sum:
        push ebp
        mov ebp, esp
        mov eax, [a]
        add eax, [b]
        pop ebp
        ret

