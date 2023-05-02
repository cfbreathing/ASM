;coding: UTF-8
.386
DATA    SEGMENT use16
    HITWORD     STRUC           ; 定义数据结构
        _LETTER     DB      21      DUP(0)
        _SIZE       DB      0   ; 单词的长度，使用硬编码写入
        _X          DB      0   ; 单词坐标
        _Y          DB      0   ; 单词坐标
        _HIT_LEN    DB      0   ; 已经按下的字母
        _STATUS     DB      0   ; 单词状态：0 = 没有打中；1 = 打中；2 = 即将消失
        _OLD_CHAR   DB      0   ; 被子弹穿过的字符
        _OLD_COLOR  DB      0   ; 被子弹穿过的字符颜色
        _PX         DB      0   ; 子弹上一刻的坐标
        _PY         DB      0   ; 子弹上一刻的坐标
        _BX         DB      0   ; 子弹坐标
        _BY         DB      0   ; 子弹坐标
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
    SEED        DD  0H          ; 随机数种子
    STOP        DB  0H          ; 暂停标志，在按下 Esc 后游戏结束
    TICKS_TO_WAIT   DB  0H      ; 刷新频率，数值越小刷新越快
    UPDATING    DB  1H          ; 更新标志，为 0 时禁止 INT_9 更新
    _OVER       DB  'Done', 0DH, 0AH, '$'
    _LIST       DB  'words_listed=' ;SIZE 13
    _HIT        DB  '; words_hit=', 0
    _LOST       DB  '; words_lost='
    _RATE       DB  '; hit_rate=', 0, 0
    WORD_LISTS  DW  0H          ; 出现过的单词数
    WORD_HIT    DW  0H          ; 击中的单词数
    WORD_LOST   DW  0H          ; 放跑的单词数
    PERCENT     DW  0H          ; 击中比例
    HIT         DW  0FFFFH      ; 当前敲击单词下标
    HIT_LEN     DW  0H          ; 已敲击字符数量长度
    SCREEN_WORDS    DW  0H      ; 屏幕上的单词数量
    ALPHA_TABLE DB  01EH, 030H, 02EH, 020H, 012H, 021H, 022H, 023H
                DB  017H, 024H, 025H, 026H, 032H, 031H, 018H, 019H
                DB  010H, 013H, 01FH, 014H, 016H, 02FH, 011H, 02DH
                DB  015H, 02CH
    KEY         DB  0H          ; 保存按下的按钮
    MARK        DB  26 DUP(0)   ; 保存屏幕上出现过的单词
    GENE        DW  0H          ; 保存产生的单词
    BUF         DB  25 DUP(0)   ; 缓冲区，用于数字输出
    BUF_PTR     DB  0H
DATA ENDS

CODE    SEGMENT use16
    ASSUME  CS:CODE, DS:DATA

start:
    JMP     main
    OLD_8H      DW  0H, 0H
    OLD_9H      DW  0H, 0H

memset_zero:    ; 用于将 ES:[DI] 内存中长度为 CX 的数据置 0
                ; param: ES、DI、CX
                ; return: NULL
    PUSH    DI
    PUSH    CX
memset_zero_loop:
    CMP     CX, 0H
    JZ      memset_zero_out
    MOV     BYTE PTR ES:[DI], 0H
    INC     DI
    DEC     CX 
    JMP     memset_zero_loop
memset_zero_out:
    POP     CX
    POP     DI
    RET

clear_scr:      ; 用于清屏
                ; param: NULLS
                ; return: NULL
    PUSH    AX
    PUSH    CX
    PUSH    DI
    MOV     AX, 0B800H
    MOV     ES, AX
    MOV     DI, 0H
    MOV     CX, 0FA0H
    MOV     AL, 0H
    CLD
    REP     STOSB
    POP     DI
    POP     CX
    POP     AX
    RET
    ; PUSH    AX
    ; MOV     AH, 0FH
    ; INT     10H
    ; MOV     AH, 0H
    ; INT     10H 
    ; POP     AX
    ; RET

