assume cs:C_SEG, ds:D_SEG, es:E_SEG

D_SEG segment
    ; AUGW label word
    AUGEND dd 99251
    SUM dd ?
D_SEG ends

E_SEG segment
    ; ADDW label word
    ADDEND dd -15962
E_SEG ends

C_SEG segment
start:
    ; push ds
    ; sub ax, ax
    ; push ax
    mov ax, D_SEG
    mov ds, ax
    mov ax, E_SEG
    mov es, ax
    ;
    mov ax, word ptr AUGEND
    mov bx, word ptr AUGEND + 2
    add ax, es: word ptr ADDEND
    adc bx, es: word ptr ADDEND + 2
    mov word ptr SUM, ax
    mov word ptr SUM + 2, bx

    mov ah, 4ch
    int 21h
C_SEG ends
end start