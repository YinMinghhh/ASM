;1、编写一个完整程序，实现如下功能：键盘输入十进制整数保存在BX寄存器，
;分别以二进制、八进制、十进制和十六进制显示出来；  

def_str macro name, cap
    name db cap, cap, cap dup('0dh') 
endm
          
datas segment
    capacity = 10
    def_str bin, capacity
    def_str oct, capacity
    def_str dec_,capacity
    def_str hex, capacity 
datas ends               

stacks segment
    ;
stacks ends
    
codes segment
     assume cs:codes, ds:datas, ss:stacks
     start:
     
     end start
codes ends            