set_rand_seed:  ; 设置随机数种子
                ; param: NULL
                ; return: NULL
    PUSH    EBX
    PUSH    EAX
    XOR     AX, AX
    MOV     ES, AX
    MOV     BX, 46CH
    MOV     EAX, ES:[BX]
    MOV     [SEED], EAX
    POP     EAX
    POP     EBX
    RET

get_rand:       ; 获取一个随机数
                ; param: NULL
                ; return: AX:一个小于 7FFFH 的随机数
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

generate_one_word:; 随机产生一个单词并将其放在屏幕上
                  ; param: NULL
                  ; return: NULL
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    CALL    get_rand        ; 获取一个随机数
    AND     AX, 3H
    CMP     AX, 0H          ; 当 AX 不为 0 时不产生单词
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
generate_one_word_mark:     ; 标记已经生成的单词
    CMP     BX, CX
    JZ      generate_one_word_pre
    MOV     DL, W[SI]._LETTER[0]
    SUB     DL, 'a'
    MOV     DI, DX
    MOV     BYTE PTR MARK[DI], 1H
    INC     BX
    ADD     SI, AX
    JMP     generate_one_word_mark
generate_one_word_pre:      ; 为生成单词做准备
    XOR     DI, DI
    CALL    get_rand
    AND     AX, 1H
    CMP     AX, 0H
    JZ      generate_one_word_ltor
    ADD     DI, 19H
generate_one_word_rtol:     ; 手动寻找没有出现过的单词，从右向左遍历
    CMP     BYTE PTR MARK[DI], 0H
    JZ      generate_one_word_find
    DEC     DI
    JMP     generate_one_word_rtol
generate_one_word_ltor:     ; 手动寻找没有出现过的单词，从左向右遍历
    CMP     BYTE PTR MARK[DI], 0H
    JZ      generate_one_word_find
    INC     DI
    JMP     generate_one_word_ltor
generate_one_word_find:     ; 找到没出现的单词后，将其显示在屏幕上
    MOV     [GENE], DI
    CMP     [SCREEN_WORDS], 18H
    JNB     generate_one_word_out
    MOV     AX, DATA
    MOV     ES, AX
    MOV     DS, AX
    MOV     BX, [SCREEN_WORDS]
    MOV     AX, TYPE HITWORD
    MUL     BX
    PUSH    AX              ; 压入目标单词相对于 W 的偏移地址，方便后续使用
    ADD     AX, OFFSET  W
    MOV     DI, AX
    MOV     CX, 16H
    CALL    memset_zero 
    MOV     AX, 16H
    MOV     DX, [GENE]
    MUL     DX
    ADD     AX, OFFSET PDIC
    MOV     SI, AX
    MOV     CX, 16H
    CLD
    REP  MOVSB              ; 将单词存入 W[i] 中
    POP     DI              ; 取出目标单词相对于 W 的偏移地址
    MOV     BYTE PTR W[DI]._Y, 0H
    CALL    get_rand
    MOV     BX, 50H
    SUB     BL, W[DI]._SIZE
    XOR     AH, AH
    DIV     BL
    MOV     W[DI]._X, AH
    MOV     BYTE PTR W[DI]._HIT_LEN, 0H
    MOV     BYTE PTR W[DI]._STATUS, 0H
    ADD     [SCREEN_WORDS], 1H
    ADD     [WORD_LISTS], 1H
generate_one_word_out:
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET


show_char:      ; 将一个字符放在屏幕上
                ; param: AL：需要放置的字符的 ascii 码，AH：所需颜色
                ; param: DL：字符在屏幕上的 x 坐标，DH：字符在屏幕上的 y 坐标
                ; return：NULL
    PUSH    DI
    PUSH    AX
    MOV     AX, 0B800H
    MOV     ES, AX
    MOV     AX, 50H
    MUL     DH
    ADD     AL, DL
    ADC     AH, 0H
    SHL     AX, 1
    MOV     DI, AX
    POP     AX
    MOV     WORD PTR ES:[DI], AX
    POP     DI
    RET

