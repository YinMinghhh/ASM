;-------数据段定义--------
DATA	SEGMENT
low16 DW 0
high16 DW 0
;low16 DW ?
;high16 DW ?
shrL DW 0
shrH DW 0
rorL DW 0
rorH DW 0
DATA	ENDS

;------宏定义-------
SHR32 MACRO X, Y, N
    mov ax, X
    mov bx, Y
    mov cl, N
    shr bx, cl
    rcr ax, cl
    mov shrL, ax
    mov shrH, bx
ENDM

ROR32 MACRO X, Y, N
    mov ax, X
    mov bx, Y
    mov cl, N
    ror bx, cl
    rcr ax, cl
    mov rorL, ax
    mov rorH, bx
ENDM


;-------代码段定义---------
CODE    SEGMENT
        assume cs:code, ds:data

start:
        mov ax, data

        mov ds , ax

        call input

        mov ax, data
        mov ds, ax

        SHR32 low16 , high16 , 2
        ROR32 low16 , high16 , 2

        call output

        mov ah , 4ch

        int 21h

        
; 输入子过程定义
input PROC NEAR
    push bp ; 保存bp寄存器的值到堆栈中，以便在返回时恢复它的值。
    mov bp, sp ; 将bp寄存器设置为sp寄存器的值，以便访问堆栈中的参数。
    
    ; 输入low16变量的值。
    mov ah, 01h ; 设置ah寄存器为01h，以便调用DOS中断获取键盘输入。
    int 21h ; 调用DOS中断获取键盘输入。
    sub al, '0' ; 将al寄存器减去'0'，以便将字符转换为数字。
    mov cl, 4
    shl al, cl ; 将al寄存器左移4位，以便将高4位设置为输入的数字。
    mov bx, offset low16
    mov [bx+1], al ; 将al寄存器的值保存到low16变量的高8位中。
    
    ; 输入low16变量的值。
    mov ah, 01h ; 设置ah寄存器为01h，以便调用DOS中断获取键盘输入。
    int 21h ; 调用DOS中断获取键盘输入。
    sub al, '0' ; 将al寄存器减去'0'，以便将字符转换为数字。
    mov bx, offset low16
    or [bx+1], al ; 将al寄存器的值或运算到low16变量的高8位中。

    ;回车换行
        MOV AH,02H		
	    MOV	DL,0DH
	    INT	21H
	    MOV	DL,0AH
        INT 21H
    
    ; 输入high16变量的值。
    mov ah, 01h ; 设置ah寄存器为01h，以便调用DOS中断获取键盘输入。
    int 21h ; 调用DOS中断获取键盘输入。
    sub al, '0' ; 将al寄存器减去'0'，以便将字符转换为数字。
    mov cl, 4
    shl al, cl ; 将al寄存器左移4位，以便将高4位设置为输入的数字。
    mov bx, offset high16
    mov [bx+1], al ; 将al寄存器的值保存到high16变量的高8位中。

; 输入high16变量的值。
mov ah, 01h ; 设置ah寄存器为01h，以便调用DOS中断获取键盘输入。
int 21h ; 调用DOS中断获取键盘输入。
sub al,'0' ; 将al寄存器减去'0'，以便将字符转换为数字。
mov bx, offset high16
or [bx+1] , al; 将al寄存器的值或运算到high16变量的高8位中。

pop bp; 恢复bp寄存器的值从堆栈中。

ret; 返回到调用处。

input ENDP

; 十六进制输出子过程定义
print_hex PROC NEAR
    push bx
    push cx
    push dx

    mov bx, 0
    mov cx, 4

print_hex_loop:
    
    rol ax, 1
    rol ax, 1
    rol ax, 1
    rol ax, 1
    mov dx, ax
    and dx, 0Fh
    cmp dl, 9
    jbe print_hex_digit
    add dl, 7

print_hex_digit:
    add dl, '0'
    mov ah, 0Eh
    int 10h

    dec cx
    jnz print_hex_loop

    pop dx
    pop cx
    pop bx
    ret
print_hex ENDP


; 输出子过程定义
output PROC NEAR
    push bp ; 保存bp寄存器的值到堆栈中，以便在返回时恢复它的值。
    mov bp, sp ; 将bp寄存器设置为sp寄存器的值，以便访问堆栈中的参数。
    
    ; 输出shrL变量的值。
    mov ax, shrL ; 将shrL变量的值加载到ax寄存器中。
    call print_hex ; 调用print_hex子过程，将ax寄存器中的值以十六进制形式输出到屏幕上。
    
    ; 输出shrH变量的值。
    mov ax, shrH ; 将shrH变量的值加载到ax寄存器中。
    call print_hex ; 调用print_hex子过程，将ax寄存器中的值以十六进制形式输出到屏幕上。
    
    ; 输出换行符。
    mov dl, 0Ah ; 设置dl寄存器为0Ah，以便输出换行符。
    mov ah, 02h ; 设置ah寄存器为02h，以便调用DOS中断输出字符。
    int 21h ; 调用DOS中断输出字符。
    
    ; 输出rorL变量的值。
    mov ax, rorL ; 将rorL变量的值加载到ax寄存器中。
    call print_hex ; 调用print_hex子过程，将ax寄存器中的值以十六进制形式输出到屏幕上。
    
    ; 输出rorH变量的值。
    mov ax, rorH ; 将rorH变量的值加载到ax寄存器中。
    call print_hex ; 调用print_hex子过程，将ax寄存器中的值以十六进制形式输出到屏幕上。

    pop bp; 恢复bp寄存器的值从堆栈中。

    ret; 返回到调用处。

output ENDP

.loop:
    xor dx , dx; 将dx寄存器清零。

    div bx; 将ax寄存器除以bx寄存器，并将余数保存在dx寄存器中。

    push dx; 将dx寄存器压入堆栈。

    inc cx; 增加cx计数器。

    cmp ax , 0; 比较ax和0。

    jne .loop; 如果不等于0，则跳转到.loop标签处继续执行。

.print:
    pop dx; 弹出dx寄存器。

    add dl , '0'; 将dl加上'0'，转换为字符。

    cmp dl , '9'; 比较dl和'9'。

    jbe .skip; 如果小于等于'9'，则跳转到.skip标签处继续执行。

    add dl , 7; 否则将dl加上7，转换为A~F之间的字符。

.skip:
mov ah , 02h; 设置ah为02h，准备调用DOS中断输出字符


CODE	ENDS

END     start