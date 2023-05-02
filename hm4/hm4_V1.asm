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
    STOP        DB  0H
    ticks_to_wait   DB  0H
    updating    DB  0H
    over_word   DB  'Done',0DH, 0AH, '$'
    _LIST       DB  'words_listed=' ;SIZE 13
    _HIT        DB  '; words_hit=', 0
    _LOST       DB  '; words_lost='
    _RATE       DB  '; hit_rate=', 0, 0
    WORD_LISTS  DW  0H
    WORD_HIT    DW  0H
    WORD_LOST   DW  0H
    PERCENT     DW  0H
    BUF         DB  25 DUP(0)
    BUF_PTR     DB  0H
    SEED        DD  0H
    HIT         DW  0FFFFH
    HIT_LEN     DW  0H
    SCREEN_WORDS    DW  0H
    ALPHA_TABLE DB  01EH, 030H, 02EH, 020H, 012H, 021H, 022H, 023H
                DB  017H, 024H, 025H, 026H, 032H, 031H, 018H, 019H
                DB  010H, 013H, 01FH, 014H, 016H, 02FH, 011H, 02DH
                DB  015H, 02CH
    KEY         DB  0H
    MARK        DB  26 DUP(0)
    GENE        DW  0H
    OLD_8H      DW  0H, 0H
    OLD_9H      DW  0H, 0H
DATA ENDS

CODE    SEGMENT use16
    ASSUME  CS:CODE, DS:DATA

start:
    JMP     main

memset_zero:; ES:[DI] CLEAR, CX:COUNT
    PUSH    DI
    PUSH    CX
memset_zero_loop:
    CMP     CX, 0H
    JZ      zero_done
    MOV     BYTE PTR ES:[DI], 0
    INC     DI
    DEC     CX 
    JMP     memset_zero_loop
zero_done:
    POP     CX
    POP     DI
    RET

clear_scr:
    PUSH    AX
    MOV     AH, 0FH
    INT     10H
    MOV     AH, 0H
    INT     10H 
    POP     AX
    RET

set_rand_seed:
    PUSH    EBX
    PUSH    EAX
    XOR     AX, AX
    MOV     ES, AX
    MOV     BX, 46CH
    MOV     EAX, DWORD PTR ES:[BX]
    MOV     [SEED], EAX
    POP     EAX
    POP     EBX
    RET

get_rand:;RETURN EAX WITH THE RAND
    PUSH    EBX
    PUSH    EDX
    MOV     EAX, [SEED]
    MOV     EBX, 015A4E35H
    MUL     EBX
    ADD     EAX, 1H
    MOV     [SEED], EAX
    LEA     EAX, SEED
    ADD     EAX, 1H
    MOV     EAX, DWORD PTR [EAX]
    AND     EAX, 7FFFH
    POP     EDX
    POP     EBX
    RET

generate_one_word:
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    CALL    get_rand
    AND     AX, 3H
    CMP     AX, 0H
    JNZ     generate_one_word_out
    MOV     AX, DATA
    MOV     ES, AX
    LEA     DI, MARK
    MOV     CX, 1AH
    CALL    memset_zero
    XOR     DX, DX
    MOV     CX, [SCREEN_WORDS]
    XOR     BX, BX
    MOV     AX, TYPE HITWORD
    XOR     SI, SI
generate_one_word_mark:
    CMP     BX, CX
    JZ      generate_one_word_pre
    MOV     DL, BYTE PTR W[SI].LETTER[0]
    SUB     DL, 'a'
    MOV     DI, DX
    MOV     BYTE PTR MARK[DI], 1H
    INC     BX
    ADD     SI, AX
    JMP     generate_one_word_mark
generate_one_word_pre:
    XOR     DI, DI
    CALL    get_rand
    AND     AX, 1H
    CMP     AX, 0H
    JZ      generate_one_word_ltor
    ADD     DI, 19H
generate_one_word_rtol:
    CMP     MARK[DI], 0H
    JZ      generate_one_word_find
    DEC     DI
    JMP     generate_one_word_rtol