show_one_word:  ; 展示 W[i] 的单词
                ; param: BX：需要展示的单词下标
                ; return：NULL
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    PUSH    BP
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     BP, AX
    MOV     CL, W[BP]._HIT_LEN
    MOV     DL, W[BP]._X
    MOV     DH, W[BP]._Y
    XOR     SI, SI
show_word_loop:
    MOV     AL, W[BP]._LETTER[SI]
    CMP     AL, 0H          ; 当遇上 0 时停止展示
    JZ      show_word_end
    CMP     CL, 0H
    JG      show_green_word
    MOV     AH, 07H
    JMP     show_word_pre
show_green_word:
    MOV     AH, 02H
show_word_pre:
    CALL    show_char
    INC     SI
    DEC     CL
    INC     DL
    JMP     show_word_loop
show_word_end:
    POP     BP
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET

show_words:     ; 展示 W 中的所有单词
                ; param: NULL
                ; return：NULL
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

print_number:   ; 展示一个数字
                ; param: AX：需要展示的数字，DL：数字的 x 坐标，DH：数字的 y 坐标
                ; return：NULL
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    SI
    PUSH    DX
    LEA     SI, BUF_PTR
    XOR     CL, CL
    MOV     BX, 0AH
print_number_change:        ; 先将 AX 转化为字符串存入 BUF 中
    XOR     DX, DX
    DIV     BX
    ADD     DL, '0'
    DEC     SI
    MOV     DS:[SI], DL
    INC     CL
    CMP     AX, 0H
    JNZ     print_number_change
    POP     DX              ; 压出 DX，便于为数字定位
print_number_put:           ; 开始输出
    CMP     CL, 0H
    JZ      print_number_over
    MOV     AL, DS:[SI]
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

show_score:     ; 展示分数面板
                ; param: NULL
                ; return：NULL
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    PUSH    BP
    MOV     AX, DATA
    MOV     DS, AX
    MOV     AX, [WORD_HIT]
    MOV     BX, 64H
    MUL     BX
    MOV     BX, [WORD_LISTS]
    CMP     BX, 0H
    JZ      no_div          ; 当 WORD_LISTS 为 0 时不做除法
    XOR     DX, DX
    DIV     BX
    MOV     [PERCENT], AX
no_div:
    MOV     SI, OFFSET _LIST
    MOV     BP, OFFSET WORD_LISTS
    MOV     CL, 0DH
    MOV     CH, 04H
    MOV     DH, 18H
    XOR     DL, DL
show_score_loop:            ; 先输出文字部分，后输出数字部分
    MOV     AH, 17H
    MOV     AL, DS:[SI]
    CMP     AL, 0H
    JZ      show_score_no_print
    CALL    show_char   
    INC     DL              ; 每次完成一次输出后都要增加 DL，代表坐标在 x 方向上移一格
show_score_no_print:
    DEC     CL
    INC     SI
    CMP     CL, 0H
    JNZ     show_score_loop
    MOV     CL, 0DH
    MOV     AX, DS:[BP]
    CALL    print_number    ; 输出数字部分
    ADD     BP, 2H
    DEC     CH
    CMP     CH, 0H
    JNZ     show_score_loop
    MOV     AL, '%'
    MOV     AH, 17H
    CALL    show_char       ; 最后输出一个 %
    POP     BP
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET

move_words_down:; 让所有单词下移一格
                ; param: NULL
                ; return：NULL
    PUSH    AX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    MOV     BYTE PTR [UPDATING], 0H
    MOV     CX, [SCREEN_WORDS]
    MOV     AX, TYPE HITWORD
    XOR     SI, SI
