; 2、修改下面程序，实现下列目的：
; （1）从键盘上接收扫描码，并在屏幕上显示扫描码的十六进制；
; （2） 将扫描码存入缓冲区内，在30秒内，当缓冲区满时，给出buffer overflow信息，当缓冲区不满时，给出buffer not overflow信息.
; （3） 缓冲区的大小为16字节。

dseg segment
   count       dw ?
   buffer      db 0fh dup(' ')
   addr_point  dw  buffer
   prompt      db 'please enter the character : '
               db 0dh,0ah,'$'
   message     db 'buffer overflow',0dh,0ah,'$'
   messageb    db 'buffer not overflow',0dh,0ah,'$'
   save_ip9    dw ?
   save_cs9    dw ?
dseg ends
cseg segment
   assume cs:cseg , ds:dseg
main proc far
start:
   mov  ax , dseg
   mov  ds , ax
   mov  ax , offset buffer ;初始化缓冲区地址和缓冲区字符数量
   mov  addr_point , ax
   mov  count , 0
;********   
   mov al , 09h ;保存9h的中断向量
   mov ah , 35h
   int 21h
   mov save_ip9 , bx
   mov save_cs9 , es
   mov dx , offset kbint ;把过程kbint地址设置成09h的中断向量
   push ds
   mov ax , seg kbint
   mov ds , ax
   mov al , 09h
   mov ah , 25h
   int 21h
   pop ds
   in al , 21h ;允许键盘中断
   and al , 0fdh
   out 21h , al
   mov ah , 09h ; 屏幕上显示提示信息
   lea dx , prompt
   int 21h
;*******
   sti ;允许CPU响应外部中断
;*******
mov di , 0f000h ;主过程等待键盘的输入和打印机的输出
mainp:
   mov si , 01f0h
mainp1:
   dec si
   jnz mainp1
   dec di
   jnz mainp
;******
   mov ah , 02h ;屏幕上显示字符$表示主程序结束
   mov dl , '$'
   int 21h
;******
   cli  ;禁止许CPU响应外部中
;******
   push ds ;恢复09h中断向量
   mov  dx , save_ip9
   mov  ax , save_cs9
   mov  ds , ax
   mov  al , 09h
   mov  ah , 25h
   int  21h
   pop  ds
    cmp count , 16
   jnz ov
   mov ah , 09h ; 屏幕上显示提示信息
   lea dx , message
   int 21h
   jmp endd 
 ov:
   mov ah , 09h ; 屏幕上显示提示信息
   lea dx , messageb
   int 21h 
endd:
   in al , 21h ;允许键盘中断
   and al , 0fdh
   out 21h , al
;******
   sti  ;允许CPU响应外部中 
   mov ax , 4c00h
   int 21h
main endp
 ;--------------------------------------------------------------
kbint proc near
      push ax
      push bx
      in al , 60h
      test al , 80h ;测试按键还是释放键
      jnz cont
 
      cmp count , 16
      jz cont
     mov bx , addr_point
      mov [bx] , al
      call disp
      inc bx
      inc count
      mov addr_point , bx
 
cont:     
      cli
      mov al , 20h  ;结束外中断
      out 20h , al
 
      pop ax
      pop bx
      iret
kbint endp
 ;-------------------------------------------------------
disp proc near
       push ax
       push bx
       push dx 
        mov ch , 2
       mov cl , 4
nestb:
       rol al , cl
       push ax
       mov dl , al
       and dl , 0fh
       or dl , 30h
       cmp dl , 3ah
       jl  dispit
       add dl , 7h
dispit:
       mov ah , 2
       int 21h
       pop ax
       dec ch
       jnz nestb
       mov ah , 2
       mov dl , ','
       int 21h
       pop dx
       pop bx
       pop ax
       ret
disp endp 
;---------------------------------------------------------
cseg ends
end start             