generate_one_word_ltor:
    CMP     MARK[DI], 0H
    JZ      generate_one_word_find
    INC     DI
    JMP     generate_one_word_ltor
generate_one_word_find:
    MOV     [GENE], DI
    CMP     [SCREEN_WORDS], 18H
    JNB     generate_one_word_out
    MOV     BX, [SCREEN_WORDS]
    MOV     AX, TYPE HITWORD
    MUL     BX
    PUSH    AX
    ADD     AX, OFFSET  W
    MOV     DI, AX
    MOV     CX, 16H
    MOV     AX, DATA
    MOV     ES, AX
    CALL    memset_zero
    MOV     AX, 16H
    MOV     DX, [GENE]
    MUL     DX
    ADD     AX, OFFSET PDIC
    MOV     SI, AX
    MOV     CX, 16H
    CLD
    REP  MOVSB
    POP     DI
    MOV     BYTE PTR W[DI].Y, 0H
    CALL    get_rand
    MOV     BX, 50H
    SUB     BL, BYTE PTR W[DI].SIZE_OF
    XOR     AH, AH
    DIV     BL
    MOV     BYTE PTR W[DI].X, AH
    MOV     BYTE PTR W[DI].HITTED, 0H
    MOV     BYTE PTR W[DI].STATUS, 0H
    ADD     [SCREEN_WORDS], 1H
    ADD     [WORD_LISTS], 1H
generate_one_word_out:
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET


show_char:; AL:char, AH:color, DL:X, DH:Y
         ; ES 为 B800H
         ; DI 会变
    PUSH    DI
    PUSH    AX
    MOV     AX, 0B800H
    MOV     ES, AX
    XOR     AX, AX
    MOV     AL, 50H
    MUL     DH
    ADD     AL, DL
    ADC     AH, 0H
    SHL     AX, 1
    MOV     DI, AX
    POP     AX
    MOV     WORD PTR ES:[DI], AX
    POP     DI
    RET

show_one_word:; BX:word need to show
              ; BP, SI 会变
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     BP, AX
    MOV     CL, BYTE PTR W[BP].HITTED
    MOV     DL, BYTE PTR W[BP].X
    MOV     DH, BYTE PTR W[BP].Y
    XOR     SI, SI
show_word_loop:
    CMP     CL, 0H
    JG      show_green_word
    MOV     AH, 07H
    JMP     show_word_pre
show_green_word:
    MOV     AH, 02H
show_word_pre:
    MOV     AL, BYTE PTR W[BP].LETTER[SI]
    CMP     AL, 0H
    JZ      show_word_end
    CALL    show_char
    INC     SI
    DEC     CL
    INC     DL
    JMP     show_word_loop
show_word_end:
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET

show_words:
    PUSH    BX
    PUSH    CX
    CALL    clear_scr
    XOR     BX, BX
    MOV     CX, [SCREEN_WORDS]
show_words_loop:
    CMP     BX, CX
    JZ      show_words_end
    CALL    show_one_word
    INC     BX
    JMP     show_words_loop
show_words_end:
    POP     CX
    POP     BX
    RET

print_number:; AX NUMER TO PRINT, 
             ; DX ZUOBIAO
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    SI
    PUSH    DX
    LEA     SI, BUF_PTR
    XOR     CL, CL
    MOV     BX, 0AH
print_number_change:
    XOR     DX, DX
    DIV     BX
    ADD     DL, '0'
    DEC     SI
    MOV     [SI], DL
    INC     CL
    CMP     AX, 0H
    JNZ     print_number_change
    POP     DX
print_number_put:
    CMP     CL, 0H
    JZ      print_number_over
    MOV     AL, [SI]
    MOV     AH, 17H
    CALL    show_char
    INC     DL
    DEC     CL
    INC     SI
    JMP     print_number_put
print_number_over:
    POP     SI
    POP     CX
    POP     BX
    POP     AX
    RET

