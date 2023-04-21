; 6、输入下面程序并调试运行,当BL寄存器分别为0FFH、0FH和F0H时请给出程序执行后屏幕显示内容。

B_A SEGMENT
   B_T DW  R1
       DW  R2
       DW  R3
       DW  R4
       DW  R5
       DW  R6
       DW  R7
       DW  R8
B_A ENDS

CODE SEGMENT
    ASSUME CS:CODE , DS : B_A
    MAIN PROC FAR
START:
        MOV     AX , B_A
        MOV     DS , AX
        MOV     BL,0FFH;0F0H  0FH
        MOV     CX,8
        XOR     AL, AL
        LEA     SI , B_T
        L:  
            SHR     BL , 1
            JNB  NOT_YET
            JMP  WORD PTR[SI]
        NOT_YET:
            ADD SI, TYPE B_T
            JMP L    
        R1: 
        ADD AL,1
        MOV DL,31H
        MOV AH , 02
        INT 21H
        JMP SHORT EXIT
        R2: 
        ADD AL,1
        MOV DL,32H
        MOV AH , 02
        INT 21H
        JMP SHORT EXIT
        R3:     
        ADD AL,1
        MOV DL,33H
        MOV AH , 02
        INT 21H
        JMP SHORT EXIT
        R4: 
        ADD AL,1
        MOV DL,34H
        MOV AH , 02
        INT 21H
        JMP SHORT EXIT
        R5: 
        ADD AL,1
        MOV DL,35H
        MOV AH , 02
        INT 21H
            JMP SHORT EXIT
        R6: 
        ADD AL,1
        MOV DL,36H
        MOV AH , 02
        INT 21H
            JMP SHORT EXIT
        R7: 
        ADD AL,1
        MOV DL,37H
        MOV AH , 02
        INT 21H
            JMP SHORT EXIT
        R8: 
        ADD AL,1
        MOV DL,38H
        MOV AH , 02
        INT 21H
        EXIT: 
            MOV DL , AL
            ADD DL,30H
            MOV AH , 02
            INT 21H
            LOOP L
            MOV AX, 4C00H
            INT 21H
    MAIN ENDP
CODE ENDS
    END START	

