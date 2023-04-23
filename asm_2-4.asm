; 默认X为高16位, Y为低16位
SHR32   MACRO   X,  Y,  N
    PUSHF
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    DI
    PUSH    SI
    PUSH    DS

    MOV     CX, DATAS
    MOV     DS, CX
    LEA     DI, SHRH

    MOV     DX, WORD PTR X
    MOV     AX, WORD PTR Y

    MOV     CX, N
    SHR32_ONE_BIT:
        SHR     DX, 1
        RCR     AX, 1
    DEC     CX
    JNZ     SHR32_ONE_BIT

    MOV     [DI], DX
    MOV     [DI + 2], AX

    POP     DS
    POP     SI
    POP     DI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    POPF
ENDM

ROR32   MACRO   X,Y,N
    PUSHF
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    DI
    PUSH    SI
    PUSH    DS

    MOV     CX, DATAS
    MOV     DS, CX
    LEA     DI, RORH

    MOV     DX, WORD PTR X
    MOV     AX, WORD PTR Y

    MOV     CX, N
    ROR32_ONE_BIT:
        SUB     BX, BX

        SHL     DX, 1
        PUSHF
        TEST    AX, 1B
        JZ      ROR32_NOT_ADC
        OR      DX, 8000H
        ROR32_NOT_ADC:
        POPF
        RCR     AX, 1
        
    DEC     CX
    JNZ     ROR32_ONE_BIT

    MOV     [DI], DX
    MOV     [DI + 2], AX

    POP     DS
    POP     SI
    POP     DI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    POPF
ENDM

DATAS   SEGMENT
    HIGH16  DW  12
    LOW16   DW  23
    ; ==============================
    SHRH    DW  0
    SHRL    DW  0
    RORH    DW  0
    RORL    DW  0
    INPUT_TIPS  DB  'PLEASE INPUT TWO HEX NUMBERS: ', 0AH, 0DH, '>>>', '$'
DATAS   ENDS

STACKS  SEGMENT
    STACK_LENGHT_WORD = 100H
    DW  STACK_LENGHT_WORD   DUP(0)
STACKS  ENDS    

FUNC    SEGMENT
    ASSUME CS:FUNC
    PRINT_INPUT_TIPS    PROC    FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DS
        PUSH    SI

        LEA     DX, INPUT_TIPS
        MOV     AH, 09H
        INT     21H

        POP     SI
        POP     DS
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
    PRINT_INPUT_TIPS    ENDP

    ; 输入两个16位的十六进制数
    INPUT PROC  FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DS
        PUSH    SI


        MOV     CX, 2
        LEA     SI, HIGH16
    INPUT_NEW_DIGIT:
        SUB     BX, BX
        INPUT_NEW_CHAR:
            MOV     AH, 01H
            INT     21H

            ; 0-9
            SUB     AL, '0'
            JB      INPUT_NEW_DIGIT_END
            CMP     AL, 9D
            JBE     TO_DIGIT

            ; A-F 和 A-F
            ADD     AL, '0'
            AND     AL, 0DFH   ; 统一转为大写
            SUB     AL, 'A'
            JB      INPUT_NEW_DIGIT_END
            CMP     AL, 5D
            JA      INPUT_NEW_DIGIT_END
            ADD     AL, 10D

            TO_DIGIT:
            CBW

            XCHG    AX, BX
            MOV     DX, 16D
            MUL     DX
            ADD     AX, BX
            XCHG    AX, BX

            JMP     INPUT_NEW_CHAR

        INPUT_NEW_DIGIT_END:
            MOV     [SI], BX
            ADD     SI, 2

        DEC     CX
        JNZ     INPUT_NEW_DIGIT

        POP     SI
        POP     DS
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
    INPUT ENDP

    PRINT_SI_WORD   PROC    FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DS
        
        MOV     BX, [SI]
        MOV     CH, 4
        MOV     CL, 4

        PRINT_SI_WORD_NEXT_CHAR:
            ROL     BX, CL
            MOV     DL, BL
            AND     DL, 0FH
            ADD     DL, '0'
            CMP     DL, '9'
            JBE     PRINT_SI_WORD_PUTCHAR
            ADD     DL, 'A' - ('9' + 1)
            PRINT_SI_WORD_PUTCHAR:
                MOV     AH, 02H
                INT     21H
        DEC     CH
        JNZ     PRINT_SI_WORD_NEXT_CHAR

        POP     DS
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
    PRINT_SI_WORD   ENDP

    CRLF    PROC    FAR
        PUSH    AX
        PUSH    DX
        MOV     DL, 0DH
        MOV     AH, 02H
        INT     21H
        MOV     DL, 0AH
        MOV     AH, 02H
        INT     21H
        POP     DX
        POP     AX
        RET
    CRLF   ENDP 
FUNC    ENDS    

; MACROS  SEGMENT
;     ASSUME  CS:MACROS

; MACROS  ENDS    

CODES   SEGMENT
    ASSUME CS:CODES, DS:DATAS, SS:STACKS
MAIN:
    ; ============ 初始化 ================
    MOV     AX, DATAS
    MOV     DS, AX
    MOV     AX, STACKS
    MOV     SS, AX
    MOV     SP, STACK_LENGHT_WORD * 2
    ; ====================================

    ; 输入操作数
    CALL    PRINT_INPUT_TIPS
    CALL    INPUT

    ; ; 输出查看输入是否正确
    ; LEA     SI, HIGH16
    ; CALL    PRINT_SI_WORD
    ; LEA     SI, LOW16
    ; CALL    PRINT_SI_WORD
    ; CALL    CRLF

    ; 题目没有要求输入位移位数,这里默认位移1位
    ROR32   [HIGH16], [LOW16], 1D
    LEA     SI, RORH
    CALL    PRINT_SI_WORD
    LEA     SI, RORL
    CALL    PRINT_SI_WORD
    CALL    CRLF

    SHR32   [HIGH16], [LOW16], 1D
    LEA     SI, SHRH
    CALL    PRINT_SI_WORD
    LEA     SI, SHRL
    CALL    PRINT_SI_WORD
    CALL    CRLF

    ; ====================================
    MOV     AH, 4CH
    INT     21H
CODES   ENDS
    END MAIN
