.386  ; 使用32位寄存器
; 数据段的定义
data SEGMENT use16
    BUF     DB 255, ?           ; 缓冲区
    INPUT   DB 255 DUP(0)       ; 真正读入的内容
    CRLF    DB 0DH, 0AH, 24H    ; 回车、换行、$
    NUM     DB 33 DUP(0)        ; 输出结果-十进制
    NUM_PTE DB "$"              ; 十进制输出结果的尾指针
    HEX     DB 8 DUP(48)        ; 输出结果-十六进制
    HEX_PTE DB "h", "$"         ; 十六进制输出结果的尾指针
data ends

; 代码段空间的定义
code SEGMENT  use16
           ASSUME CS:code,DS:data
    start:
           MOV    AX, data
           MOV    DS, AX             ; 初始化数据段
           XOR    EAX, EAX
           XOR    EBX, EBX           ; 将要使用的寄存器清空
           JMP    getin              ; 进入程序第一部分--读入

    OP     DB     0                  ; 记录当前运算符
    LASTOP DB     0                  ; 记录上一个运算符

    getin: 
           LEA    DX, BUF            ; \
           MOV    AH, 0AH            ; | 键盘输入到缓冲区
           INT    21H                ; /
           LEA    DX, CRLF           ; \
           MOV    AH, 9              ; | 输出一个回车
           INT    21H                ; /

           LEA    DI, INPUT
           CALL   atoi               ; 读入第一个数字和运算符
           MOV    [LASTOP], DL       ; 记录当前运算符，读到第二个运算符时再执行
           MOV    EAX, EBX           ; 将EBX中的内容放在EAX中，EAX作为储存结果的寄存器
    main:  ; 主循环，用一个指针遍历表达式
           INC    DI
           CALL   atoi               ; 读入一个数字和运算符
           MOV    [OP], DL
           MOV    DL, [LASTOP]
           PUSH   EDX                ; 将EDX压入栈中，防止后续计算溢出 
           CALL   calc               ; 开始计算
           POP    EDX
           MOV    DL, [OP]
           MOV    [LASTOP], DL
           CMP    DX, 0DH            ; 判断表达式是否遍历完毕
           JBE    over
           JMP    main

    over:  ; 运算结束，开始为输出做准备
           PUSH   EAX                ; 将EAX压入栈中，以便二次输出
           MOV    EBX, 0AH
           LEA    DI, NUM_PTE
    change:; 将EAX中的数字转化为ASCII存在NUM变量中
           XOR    EDX, EDX           ; 每次转换前清空EDX，防止DIV指令出错
           DIV    EBX                ; 利用除法得到EAX的末尾数
           ADD    DL, 30H
           DEC    DI
           MOV    [DI], DL           ; 存一位数字
           CMP    EAX, 00H
           JZ     putdec             ; 当EAX为0时代表转换结束
           JMP    change
    putdec:; 将结束输出到终端
           MOV    DX, DI             ; \
           MOV    AH, 9              ; | 直接将DI作为输出的头指针，输出10进制结果
           INT    21H                ; /
           LEA    DX, CRLF
           MOV    AH, 9
           INT    21H
           POP    EAX                ; 将EAX压出，开始二次输出
           LEA    DI, HEX_PTE
           MOV    EBX, EAX           ; 将EAX的值放在EBX中，用以后续的移位

    puthex:; 将EAX中的值转化为十六进制，存在HEX变量中
           CMP    EAX, 00H
           JZ     done
           AND    AL, 0FH 
           CMP    AL, 0AH            ; 判断AL中的值小于10还是大于10
           JB     to_num
           ADD    AL, 7H
    to_num:
           ADD    AL, 30H
           DEC    DI
           MOV    [DI], AL           ; 存一位数字
           SHR    EBX, 4
           MOV    EAX, EBX
           JMP    puthex

    done:  ; 结束
           LEA    DX, HEX            ; \
           MOV    AH, 9              ; | 输出十六进制结果
           INT    21H                ; /
           MOV    AH, 7
           INT    21H                ; 延迟，防止程序直接结束
           MOV    AH, 4CH
           INT    21H                ; 程序终止

    atoi:  ;将 DI 指向的字符串转化为数字存在 EBX 中，遇到运算符时停下，并将运算符存在DX中
           XOR    EBX, EBX
           XOR    ECX, ECX
           XOR    EDX, EDX
    is_num:
           MOV    DL, [DI]
           CMP    DL, 30H
           JB     no_num
           SUB    DL, 30H
           MOV    ECX, EBX           ; \
           SHL    EBX, 3             ; | 使用快速幂方法计算EBX*10   
           SHL    ECX, 1             ; | 利用EBX*10+EDX将字符串转化为数字
           ADD    EBX, ECX           ; /
           ADD    EBX, EDX
           INC    DI
           JMP    is_num
    no_num:
           RET
       
    calc:  ;开始计算，操作符在EAX和EBX中，运算符在DX中，结果储存在 EAX 中
           CMP    DL, 2AH
           JZ     is_mul
           CMP    DL, 2BH
           JZ     is_add
           CMP    DL, 2DH
           JZ     is_sub
           CMP    DL, 2FH
           JZ     is_div
           RET
    is_mul:
           MUL    EBX
           RET
    is_add:
           ADD    EAX, EBX
           RET
    is_sub:
           SUB    EAX, EBX
           RET
    is_div:
           XOR    EDX, EDX
           DIV    EBX
           RET
           
code ends
end start