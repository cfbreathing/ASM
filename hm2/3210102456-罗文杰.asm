CODE SEGMENT
           ASSUME CS:CODE
    MAIN:  
           JMP    START
           i      DB, 00H

    CTOH:  ; 将AL中的char转化为十六进制数
           CMP    AL, 41H
           JB     IS_NUM
           SUB    AL, 7H
    IS_NUM:SUB    AL, 30H
           RET

    HTOC:  ; 将AL中的十六进制数转化为char
           CMP    AL, 0AH
           JB     TO_HUN
           ADD    AL, 7H
    TO_HUN:ADD    AL, 30H
           RET

    START: 
           MOV    AH, 01H
           INT    21H
           CALL   CTOH
           MOV    BL, AL
           SHL    BL, 4
           INT    21H
           CALL   CTOH
           OR     BL, AL
           MOV    [i], BL

           XOR    CL, CL
           MOV    AX, 0B800H
           MOV    ES, AX
           XOR    DI, DI
          
    OUTPUT:
           MOV    BL, [i]
           ADD    BL, CL
           MOV    AL, BL
           MOV    BYTE PTR ES:[DI], AL
           MOV    BYTE PTR ES:[DI+1], 7CH
           SHR    AL, 4
           CALL   HTOC
           MOV    BYTE PTR ES:[DI+2], AL
           MOV    BYTE PTR ES:[DI+3], 1AH
           MOV    AL, BL
           AND    AL, 0FH
           CALL   HTOC
           MOV    BYTE PTR ES:[DI+4], AL
           MOV    BYTE PTR ES:[DI+5], 1AH
           ADD    DI, 0A0H
           INC    CL
           CMP    CL, 10H
           JB     OUTPUT

           MOV    AH, 0
           INT    16H
           MOV    AH, 4CH
           INT    21H
CODE ENDS
     END START