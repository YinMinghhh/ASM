; 3、阅读下面程序，并通过调试运行，说明完成的功能；修改程序，把变量RESUL以十六进制显示出来：
; 程序:
STACK	SEGMENT STACK
    DW	100H DUP(?)
STACK	ENDS

DATA	SEGMENT
    RESUL	DW	?
DATA	ENDS

FUNC    SEGMENT
    ASSUME  CS:FUNC
    ;DESCRIPTION
    PRINT_RESULT_HEX PROC   FAR
        PUSH    AX
        PUSH    BX
        PUSH    DX
        PUSH    SI
        PUSH    DS

        MOV     AX, DATA
        MOV     DS, AX
        MOV     BX, RESUL
        MOV     CH, 4

        NEXT_CHAR:
            MOV     CL, 4
            ROL     BX, CL
            MOV     DL, BL
            AND     DL, 0FH
            ADD     DL, '0'
            MOV     AH, 02H
            INT     21H

            DEC     CH
            JNZ     NEXT_CHAR

        POP     DS
        POP     SI
        POP     DX
        POP     BX
        POP     AX
        RET
                
    PRINT_RESULT_HEX ENDP
FUNC    ENDS


CODE	SEGMENT
    MAIN	PROC	FAR
        ASSUME	CS:CODE,DS:DATA,SS:STACK
        START:	
            PUSH    DS
            SUB     AX, AX
            PUSH	AX
            MOV     AX, DATA
            MOV     DS, AX
            MOV     AX, 5
            CALL	FACT
            MOV     RESUL,  AX
            CALL    PRINT_RESULT_HEX
            RET
        FACT	PROC
            AND     AL, AL
            JNE     IIA
            MOV     AL, 1
            RET
            IIA:	
                PUSH	AX
                DEC     AL
                CALL	FACT
            X2:	
                POP	CX
                MUL	CL
            RET
        FACT	ENDP
    MAIN	ENDP
CODE	ENDS
    END	START
