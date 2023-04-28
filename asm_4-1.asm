DSEG SEGMENT
    GAP_TIME DW 1                                 ;����������ʱ��
    COUNT    DW 10                                ;�����������
    MESS     DB 'THE BELL IS RING',0DH,0AH,'$'    ;����Ļ����ʾ���ַ���
DSEG ENDS
CSEG SEGMENT
           ASSUME CS:CSEG , DS:DSEG
MAIN PROC FAR
    START: 
           MOV    AX , DSEG
           MOV    DS , AX
           MOV    AL , 1CH             ;����1CHԭ�ж����������ջ��
           MOV    AH , 35H
           INT    21H
           PUSH   ES
           PUSH   BX
           PUSH   DS                   ;�������������Ϊ1CH�ж�����
           MOV    DX,OFFSET RING
           MOV    AX,SEG RING
           MOV    DS,AX
           MOV    AL,1CH
           MOV    AH,25H
           INT    21H
           POP    DS
           IN     AL ,21H              ;����ʱ���ж�
           AND    AL , 11111110B
           OUT    21H , AL
           STI                         ;����CPU��Ӧ�ж�

           MOV    DI , 20000           ;�����̵�ʱ���ӳ٣��Ա��ڸ�ʱ���ӳ��ڽ��ж�ʱ�жϴ���
    DELAY1:
           MOV    SI , 30000

    DELAY2:
           DEC    SI
           JNZ    DELAY2

           CMP    DI, 0
           JZ     EXIT
           DEC    DI
           JNZ    DELAY1

           POP    DX                   ;�ָ�ԭ�����ж�����
           POP    DS
           MOV    AL ,1CH
           MOV    AH ,25H
           INT    21H
           MOV    AX , 4C00H
           INT    21H
MAIN ENDP

RING PROC NEAR
           PUSH   DS                   ;����Ĵ�������
           PUSH   AX
           PUSH   CX
           PUSH   DX
           MOV    AX , DSEG
           MOV    DS, AX
           STI                         ;����CPU��Ӧ�ж�

           CMP    COUNT , 0
           JZ     EXIT
        
           DEC    GAP_TIME
           JNZ    exit

           MOV    DX , OFFSET MESS     ;��ʾ�ַ�����Ϣ���ַ��������ԡ�$������
           MOV    AH ,09H
           INT    21H

           MOV    DX , 100             ;��������
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
           DEC    COUNT                ;�����������

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