show_score:
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    PUSH    BP
    MOV     AX, [WORD_HIT]
    MOV     BX, 64H
    MUL     BX
    MOV     BX, [WORD_LISTS]
    CMP     BX, 0H
    JZ      no_div
    XOR     DX, DX
    DIV     BX
    MOV     [PERCENT], AX
no_div:
    LEA     SI, _LIST
    LEA     BP, WORD_LISTS
    MOV     CL, 0DH
    MOV     CH, 04H
    MOV     DH, 18H
    XOR     DL, DL
show_score_loop:
    MOV     AH, 17H
    MOV     AL, [SI]
    CMP     AL, 0H
    JZ      show_score_no_print
    CALL    show_char
    INC     DL
show_score_no_print:
    DEC     CL
    INC     SI
    CMP     CL, 0H
    JNZ     show_score_loop
    MOV     CL, 0DH
    MOV     AX, [BP]
    CALL    print_number
    ADD     BP, 2H
    DEC     CH
    CMP     CH, 0H
    JNZ     show_score_loop
    MOV     AL, '%'
    MOV     AH, 17H
    CALL    show_char
    POP     BP
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET

move_words_down:
    PUSH    AX
    PUSH    CX
    PUSH    DX
    MOV     BYTE PTR [updating], 1H
    MOV     CX, [SCREEN_WORDS]
    MOV     AX, TYPE HITWORD
    XOR     SI, SI
move_words_down_loop:
    CMP     CX, 0H
    JZ      move_words_down_end
    ADD     BYTE PTR W[SI].Y, 1H
    ADD     SI, AX
    DEC     CX
    JMP     move_words_down_loop
move_words_down_end:
    MOV     SI, CX
    MOV     CL, BYTE PTR W[SI].Y
    CMP     CL, 18H
    JB      move_words_down_over
    CLI
    MOV     CX, [SCREEN_WORDS]
    DEC     CX
    MUL     CX
    MOV     CX, AX
    MOV     AX, DATA
    MOV     ES, AX
    XOR     AX, AX
    ADD     AX, OFFSET W
    MOV     DI, AX
    ADD     AX, TYPE HITWORD
    MOV     SI, AX
    CLD
    REP  MOVSB
    SUB     WORD PTR [SCREEN_WORDS], 1H
    ADD     WORD PTR [WORD_LOST], 1H
    CMP     [HIT], 0FFFFH
    JZ      move_words_down_no_hit
    SUB     WORD PTR [HIT], 1H
move_words_down_no_hit:
    STI
move_words_down_over:
    CALL    show_words
    MOV     BYTE PTR [updating], 0H
    POP     DX
    POP     CX
    POP     AX
    RET

get_char_color:; AL:char, AH:color, DL:X, DH:Y
    PUSH    SI
    MOV     AX, 0B800H
    MOV     ES, AX
    XOR     AX, AX
    MOV     AL, 50H
    MUL     DH
    ADD     AL, DL
    ADC     AH, 0H
    SHL     AX, 1
    MOV     SI, AX
    MOV     AL, BYTE PTR ES:[SI]
    MOV     AH, BYTE PTR ES:[SI+1]
    POP     SI
    RET

draw_bullet:; BX:I
    PUSH    AX
    PUSH    DX
    PUSH    SI
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     SI, AX
    MOV     DL, BYTE PTR W[SI].PX
    MOV     DH, BYTE PTR W[SI].PY
    MOV     AL, BYTE PTR W[SI].OLD_CAHR
    MOV     AH, BYTE PTR W[SI].OLD_COLOR
    CALL    show_char
    MOV     DL, BYTE PTR W[SI]._BX
    MOV     DH, BYTE PTR W[SI].BY
    CALL    get_char_color
    MOV     BYTE PTR W[SI].OLD_CAHR, AL
    MOV     BYTE PTR W[SI].OLD_COLOR, AH
    MOV     AL, 18H
    MOV     AH, 0CH
    CALL    show_char
    MOV     BYTE PTR W[SI].PX, DL
    MOV     BYTE PTR W[SI].PY, DH
    DEC     DH
    MOV     BYTE PTR W[SI].BY, DH
    POP     SI
    POP     DX
    POP     AX
    RET