move_words_down_loop:       ; 为所有单词的 y 坐标加一，表示向下移动一行
    CMP     CX, 0H
    JZ      move_words_down_end
    ADD     BYTE PTR W[SI]._Y, 1H   
    ADD     SI, AX
    DEC     CX
    JMP     move_words_down_loop
move_words_down_end:    ; 停止移动
    MOV     SI, CX
    MOV     CL, W[SI]._Y
    CMP     CL, 18H         ; 判断 W[0] 是否掉出屏幕
    JB      move_words_down_over
    CLI                     ; 保证更新数据时不会启用中断
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
    REP  MOVSB              ; 使用 MOVSB 迁移数据
    SUB     WORD PTR [SCREEN_WORDS], 1H
    ADD     WORD PTR [WORD_LOST], 1H
    CMP     WORD PTR [HIT], 0FFFFH
    JZ      move_words_down_no_hit
    SUB     WORD PTR [HIT], 1H
move_words_down_no_hit:     ; 没有正在敲击的单词时，不改变 HIT
    STI
move_words_down_over:
    CALL    show_words      ; 展示所有单词
    MOV     BYTE PTR [UPDATING], 1H
    POP     SI
    POP     DX
    POP     CX
    POP     AX
    RET

get_char_color: ; 获取 (DL,DH) 坐标处的字符 ASCII 码和颜色
                ; param: DL：x 坐标；DH：y 坐标
                ; return：AL：ASCII 码；AH：颜色
    PUSH    SI
    MOV     AX, 0B800H
    MOV     ES, AX
    MOV     AX, 50H
    MUL     DH
    ADD     AL, DL
    ADC     AH, 0H          ; 防止出现进位
    SHL     AX, 1
    MOV     SI, AX
    MOV     AL, ES:[SI]
    MOV     AH, ES:[SI+1]
    POP     SI
    RET

draw_bullet:    ; 画出一颗子弹
                ; param: BX：需要被射中的单词下标
                ; return：NULL
    PUSH    AX
    PUSH    DX
    PUSH    SI
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     SI, AX
    MOV     DL, W[SI]._PX
    MOV     DH, W[SI]._PY
    MOV     AL, W[SI]._OLD_CHAR
    MOV     AH, W[SI]._OLD_COLOR
    CALL    show_char       ; 在上次子弹的坐标(w[i].px, w[i].py)处以w[i].old_color这个颜色重画字符
                            ; w[i].old_char, 即重画被子弹覆盖的字符
    MOV     DL, W[SI]._BX
    MOV     DH, W[SI]._BY
    CALL    get_char_color
    MOV     W[SI]._OLD_CHAR, AL
    MOV     W[SI]._OLD_COLOR, AH
    MOV     AL, 18H
    MOV     AH, 0CH
    CALL    show_char       ; 在当前子弹坐标处画子弹 
    MOV     W[SI]._PX, DL
    MOV     W[SI]._PY, DH
    DEC     DH              ; 当前子弹的 y 坐标减1,表示子弹继续向上移动
    MOV     W[SI]._BY, DH
    POP     SI
    POP     DX
    POP     AX
    RET

int_8h:         ; 时钟中断函数,用来更新子弹的位置及对ticks_to_wait进行倒计数
                ; param: NULL
                ; return：NULL
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    PUSH    DS
    MOV     AX, DATA
    MOV     DS, AX      ; 更新 DS 寄存器
    MOV     CX, [SCREEN_WORDS]
    XOR     BX, BX
int_8h_find_search:         ; 遍历屏幕上的单词，判断是否需要发射子弹
    CMP     BX, CX
    JZ      int_8h_no_destory
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     SI, AX
    CMP     BYTE PTR W[SI]._STATUS, 2H
    JZ      int_8h_draw
    INC     BX
    JMP     int_8h_find_search
