;1、编写一个完整程序，实现如下功能：键盘输入十进制整数保存在BX寄存器，
;分别以二进制、八进制、十进制和十六进制显示出来；  
          
DATAS SEGMENT
    INPUT  DB ">>>$"
    ENDL    DB 0DH, 0AH, '$'
DATAS ENDS               

STACKS SEGMENT
    STACK_CAPACITY = 64
    DB STACK_CAPACITY DUP(0)
STACKS ENDS
    
FUNC SEGMENT
    ASSUME CS:FUNC

    ; 输入字符转数字,结果存BX
    DECIBIN PROC FAR
        CALL    PRINTTIP

        PUSH    AX
        PUSH    CX
        PUSH    DX

        SUB     BX, BX
        MOV     CX, 10D

    NEWCHAR:
        MOV     AH, 01H
        INT     21H

        SUB     AL, '0'
        JL      EXIT
        CMP     AL, 09D
        JG      EXIT
        CBW

        XCHG    AX, BX
        MUL     CX
        ADD     AX, BX
        XCHG    AX, BX
        
        JMP NEWCHAR
        

    EXIT:
        POP     DX
        POP     CX
        POP     AX
        ; CALL    FAR PTR CRLF
        RET
    DECIBIN ENDP

    ; BX内容转16进制数的字符串,结果顺便输出
    BINIHEX PROC FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DS

        MOV     CH, 04D
    BINIHEX_ROTATE:
        MOV     CL, 04D
        ROL     BX, CL
        MOV     AL, BL
        AND     AL, 00001111B
        ADD     AL, '0'
        CMP     AL, '9'
        JBE     BINIHEX_PRINTIT
        ADD     AL, 'A' - ('9' + 01D)
        
    BINIHEX_PRINTIT:
        MOV     DL, AL
        CALL    PRINT_DL
        DEC     CH
        JNZ     BINIHEX_ROTATE

        POP     DS
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        CALL    FAR PTR CRLF
        RET
    BINIHEX ENDP

    ; BX内容转8进制数的字符串,结果顺便输出
    BINIOCT PROC FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        
        MOV     AX, BX
        ROL     BX, 1
        MOV     AL, BL
        AND     AX, 00000001B
        ADD     AL, '0'
        MOV     CH, 6
        JMP     BINIOCT_PRINTIT

    BINIOCT_ROTATE:
        MOV     CL, 03D
        ROL     BX, CL
        MOV     AL, BL
        AND     AL, 00000111B
        ADD     AL, '0'
    
    BINIOCT_PRINTIT:
        MOV     DL, AL
        CALL    PRINT_DL
        DEC     CH
        JNZ     BINIOCT_ROTATE

        POP     CX
        POP     BX
        POP     AX
        CALL    FAR PTR CRLF
        RET
    BINIOCT ENDP

    ; BX内容转2进制数的字符串,结果顺便输出
    BINIBIN PROC    FAR
        PUSH    AX
        PUSH    BX

        MOV     CH, 16
    BINIBIN_ROTATE:
        ROL     BX, 1
        MOV     AL, BL
        AND     AL, 01H
        ADD     AL, '0'
        MOV     DL, AL
        CALL    PRINT_DL
        DEC     CH
        JNZ     BINIBIN_ROTATE

        POP     BX
        POP     AX
        CALL    FAR PTR CRLF
        RET
    BINIBIN ENDP

    BINIDEC PROC    FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        
        MOV     CX, 1
        BINIDEC_BEGIN:
            MOV     AX, BX
            MOV     DL, 10D
            DIV     DL
            PUSH    AX
            CMP     AL, 0
            JZ      BINIDEC_END
            MOV     BL, AL
            ; SUB     BH, BH
            INC     CX
            JMP     BINIDEC_BEGIN

        BINIDEC_END:
            POP     DX
            XCHG    DH, DL
            ADD     DL, '0'
            MOV     AH, 02H
            INT     21H
            LOOP    BINIDEC_END


        POP     DX
        POP     CX
        POP     BX
        POP     AX
        CALL    FAR PTR CRLF
        RET
    BINIDEC ENDP

    PRINT_DL PROC NEAR
        PUSH    AX

        MOV     AH, 02H
        INT     21H

        POP     AX
        RET
    PRINT_DL ENDP

    CRLF PROC FAR
        PUSH    AX
        PUSH    DX

        LEA     DX, ENDL
        MOV     AH, 09H
        INT     21H

        POP     DX
        POP     AX
        RET
    CRLF ENDP

    PRINTTIP PROC NEAR
        PUSH    AX
        PUSH    DX

        LEA     DX, INPUT
        MOV     AH, 09H
        INT     21H

        POP     DX
        POP     AX
        RET
    PRINTTIP ENDP

FUNC ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATAS, SS:STACKS
MAIN:
    MOV     AX, DATAS
    MOV     DS, AX
    MOV     AX, STACKS
    MOV     SS, AX
    MOV     SP, STACK_CAPACITY
    MOV     CX, 05D ; 默认接受5次输入
    
REPEAT:    
    CALL    DECIBIN
    
    CALL    BINIBIN
    CALL    BINIOCT
    CALL    BINIDEC
    CALL    BINIHEX

    DEC     CX
    JNZ     REPEAT

    MOV     AH, 4CH
    INT     21H
CODES ENDS
    END MAIN