int_8h:
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    MOV     CX, [SCREEN_WORDS]
    XOR     BX, BX
int_8h_find_des:
    CMP     BX, CX
    JZ      int_8h_no_update
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     SI, AX
    CMP     BYTE PTR W[SI].STATUS, 2H
    JZ      int_8h_draw
    INC     BX
    JMP     int_8h_find_des
int_8h_draw:
    CALL    draw_bullet
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     SI, AX
    MOV     DL, BYTE PTR W[SI].BY
    MOV     CH, BYTE PTR W[SI].Y
    CMP     CH, DL
    JNA     int_8h_no_update
    ADD     AX, OFFSET W
    MOV     DI, AX
    MOV     AX, TYPE HITWORD
    INC     BX
    MUL     BX
    ADD     AX, OFFSET W
    MOV     SI, AX
    MOV     AX, DATA
    MOV     ES, AX
    MOV     CX, [SCREEN_WORDS]
    SUB     CX, BX
    MOV     AX, TYPE HITWORD
    MUL     CX
    MOV     CX, AX
    REP  MOVSB
    DEC     BX
    MOV     AX, [HIT]
    CMP     AX, 0FFFFH
    JZ      int_8h_update
    CMP     AX, BX
    JNA     int_8h_update
    SUB     WORD PTR [HIT], 1H
int_8h_update:
    ADD     WORD PTR [WORD_HIT], 1H
    SUB     WORD PTR [SCREEN_WORDS], 1H
int_8h_no_update:
    CMP     [ticks_to_wait], 0H
    JZ      int_8h_out
    SUB     BYTE PTR [ticks_to_wait], 1H
int_8h_out:
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    JMP     DWORD PTR [OLD_8H]

convert_key_to_ascii:; AL: word need to convert
    PUSH    CX
    MOV     CX, 1AH
    XOR     SI, SI
convert_key_search:
    CMP     CX, 0H
    JZ      convert_not_alpha
    CMP     ALPHA_TABLE[SI], AL
    JZ      convert_key_find
    INC     SI
    DEC     CX
    JMP     convert_key_search
convert_key_find:
    ADD     SI, 'a'
    MOV     AX, SI
    JMP     convert_over
convert_not_alpha:
    MOV     AX, 0H
convert_over:
    POP     CX
    RET


prepare_for_firing:;BX-the word need to fired
    PUSH    AX
    PUSH    DX
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     SI, AX
    MOV     AL, W[SI].SIZE_OF
    MOV     DL, 2H
    DIV     DL
    ADD     AL, W[SI].X
    MOV     W[SI]._BX, AL
    MOV     W[SI].BY, 17H
    MOV     W[SI].PX, AL
    MOV     W[SI].PY, 18H
    MOV     DL, W[SI].PX
    MOV     DH, W[SI].PY
    CALL    get_char_color
    MOV     W[SI].OLD_CAHR, AL
    MOV     W[SI].OLD_COLOR, AH
    POP     DX
    POP     AX
    RET

int_9h:
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    MOV     AX, DATA
    MOV     DS, AX
    IN      AL, 60H
    MOV     [KEY], AL
    CMP     AL, 0E0H
    JZ      int_9h_iret
    CMP     AL, 0E1h
    JZ      int_9h_iret
    CMP     AL, 1H
    JZ      int_9h_stop
    AND     AL, 80H
    CMP     AL, 0H
    JNZ     int_9h_iret
    MOV     AL, [KEY]
    CALL    convert_key_to_ascii
    CMP     AL, 0H
    JZ      int_9h_iret
    MOV     [KEY], AL
    CMP     [HIT], 0FFFFH
    JNZ     int_9h_word_hit
    XOR     BX, BX
    MOV     CX, [SCREEN_WORDS]
int_9h_search_word:
    CMP     BX, CX
    JNB     int_9h_iret
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     DI, AX
    MOV     DL, W[DI].LETTER[0]
    CMP     DL, [KEY]
    JZ      int_9h_find
    INC     BX
    JMP     int_9h_search_word
