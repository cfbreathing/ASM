.386  ; 使用32位寄存器
; 数据段的定义
data SEGMENT use16
    BUF     DB 255, ?      
    INPUT   DB 255 DUP(0)    
    CRLF    DB 0DH, 0AH, 24H   
    NUM     DB 33 DUP(0)    
    NUM_PTE DB "$"        
    HEX     DB 8 DUP(48)  
    HEX_PTE DB "h", "$"     
data ends

; 代码段空间的定义
code SEGMENT  use16
           ASSUME CS:code,DS:data
    start:
           MOV    AX, data
           MOV    DS, AX         
           XOR    EAX, EAX
           XOR    EBX, EBX          
           JMP    getin           

    OP     DB     0               
    LASTOP DB     0                

    getin: 
           LEA    DX, BUF          
           MOV    AH, 0AH          
           INT    21H            
           LEA    DX, CRLF        
           MOV    AH, 9           
           INT    21H             

           LEA    DI, INPUT
           CALL   atoi            
           MOV    [LASTOP], DL    
           MOV    EAX, EBX        
    main: 
           INC    DI
           CALL   atoi        
           MOV    [OP], DL
           MOV    DL, [LASTOP]
           PUSH   EDX            
           CALL   calc      
           POP    EDX
           MOV    DL, [OP]
           MOV    [LASTOP], DL
           CMP    DX, 0DH        
           JBE    over
           JMP    main

    over: 
           PUSH   EAX 
           MOV    EBX, 0AH
           LEA    DI, NUM_PTE
    change:
           XOR    EDX, EDX
           DIV    EBX          
           ADD    DL, 30H
           DEC    DI
           MOV    [DI], DL      
           CMP    EAX, 00H
           JZ     putdec           
           JMP    change
    putdec:
           MOV    DX, DI            
           MOV    AH, 9             
           INT    21H               
           LEA    DX, CRLF
           MOV    AH, 9
           INT    21H
           POP    EAX              
           LEA    DI, HEX_PTE
           MOV    EBX, EAX        

    puthex:
           CMP    EAX, 00H
           JZ     done
           AND    AL, 0FH 
           CMP    AL, 0AH           
           JB     to_num
           ADD    AL, 7H
    to_num:
           ADD    AL, 30H
           DEC    DI
           MOV    [DI], AL         
           SHR    EBX, 4
           MOV    EAX, EBX
           JMP    puthex

    done:  
           LEA    DX, HEX        
           MOV    AH, 9           
           INT    21H             
           MOV    AH, 7
           INT    21H              
           MOV    AH, 4CH
           INT    21H            

    atoi:  
           XOR    EBX, EBX
           XOR    ECX, ECX
           XOR    EDX, EDX
    is_num:
           MOV    DL, [DI]
           CMP    DL, 30H
           JB     no_num
           SUB    DL, 30H
           MOV    ECX, EBX       
           SHL    EBX, 3            
           SHL    ECX, 1             
           ADD    EBX, ECX           
           ADD    EBX, EDX
           INC    DI
           JMP    is_num
    no_num:
           RET
       
    calc:  
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