; 2、所有子过程采用堆栈进行参数传递，完成如下功能：
; （1）从键盘输入12个整数保存在内存变量中RAWDATA中，并把输入的12个整数用十进制在屏幕上显示出来；
; （2）采用冒泡法，对RAWDATA中的12个整数进行升序排列，并把排序结果用十进制在屏幕上显示出来；

DATAS SEGMENT
    ARR_LENGTH_WORD = 12D
    ; RAWDATA DW  12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
    RAWDATA DW ARR_LENGTH_WORD DUP(0)
DATAS ENDS

STACKS SEGMENT
    STACK_CAPACITY_BYTE = 256D
    STACK_CAPACITY DB STACK_CAPACITY_BYTE DUP(0)
STACKS ENDS    

FUNCTIONS SEGMENT
    ASSUME CS:FUNCTIONS
    BUBBLE  PROC    FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI

        LEA     SI, RAWDATA
        MOV     CX, ARR_LENGTH_WORD
        DEC     CX
        JZ      BUBBLE_END
        BUBBLE_OUTER_LOOP:
            PUSH    AX
            PUSH    BX
            PUSH    CX
            PUSH    SI

            ; CALL    FAR PTR PRINT_ARRAY

            LEA     SI, RAWDATA
            BUBBLE_INNER_LOOP:

                MOV     AX, [SI]
                MOV     BX, [SI + 2]
                CMP     AX, BX


                JBE     BUBBLE_INNER_LOOP_CONTINUE
                XCHG    AX, BX
                MOV     [SI], AX
                MOV     [SI + 2], BX

                BUBBLE_INNER_LOOP_CONTINUE:
                    ADD     SI, 2
                    
                    DEC     CX
                    JNZ     BUBBLE_INNER_LOOP

            BUBBLE_INNER_LOOP_BREAK:
            POP     SI
            POP     CX
            POP     BX
            POP     AX

            ADD     SI, 02D
            DEC     CX
            JNZ     BUBBLE_OUTER_LOOP
            
        BUBBLE_END:
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX

        RET
    BUBBLE  ENDP

    ; 
    PRINT_NUM_DX   PROC    FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        
        MOV     BL, 10D
        MOV     CX, 1
        ONE:
            ; PUSH    DX
            MOV     AX, DX
            DIV     BL  ; 商在AL, 余数在AH
            PUSH    AX
            CMP     AL, 0
            JBE     ENDL
            MOV     DL, AL
            INC     CX
            JMP     ONE

        ENDL:
            POP     DX

            XCHG    DH, DL  ; 余数转入DL
            ADD     DL, 30H
            MOV     AH, 2   ; 输出
            INT     21H

            LOOP    ENDL

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
    PRINT_NUM_DX   ENDP

    PRINT_ARRAY PROC    FAR
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    SI

        MOV     CX, ARR_LENGTH_WORD
        LEA     SI, RAWDATA
        LOOP_START:
            MOV     DX, [SI]
            CALL    PRINT_NUM_DX
            ADD     SI, 2

            MOV     DL, ' '
            MOV     AH, 02H
            INT     21H
            LOOP    LOOP_START

        MOV     DL, 0DH
        MOV     AH, 02H
        INT     21H
        MOV     DL, 0AH
        MOV     AH, 02H
        INT     21H

        POP     SI
        POP     DX
        POP     CX
        POP     AX
        RET
        
    PRINT_ARRAY ENDP

    ; 输入 ARR_LENGTH_WORD 个十进制非负整数, 结果存数组
    ; 只能用一个非数字字符分割
    INPUT_ARRAY PROC    FAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI

        
        LEA     DI, RAWDATA
        MOV     CX, ARR_LENGTH_WORD
        NEWDIGIT:
            SUB     BX, BX
        NEWCHAR:
            MOV     AH, 01H
            INT     21H

            SUB     AL, '0'
            JB      INPUT_END
            CMP     AL, 09D
            JA      INPUT_END
            CBW

            XCHG    AX, BX
            MOV     DX, 10D
            MUL     DX
            ADD     AX, BX
            XCHG    AX, BX

            JMP     NEWCHAR

        INPUT_END:
            MOV     [DI], BX
            ADD     DI, 2

            DEC     CX
            JNZ     NEWDIGIT
        
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
    INPUT_ARRAY ENDP

    
FUNCTIONS ENDS   

CODES SEGMENT
    ASSUME CS:CODES, DS:DATAS, SS:STACKS
MAIN:
    MOV     AX, DATAS
    MOV     DS, AX
    MOV     AX, STACKS
    MOV     SS, AX
    MOV     SP, STACK_CAPACITY_BYTE
    

    CALL    INPUT_ARRAY
    ; CALL    PRINT_ARRAY 
    CALL    BUBBLE
    CALL    PRINT_ARRAY

    MOV     AH, 4CH
    INT     21H
    
CODES   ENDS
    END MAIN