int_9h_find:
    MOV     [HIT], BX
    MOV     WORD PTR [HIT_LEN], 1H
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     DI, AX
    MOV     BYTE PTR W[DI].STATUS, 1H
    JMP     int_9h_showordes
int_9h_word_hit:
    MOV     BX, [HIT]
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     DI, AX
    MOV     BX, [HIT_LEN]
    MOV     AL, [KEY]
    CMP     AL, W[DI].LETTER[BX]
    JNZ     is_9h_not_shoot
    ADD     WORD PTR [HIT_LEN], 1H
int_9h_showordes:
    MOV     BX, [HIT_LEN]
    MOV     BYTE PTR W[DI].HITTED, BL
    CMP     [updating], 0H
    JNZ     int_9h_not_show
    MOV     BX, [HIT]
    CALL    show_one_word
int_9h_not_show:
    MOV     AL, W[DI].SIZE_OF
    XOR     AH, AH
    CMP     [HIT_LEN], AX
    JNZ     int_9h_iret
    MOV     BX, [HIT]
    CALL    prepare_for_firing
    MOV     BYTE PTR W[DI].STATUS, 2H
    MOV     WORD PTR [HIT], 0FFFFH
    MOV     WORD PTR [HIT_LEN], 0H
    JMP     int_9h_iret
    
is_9h_not_shoot:
    MOV     BYTE PTR W[DI].STATUS, 0H
    MOV     BYTE PTR W[DI].HITTED, 0H
    MOV     WORD PTR [HIT], 0FFFFH
    MOV     WORD PTR [HIT_LEN], 0H
    JMP     int_9h_iret
int_9h_stop:
    MOV     BYTE PTR [STOP], 1H
int_9h_iret:
    MOV     AL, 20H
    OUT     20H, AL
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    IRET

main:   
    MOV     AX, data
    MOV     DS, AX         
    CALL    set_rand_seed
    MOV     CX, 320H
    MOV     ES, AX
    LEA     DI, W
    CALL    memset_zero
    MOV     [SCREEN_WORDS], 0H
    MOV     [STOP], 0H
    CALL    clear_scr
    XOR     AX, AX
    MOV     ES, AX
    CLI
    MOV     BX, 8H*4
    PUSH    WORD PTR ES:[BX]
    POP     OLD_8H[0]
    PUSH    WORD PTR ES:[BX+2]
    POP     OLD_8H[2]
    MOV     WORD PTR ES:[BX], offset int_8h
    MOV     ES:[BX+2], CS
    MOV     BX, 9H*4
    PUSH    WORD PTR ES:[BX]
    POP     OLD_9H[0]
    PUSH    WORD PTR ES:[BX+2]
    POP     OLD_9H[2]
    MOV     WORD PTR ES:[BX], offset int_9h
    MOV     ES:[BX+2], CS
    STI
main_loop:
    CMP     [STOP], 0H
    JNZ     main_done
    MOV     [ticks_to_wait], 0CH
wait_a_tick:
    CMP     [ticks_to_wait], 0H
    JNZ     wait_a_tick
    CALL    generate_one_word
    CALL    move_words_down
    CALL    show_score
    JMP     main_loop
main_done:
    CLI
    XOR     AX, AX
    MOV     ES, AX   
    MOV     BX, 8H*4
    PUSH    OLD_8H[0]
    POP     WORD PTR ES:[BX]
    PUSH    OLD_8H[2]
    POP     WORD PTR ES:[BX+2]
    MOV     BX, 9H*4
    PUSH    OLD_9H[0]
    POP     WORD PTR ES:[BX]
    PUSH    OLD_9H[2]
    POP     WORD PTR ES:[BX+2]
    STI
    CALL    clear_scr
    MOV     AH, 9H
    LEA     DX, over_word
    INT     21H
    MOV     AH, 4CH
    INT     21H                ; 程序终止
CODE    ENDS
    END start

    