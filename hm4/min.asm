.386
DATA    SEGMENT use16
    HITWORD     STRUC; SIZE 32
    LETTER      DB      21      DUP(0)
    SIZE_OF     DB      0
    X           DB      0
    Y           DB      0
    HITTED      DB      0
    STATUS      DB      0
    OLD_CAHR    DB      0
    OLD_COLOR   DB      0
    PX          DB      0
    PY          DB      0
    _BX         DB      0
    BY          DB      0
    HITWORD ENDS
    PDIC        DB 'a','r','m','a','d','i','l','l','o', 0 , 0 , 10 DUP(0), 9 
                DB 'b','u','l','l', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 4 
                DB 'c','a','t', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 3 
                DB 'd','o','g', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 3 
                DB 'e','a','g','l','e', 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 5 
                DB 'f','o','x', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 3 
                DB 'g','i','r','a','f','f','e', 0 , 0 , 0 , 0 , 10 DUP(0), 7 
                DB 'h','y','e','n','a', 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 5 
                DB 'i','g','u','a','n','a', 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 6 
                DB 'j','a','g','u','a','r', 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 6 
                DB 'k','a','n','g','a','r','o','o', 0 , 0 , 0 , 10 DUP(0), 7 
                DB 'l','l','a','m','a', 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 5 
                DB 'm','o','n','k','e','y', 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 6 
                DB 'n','i','g','h','t','i','n','g','a','l','e', 10 DUP(0), 0BH 
                DB 'o','c','t','o','p','u','s', 0 , 0 , 0 , 0 , 10 DUP(0), 7 
                DB 'p','a','r','r','o','t', 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 6 
                DB 'q','i','a','i','l', 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 5 
                DB 'r','o','a','d','r','u','n','n','e','r', 0 , 10 DUP(0), 0AH 
                DB 's','e','a','g','u','l','l', 0 , 0 , 0 , 0 , 10 DUP(0), 7 
                DB 't','i','m','b','e','r','m','a','n', 0 , 0 , 10 DUP(0), 9 
                DB 'u','r','c','h','i','n', 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 6 
                DB 'v','u','l','t','u','r','e', 0 , 0 , 0 , 0 , 10 DUP(0), 7 
                DB 'w','e','a','s','e','l', 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 6 
                DB 'x','e','r','u','s', 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 5 
                DB 'y','a','k', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 3 
                DB 'z','e','b','r','a', 0 , 0 , 0 , 0 , 0 , 0 , 10 DUP(0), 5
    W   HITWORD 25  DUP(<>)
    ALPHA_TABLE DB  01EH, 030H, 02EH, 020H, 012H, 021H, 022H, 023H
                DB  017H, 024H, 025H, 026H, 032H, 031H, 018H, 019H
                DB  010H, 013H, 01FH, 014H, 016H, 02FH, 011H, 02DH
                DB  015H, 02CH    
    SCREEN_WORDS    DW 0F0H
    _OVER       DB  'Done', 0DH, 0AH, '$'
    _LIST       DB  'words_listed=' ;SIZE 13
    _HIT        DB  '; words_hit=', 0
    _LOST       DB  '; words_lost='
    _RATE       DB  '; hit_rate=', 0, 0
    WORD_LISTS  DW  1234H
    WORD_HIT    DW  0H
    WORD_LOST   DW  0H
    PERCENT     DW  0H
    BUF         DB  25 DUP(0)
    BUF_PTR     DB  0H

DATA ENDS

CODE    SEGMENT use16
    ASSUME  CS:CODE, DS:DATA

start:
    JMP     main

clear_scr:      ; 用于清屏
                ; param: NULL
                ; return: NULL
    PUSH    AX
    PUSH    CX
    PUSH    DI
    MOV     AX, 0B800H
    MOV     ES, AX
    MOV     DI, 0H
    MOV     CX, 0FA0H
    MOV     AX, 2000H
    CLD
    REP     STOSB
    POP     DI
    POP     CX
    POP     AX
    ; PUSH    AX
    ; MOV     AH, 0FH
    ; INT     10H
    ; MOV     AH, 0H
    ; INT     10H 
    ; POP     AX
    RET

; convert_key_to_ascii:; AL: word need to convert
;     PUSH    CX
;     LEA     DI, ALPHA_TABLE
;     MOV     CX, DATA
;     MOV     ES, CX
;     MOV     CX, 1AH
;     CLD
;     REPNE  SCASB
;     CMP     CX, 0H
;     JZ      convert_not_alpha
;     DEC     DI
;     SUB     DI, OFFSET ALPHA_TABLE
;     MOV     AX, DI
;     ADD     AL, 'a'
;     JMP     convert_over
; convert_not_alpha:
;     MOV     AL, 0H
; convert_over:
;     POP     CX
;     RET


