DATA SEGMENT
       s    DB 100 DUP(0)        ; 定义数组s
       t    DB 100 DUP(0)        ; 定义数组t
       CRLF DB 0AH,0DH,"$"       ; 回车换行
DATA ENDS

CODE SEGMENT
              ASSUME CS:CODE,DS:DATA
       START: 
              MOV    AX, DATA                      ; 重置DS的值
              MOV    DS, AX                        ; 让其指向DATA段
              LEA    SI, s                         ; 用寄存器SI存储s下标
              LEA    DI, t                         ; 用寄存器DI存储t下标
              XOR    BX, BX                        ; 重置BX为 0
       READ:  
              INC    BX
              MOV    AH, 01H
              INT    21H
              MOV    BYTE PTR [SI+BX-1], AL        ; 将输入的字符存入数组s中，因为BX有自增，所以寻址要减一
              CMP    AL, 0DH                       ; 判断按下的是否为回车键
              JNZ    READ
              MOV    BYTE PTR [SI+BX-1], 00H       ; 将回车转化为00H保存在数组中
              LEA    DX, CRLF
              MOV    AH, 09H
              INT    21H                           ; 输出回车换行
          
       GET:   
              MOV    AL, BYTE PTR [SI]             ; 取出数组s中的元素
              INC    SI
              CMP    AL, 00H                       ; 判断元素是否为00H，若是则开始输出
              JZ     PUTOUT
              CMP    AL, 20H                       ; 判断元素是否为空格，若是则跳过它
              JZ     GET
              CMP    AL, 61H                       ; 判断元素的ASCII码是否比'a'大
              JB     STROE
              CMP    AL, 7AH                       ; 判断元素的ASCII码是否比'z'小
              JA     STROE
              SUB    AL, 20H                       ; 判断元素从小写字母转化为大写字母
       STROE: 
              MOV    BYTE PTR [DI], AL             ; 将元素存储在t中
              INC    DI
              JMP    GET

       PUTOUT:
              LEA    DI, t
       PUTS:  
              MOV    DL, BYTE PTR [DI]
              CMP    DL, 00H                       ; 判断元素是否为00H，若是则停止输出
              JZ     PUTEND
              MOV    AH, 02H
              INT    21H
              INC    DI
              JMP    PUTS
       PUTEND:
              LEA    DX, CRLF
              MOV    AH, 09H
              INT    21H                           ; 输出回车换行
              MOV    AH, 4CH
              INT    21H
CODE ENDS
     END START