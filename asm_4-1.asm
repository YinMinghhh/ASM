DSEG SEGMENT
    GAP_TIME DW 1                                 ;控制响铃间隔时间
    COUNT    DW 10                                ;控制响铃次数
    MESS     DB 'THE BELL IS RING',0DH,0AH,'$'    ;在屏幕上显示的字符串
DSEG ENDS
CSEG SEGMENT
           ASSUME CS:CSEG , DS:DSEG
MAIN PROC FAR
    START: 
           MOV    AX , DSEG
           MOV    DS , AX
           MOV    AL , 1CH             ;保存1CH原中断向量进入堆栈中
           MOV    AH , 35H
           INT    21H
           PUSH   ES
           PUSH   BX
           PUSH   DS                   ;把响铃过程设置为1CH中断向量
           MOV    DX,OFFSET RING
           MOV    AX,SEG RING
           MOV    DS,AX
           MOV    AL,1CH
           MOV    AH,25H
           INT    21H
           POP    DS
           IN     AL ,21H              ;允许定时器中断
           AND    AL , 11111110B
           OUT    21H , AL
           STI                         ;允许CPU响应中断

           MOV    DI , 20000           ;主过程的时间延迟，以便在该时间延迟内进行定时中断处理
    DELAY1:
           MOV    SI , 30000

    DELAY2:
           DEC    SI
           JNZ    DELAY2

           CMP    DI, 0
           JZ     EXIT
           DEC    DI
           JNZ    DELAY1

           POP    DX                   ;恢复原来的中断向量
           POP    DS
           MOV    AL ,1CH
           MOV    AH ,25H
           INT    21H
           MOV    AX , 4C00H
           INT    21H
MAIN ENDP

RING PROC NEAR
           PUSH   DS                   ;保存寄存器内容
           PUSH   AX
           PUSH   CX
           PUSH   DX
           MOV    AX , DSEG
           MOV    DS, AX
           STI                         ;允许CPU响应中断

           CMP    COUNT , 0
           JZ     EXIT
        
           DEC    GAP_TIME
           JNZ    exit

           MOV    DX , OFFSET MESS     ;显示字符串信息，字符串必须以’$’结束
           MOV    AH ,09H
           INT    21H

           MOV    DX , 100             ;发声控制
           IN     AL ,61H
           AND    AL ,11111100B
    SOUND: 
           XOR    AL , 02H
           OUT    61H , AL

           MOV    CX ,1400
    WAIT1: 
           LOOP   WAIT1
           DEC    DX
           JNZ    SOUND

           MOV    GAP_TIME, 182
           DEC    COUNT                ;控制响铃次数

    EXIT:  
           CLI
           POP    DX
           POP    CX
           POP    AX
           POP    DS
           IRET
RING ENDP
CSEG ENDS
END START
