; 2���޸��������ʵ������Ŀ�ģ�
; ��1���Ӽ����Ͻ���ɨ���룬������Ļ����ʾɨ�����ʮ�����ƣ�
; ��2�� ��ɨ������뻺�����ڣ���30���ڣ�����������ʱ������buffer overflow��Ϣ��������������ʱ������buffer not overflow��Ϣ.
; ��3�� �������Ĵ�СΪ16�ֽڡ�

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
   mov  ax , offset buffer ;��ʼ����������ַ�ͻ������ַ�����
   mov  addr_point , ax
   mov  count , 0
;********   
   mov al , 09h ;����9h���ж�����
   mov ah , 35h
   int 21h
   mov save_ip9 , bx
   mov save_cs9 , es
   mov dx , offset kbint ;�ѹ���kbint��ַ���ó�09h���ж�����
   push ds
   mov ax , seg kbint
   mov ds , ax
   mov al , 09h
   mov ah , 25h
   int 21h
   pop ds
   in al , 21h ;��������ж�
   and al , 0fdh
   out 21h , al
   mov ah , 09h ; ��Ļ����ʾ��ʾ��Ϣ
   lea dx , prompt
   int 21h
;*******
   sti ;����CPU��Ӧ�ⲿ�ж�
;*******
mov di , 0f000h ;�����̵ȴ����̵�����ʹ�ӡ�������
mainp:
   mov si , 01f0h
mainp1:
   dec si
   jnz mainp1
   dec di
   jnz mainp
;******
   mov ah , 02h ;��Ļ����ʾ�ַ�$��ʾ���������
   mov dl , '$'
   int 21h
;******
   cli  ;��ֹ��CPU��Ӧ�ⲿ��
;******
   push ds ;�ָ�09h�ж�����
   mov  dx , save_ip9
   mov  ax , save_cs9
   mov  ds , ax
   mov  al , 09h
   mov  ah , 25h
   int  21h
   pop  ds
    cmp count , 16
   jnz ov
   mov ah , 09h ; ��Ļ����ʾ��ʾ��Ϣ
   lea dx , message
   int 21h
   jmp endd 
 ov:
   mov ah , 09h ; ��Ļ����ʾ��ʾ��Ϣ
   lea dx , messageb
   int 21h 
endd:
   in al , 21h ;��������ж�
   and al , 0fdh
   out 21h , al
;******
   sti  ;����CPU��Ӧ�ⲿ�� 
   mov ax , 4c00h
   int 21h
main endp
 ;--------------------------------------------------------------
kbint proc near
      push ax
      push bx
      in al , 60h
      test al , 80h ;���԰��������ͷż�
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
      mov al , 20h  ;�������ж�
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