int_8h_draw:                ; 找到需要销毁的单词，发射子弹
    CALL    draw_bullet
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     SI, AX
    MOV     DL, W[SI]._BY
    MOV     CH, W[SI]._Y
    CMP     CH, DL          ; 子弹是否穿过单词，若穿过则更新数据，反之则不更新
    JNA     int_8h_no_destory
    ADD     AX, OFFSET W
    MOV     DI, AX
    ADD     AX, TYPE HITWORD
    MOV     SI, AX
    MOV     AX, DATA
    MOV     ES, AX
    MOV     DS, AX
    INC     BX
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
int_8h_update:              ; 更新数据
    ADD     WORD PTR [WORD_HIT], 1H
    SUB     WORD PTR [SCREEN_WORDS], 1H
int_8h_no_destory:          ; 没有需要销毁的单词
    CMP     BYTE PTR [TICKS_TO_WAIT], 0H
    JZ      int_8h_out
    SUB     BYTE PTR [TICKS_TO_WAIT], 1H
int_8h_out:
    POP     DS
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    JMP     DWORD PTR CS:[OLD_8H]

convert_key_to_ascii:; 将一个扫描码转化为 ascii 码
                ; param：AL：需要转化的扫描码
                ; return：AL：转化后的 ascii 码，若键码不是字母则为 0 
    PUSH    CX
    PUSH    SI
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
    POP     SI
    POP     CX
    RET


prepare_for_firing: ; 初始化子弹
                ; param：BX：需要被销毁的单词下标
                ; return：NULL                   
    PUSH    AX
    PUSH    DX
    PUSH    SI
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     SI, AX
    MOV     AL, W[SI]._SIZE
    MOV     DX, 2H
    XOR     AH, AH
    DIV     DL
    ADD     AL, W[SI]._X
    MOV     W[SI]._BX, AL
    MOV     BYTE PTR W[SI]._BY, 17H
    MOV     W[SI]._PX, AL
    MOV     BYTE PTR W[SI]._PY, 18H
    MOV     DL, W[SI]._PX
    MOV     DH, W[SI]._PY
    CALL    get_char_color
    MOV     W[SI]._OLD_CHAR, AL
    MOV     W[SI]._OLD_COLOR, AH
    POP     SI
    POP     DX
    POP     AX
    RET

int_9h:         ; 键盘中断函数
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    DI
    PUSH    DS
    MOV     AX, DATA            ; 更新 DS 寄存器
    MOV     DS, AX
    IN      AL, 60H
    MOV     [KEY], AL
    CMP     AL, 0E0H
    JZ      int_9h_iret         ; 直接跳出
    CMP     AL, 0E1h
    JZ      int_9h_iret         ; 直接跳出
    CMP     AL, 1H
    JZ      int_9h_stop         ; 终止程序
    AND     AL, 80H
    CMP     AL, 0H
    JNZ     int_9h_iret         ; 直接跳出
    MOV     AL, [KEY]
    CALL    convert_key_to_ascii
    CMP     AL, 0H              ; 若输入的不是字母，则直接跳出
    JZ      int_9h_iret
    MOV     [KEY], AL
    CMP     WORD PTR [HIT], 0FFFFH
    JNZ     int_9h_word_hit     ; 判断当前有无正在敲的单词，若有则进入 int_9h_word_hit
    XOR     BX, BX
    MOV     CX, [SCREEN_WORDS]
int_9h_search_word:             ; 遍历所有单词，查找目前的敲击是否与屏幕上单词对应
    CMP     BX, CX
    JNB     int_9h_iret
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     DI, AX
    MOV     DL, W[DI]._LETTER[0]
    CMP     DL, [KEY]
    JZ      int_9h_find 
    INC     BX
    JMP     int_9h_search_word
int_9h_find:                    ; 成功找到目标字母，设置 HIT、HIT_LEN 为第一次敲击状态
    MOV     [HIT], BX
    MOV     WORD PTR [HIT_LEN], 1H
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     DI, AX
    MOV     BYTE PTR W[DI]._STATUS, 1H
    JMP     int_9h_showordes