; show_char:; AL:char, AH:color, DL:X, DH:Y
;          ; ES 为 B800H
;          ; DI 会变
;     PUSH    DI
;     PUSH    AX
;     MOV     AX, 0B800H
;     MOV     ES, AX
;     XOR     AX, AX
;     MOV     AL, 50H
;     MUL     DH
;     ADD     AL, DL
;     ADC     AH, 0H
;     SHL     AX, 1
;     MOV     DI, AX
;     POP     AX
;     MOV     WORD PTR ES:[DI], AX
;     POP     DI
;     RET

; print_number:; AX NUMER TO PRINT, 
;              ; DX ZUOBIAO
;     PUSH    AX
;     PUSH    BX
;     PUSH    CX
;     PUSH    SI
;     PUSH    DX
;     LEA     SI, BUF_PTR
;     XOR     CL, CL
;     MOV     BX, 0AH
; print_number_change:
;     XOR     DX, DX
;     DIV     BX
;     ADD     DL, '0'
;     DEC     SI
;     MOV     [SI], DL
;     INC     CL
;     CMP     AX, 0H
;     JNZ     print_number_change
;     POP     DX
; print_number_put:
;     CMP     CL, 0H
;     JZ      print_number_over
;     MOV     AL, [SI]
;     MOV     AH, 17H
;     CALL    show_char
;     INC     DL
;     DEC     CL
;     INC     SI
;     JMP     print_number_put
; print_number_over:
;     POP     SI
;     POP     CX
;     POP     BX
;     POP     AX
;     RET


; show_score:
;     PUSH    AX
;     PUSH    BX
;     PUSH    CX
;     PUSH    DX
;     PUSH    SI
;     PUSH    BP
;     MOV     AX, [WORD_HIT]
;     MOV     BX, 64H
;     MUL     BX
;     MOV     BX, [WORD_LISTS]
;     CMP     BX, 0H
;     JZ      no_div
;     XOR     DX, DX
;     DIV     BX
;     MOV     [PERCENT], AX
; no_div:
;     LEA     SI, _LIST
;     LEA     BP, WORD_LISTS
;     MOV     AH, 17H
;     MOV     CL, 0DH
;     MOV     CH, 04H
;     MOV     DH, 18H
;     XOR     DL, DL
; show_score_loop:
;     MOV     AH, 17H
;     MOV     AL, [SI]
;     CMP     AL, 0H
;     JZ      show_score_no_print
;     CALL    show_char
;     INC     DL
; show_score_no_print:
;     DEC     CL
;     INC     SI
;     CMP     CL, 0H
;     JNZ     show_score_loop
;     MOV     CL, 0DH
;     MOV     AX, [BP]
;     CALL    print_number
;     ADD     BP, 2H
;     DEC     CH
;     CMP     CH, 0H
;     JNZ     show_score_loop
;     POP     BP
;     POP     SI
;     POP     DX
;     POP     CX
;     POP     BX
;     POP     AX
;     RET


main:   
    MOV     AX, data
    MOV     DS, AX         
    ; XOR     AX, AX
    ; MOV     AL, 0FFH
    ; MOV     BL, 0FEH
    ; ADD     AL, BL
    ; ADC     AH, 0H
    ; ADD     AX, TYPE HITWORD
    ; MOV     AL, 030H
    ; CALL    convert_key_to_ascii
    ; MOV     AL, 0F0H
    ; MOV     AH, 0H
    ; MOV     DH, 2H
    ; MUL     DH
    ; SUB     WORD PTR DS:[SCREEN_WORDS], 1H
    ; SUB     WORD PTR [HIT], 10H
    ; MOV     AX, [HIT]
    ; MOV     BX, 0H
    ; MOV     AX, TYPE HITWORD
    ; MUL     BX
    ; PUSH    AX
    ; ADD     AX, OFFSET  W
    ; MOV     DI, AX
    ; MOV     CX, 16H
    ; MOV     AX, DATA
    ; MOV     ES, AX
    ; MOV     AX, 16H
    ; MOV     DX, 0H
    ; MUL     DX
    ; ADD     AX, OFFSET PDIC
    ; MOV     SI, AX
    ; MOV     CX, 16H
    ; CLD
    ; REP  MOVSB
    ; MOV     SI, 0H
    ; MOV     AL, W[SI].SIZE_OF
;     LEA     DI, RATE
;     MOV     CX, 0DH
; LOO:
;     CMP     CX, 0HJ
;     JZ      _OUT
;     MOV     AL, BYTE PTR [DI]
;     INC     DI
;     DEC     CX
;     JMP     LOO
    ; MOV     DH, 18H
    ; MOV     DL, 0H
    ; MOV     AX, 10H
    ; CALL    print_number
    ; MOV     AX, 10H
    ; CALL    print_number
_OUT:    
    ; CALL    show_score

    ; MOV     BP, OFFSET WORD_LISTS
    ; MOV     AX, [BP]

    ; CALL    clear_scr
    MOV     AX, 03H
    INT     10H
    ; MOV     AH, 0H
    ; INT     10H 
    LEA     DX, _OVER
    MOV     AH, 9H
    INT     21H
    MOV     AH, 7
    INT     21H                ; 延迟，防止程序直接结束
    MOV     AH, 4CH
    INT     21H                ; 程序终止
CODE    ENDS
    END start

    