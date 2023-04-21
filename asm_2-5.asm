; 5、采用堆栈传递方式，完成如下功能：
; （1）从键盘输入两个字符串“ABCDEF12345”和“ABCDEF67890”，分别存在变量STR1和STR2。
; （2）利用串操作指令对比两个字符串是否相等，如果相等则输出Y字符，否则输出N字符，
; 对比结束后，输出[SI]和[DI]指向单元字节内容和寄存器SI和DI的十进制数值。

.8086

DATAS   SEGMENT
    STR_LENGTH_BYTE =   13D
    STR1    DB  13D, 13D,  STR_LENGTH_BYTE DUP ('$')
    STR2    DB  13D, 13D,  STR_LENGTH_BYTE DUP ('$')
DATAS   ENDS

STACKS  SEGMENT
    STACK_LENGHT_WORD   =   100H
    DW  STACK_LENGHT_WORD   DUP (0)
STACKS  ENDS

FUNCS   SEGMENT
    ASSUME  CS:FUNCS
    ; 从键盘输入字符串，存放在DX指向的单元中
    INPUT_STR PROC  FAR
        PUSH    AX
        PUSH    DX
        PUSH    DI

        MOV     AH, 02H
        MOV     DL, '>'
        INT     21H

        LEA     DX, STR1
        MOV     AH, 0AH
        INT     21H

        CALL    FAR PTR CRLF

        MOV     AH, 02H
        MOV     DL, '>'
        INT     21H

        LEA     DX, STR2
        MOV     AH, 0AH
        INT     21H

        CALL    FAR PTR CRLF

        POP     DI
        POP     DX
        POP     AX
        RETF
    INPUT_STR ENDP

    CRLF    PROC    FAR
        PUSH    AX
        PUSH    DX

        MOV     AH, 02H
        MOV     DL, 0AH
        INT     21H

        MOV     AH, 02H
        MOV     DL, 0DH
        INT     21H

        POP     DX
        POP     AX
        RETF
    CRLF    ENDP

    ; 将DX指向的单元的十进制数值输出到屏幕上
    BINIDEC PROC    FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        MOV     CX, 1
        MOV     BL, 10D

        NEXT_DIGIT:
            MOV     AX, DX
            DIV     BL
            PUSH    AX
            CMP     AL, 0
            JZ      PRINTIT
            MOV     DL, AL
            INC     CX
            JMP     NEXT_DIGIT

        PRINTIT:
            POP     DX;
            XCHG    DH, DL; 余数转入DL
            ADD     DL, '0'
            MOV     AH, 02H
            INT     21H
            LOOP    PRINTIT
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RETF
    BINIDEC ENDP
FUNCS   ENDS    

CODES   SEGMENT
    ASSUME  CS:CODES, DS:DATAS, SS:STACKS

    RETURN_0    MACRO
        MOV     AH, 4CH
        INT     21H
    ENDM

MAIN:
    MOV     AX, DATAS
    MOV     DS, AX
    MOV     ES, AX
    MOV     AX, STACKS
    MOV     SS, AX
    MOV     SP, STACK_LENGHT_WORD
; 输入两个字符串
    CALL    INPUT_STR

; 比较两个字符串是否相等
    LEA     SI, STR1+2
    LEA     DI, STR2+2
    MOV     CX, STR_LENGTH_BYTE

    REPE    CMPSB
    JNE     NOT_EQUAL
    MOV     AH, 02H
    MOV     DL, 'Y'
    INT     21H
    JMP     AFTER_COMPAIR

NOT_EQUAL:
    MOV     AH, 02H
    MOV     DL, 'N'
    INT     21H

AFTER_COMPAIR:
; 输出SI和DI指向单元的字节内容
    CALL    CRLF
    MOV     DL, [SI]
    MOV     AH, 02H
    INT     21H
    CALL    CRLF
    MOV     DL, [DI]
    MOV     AH, 02H
    INT     21H
    CALL    CRLF

; 输出SI和DI的十进制数值
    MOV     DX, SI
    CALL    BINIDEC
    CALL    CRLF
    MOV     DX, DI
    CALL    BINIDEC
    CALL    CRLF

    RETURN_0
CODES   ENDS
    END MAIN    