int_9h_word_hit:                ; 存在正在敲击中的单词的分支
    MOV     BX, [HIT]
    MOV     AX, TYPE HITWORD
    MUL     BX
    MOV     DI, AX
    MOV     BX, [HIT_LEN]
    MOV     AL, [KEY]           ; 判断目前敲击是否打中了 W[HIT] 的剩余字母
    CMP     AL, W[DI]._LETTER[BX]
    JNZ     is_9h_not_shoot
    ADD     WORD PTR [HIT_LEN], 1H
int_9h_showordes:               ; 展示函数，为第一次敲击分支与第二次敲击分支共用
    MOV     BX, [HIT_LEN]
    MOV     W[DI]._HIT_LEN, BL
    CMP     BYTE PTR [UPDATING], 0H
    JZ      int_9h_not_show
    MOV     BX, [HIT]
    CALL    show_one_word
int_9h_not_show:            
    MOV     AL, W[DI]._SIZE
    XOR     AH, AH
    CMP     [HIT_LEN], AX       ; 判断当前单词字母是否全部打完
    JNZ     int_9h_iret
    MOV     BX, [HIT]
    CALL    prepare_for_firing
    MOV     BYTE PTR W[DI]._STATUS, 2H
    MOV     WORD PTR [HIT], 0FFFFH
    MOV     WORD PTR [HIT_LEN], 0H
    JMP     int_9h_iret
is_9h_not_shoot:                ; 当没有打中时，将 _STATUS 和 _HIT_LEN 置 0
    MOV     BYTE PTR W[DI]._STATUS, 0H
    MOV     BYTE PTR W[DI]._HIT_LEN, 0H
    MOV     WORD PTR [HIT], 0FFFFH
    MOV     WORD PTR [HIT_LEN], 0H
    JMP     int_9h_iret
int_9h_stop:
    MOV     BYTE PTR [STOP], 1H
int_9h_iret:
    MOV     AL, 20H
    OUT     20H, AL
    POP     DS
    POP     DI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    IRET

main:           ; 主函数
    MOV     AX, data
    MOV     DS, AX         
    CALL    set_rand_seed
    MOV     CX, 320H
    MOV     ES, AX
    LEA     DI, W
    CALL    memset_zero 
    MOV     WORD PTR [SCREEN_WORDS], 0H
    MOV     BYTE PTR [STOP], 0H
    CALL    clear_scr
    XOR     AX, AX
    MOV     ES, AX
    CLI
    MOV     BX, 8H*4
    PUSH    WORD PTR ES:[BX]
    POP     CS:OLD_8H[0]
    PUSH    WORD PTR ES:[BX+2]
    POP     CS:OLD_8H[2]
    MOV     WORD PTR ES:[BX], offset int_8h
    MOV     ES:[BX+2], CS
    MOV     BX, 9H*4
    PUSH    WORD PTR ES:[BX]
    POP     CS:OLD_9H[0]
    PUSH    WORD PTR ES:[BX+2]
    POP     CS:OLD_9H[2]
    MOV     WORD PTR ES:[BX], offset int_9h
    MOV     ES:[BX+2], CS
    STI
main_loop:
    CMP     BYTE PTR [STOP], 0H
    JNZ     main_done
    MOV     BYTE PTR [TICKS_TO_WAIT], 0CH
wait_a_tick:
    CMP     BYTE PTR [TICKS_TO_WAIT], 0H
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
    PUSH    CS:OLD_8H[0]
    POP     WORD PTR ES:[BX]
    PUSH    CS:OLD_8H[2]
    POP     WORD PTR ES:[BX+2]
    MOV     BX, 9H*4
    PUSH    CS:OLD_9H[0]
    POP     WORD PTR ES:[BX]
    PUSH    CS:OLD_9H[2]
    POP     WORD PTR ES:[BX+2]
    STI
    MOV     AX, 03H
    INT     10H
    MOV     AH, 9H
    LEA     DX, _OVER           ; 输出结束语
    INT     21H
    MOV     AH, 4CH
    INT     21H                 ; 程序终止
CODE    ENDS
    END start

    