/*****************************************************/
/* Hitword v1.0                                      */
/* copyright (c) Black White, Nov 29, 2022.          */
/* email: iceman@zju.edu.cn                          */
/* This program is for teaching purpose only, and    */
/* it can ONLY be shared within Zhejiang University. */
/* Everyone at ZJU who has downloaded this program   */
/* is NOT allowed to upload it to internet & CC98    */
/* without my permission.                            */
/*****************************************************/

/* 编译及运行步骤:
把此文件复制到xp虚拟机d:\tc中
运行tc后:
Alt+F选择File->Load->hitword.c
Alt+C选择Compile->Compile to OBJ 编译
Alt+C选择Compile->Line EXE file 连接
Alt+R选择Run->Run 运行

    或

把此文件复制到Bochs虚拟机的c:\tc中,
运行Bochs虚拟机
c:
cd \tc
tc
Alt+F选择File->Load->hitword.c
Alt+C选择Compile->Compile to OBJ 编译
Alt+C选择Compile->Line EXE file 连接
Alt+R选择Run->Run 运行
 */

#include <dos.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    char letter[21]; /* 构成单词的字母 */
    int x, y;        /* 单词坐标 */
    int status;      /* 单词状态: 0=not_hit; 1=hit; 2=to_be_destroyed; */
    int hit_len;     /* 打中的字母个数 */
    char old_char, old_color; /* hold char & color covered by bullet */
    int px, py;               /* bullet's previous coordinates */
    int bx, by;               /* bullet's coordinates */
} WORD;

/* 汇编语言中的结构类型按以下语法定义:
HITWORD struc
letter db 21 dup(0)
x dw 0
y dw 0
...
bx dw 0
by dw 0
HITWORD ends
 */

unsigned char* pdic[26] = {
    "armadillo", "bull",        "cat",     "dog",     "eagle",    "fox",
    "giraffe",   "hyena",       "iguana",  "jaguar",  "kangaroo", "llama",
    "monkey",    "nightingale", "octopus", "parrot",  "quail",    "roadrunner",
    "seagull",   "timberman",   "urchin",  "vulture", "weasel",   "xerus",
    "yak",       "zebra"};

char far* _vp = (char far*)0xB8000000; /* 坐标(0,0)的显卡地址 */
unsigned long int seed = 0;            /* 随机数种子 */
void interrupt (*old_8h)(void);        /* 原时钟中断向量 */
void interrupt (*old_9h)(void);        /* 原键盘中断向量 */
WORD w[25];                            /* 25个单词 */
/* 汇编语言中按以下语法定义结构数组
   w HITWORD 25 dup (<>)
 */

int screen_words; /* 屏幕上已显示的单词个数 */
int hit = -1, hit_len = 0; /* hit=当前打中的单词下标, w[hit]就是打中的单词,
                              hit_len=已打中的字母个数 */
int stop = 0;              /* 按Esc键时, stop=1 */
int words_listed = 0, words_hit = 0, words_lost = 0;
volatile int updating = 0, ticks_to_wait = 0;

/* 设置随机数发生器的种子值, 0:[46Ch]是DOS系统中的ticks数 */
void set_rand_seed(void) {
    unsigned short int far* pticks;
    pticks = (unsigned short int far*)0x0000046C;
    seed = *pticks;
}

/* 产生一个[0, 7FFFh]之间的随机数 */
unsigned short int get_rand(void) {
    seed = (seed * 0x015A4E35L) + 1;
    return *((unsigned short int*)&seed + 1) & 0x7FFF;
}

/* 从pdic中随机选择一个单词呈现到屏幕上 */
void generate_one_word(void) {
    int i, j, d, r;
    int mark[26] = {0};
    r = get_rand() % 3;
    if (r > 0)  /* if(r==1 || r==2) */
        return; /*    do not generate a new word; */

    /* 当r==0时才产生一个单词, 防止速度过快来不及打 */
    for (j = 0; j < screen_words;
         j++) /* 根据屏幕上已显示单词的首字母设置mark */
    {         /* 注意屏幕上每个单词的首字母一定不相同 */
        mark[w[j].letter[0] - 'a'] =
            1; /* 若w[j]已在屏幕上, 则首字母对应的mark标为1, */
               /* 例如w[j]是单词"zebra", 则mark[25]=1 */
    }
    d = get_rand() & 1;
    if (d == 0) /* search from left to right */
    {
        for (j = 0; j < 26; j++)
            if (mark[j] == 0) /* found the unused word */
                break;
    } else /* search from right to left */
    {
        for (j = 25; j >= 0; j--)
            if (mark[j] == 0)
                break;
    }

    i = j; /* w[i] 将被显示在屏幕上 */
    if (screen_words < 24) {
        memset(w[screen_words].letter, 0, sizeof(w[0].letter));
        strncpy(w[screen_words].letter, pdic[i], 20);
        w[screen_words].y = 0; /* 新加入单词的y坐标总是0, 位于屏幕顶上 */
        w[screen_words].x = get_rand() % (80 - strlen(w[screen_words].letter));
        /* 新单词的x坐标随机产生, 但不能让它越过屏幕右边界 */
        w[screen_words].status = 0;
        w[screen_words].hit_len = 0;
        screen_words++;
        words_listed++;
    }
}

void show_char(int x, int y, char c, char color) {
    char far* p = _vp + (80 * y + x) * 2;
    *p = c;
    *(p + 1) = color;
}

void show_one_word(int i) {
    int j, n = strlen(w[i].letter);
    if (w[i].status >= 1) /* 1=hit, 2=to_be_destroyed */
    {
        for (j = 0; j < w[i].hit_len; j++)
            show_char(w[i].x + j, w[i].y, w[i].letter[j],
                      0x02); /* 已打字母显示绿色 */
        for (j = w[i].hit_len; j < n; j++)
            show_char(w[i].x + j, w[i].y, w[i].letter[j],
                      0x07); /* 没打字母显示白色 */
    } else                   /* w[i].status == 0, 该单词没有打中 */
    {
        for (j = 0; j < n; j++)
            show_char(w[i].x + j, w[i].y, w[i].letter[j],
                      0x07); /* 用白色显示整个单词 */
    }
}

void show_words(void) {
    int i;
    clrscr(); /* 清屏 */
    for (i = 0; i < screen_words; i++) {
        show_one_word(i);
    }
}

void show_score(void) {
    char buf[100];
    int i, n, percent = 0;
    if (words_listed != 0)
        percent = (words_hit * 100L) / words_listed;
    sprintf(buf, "words_listed=%d; words_hit=%d; words_lost=%d; hit_rate=%d%%",
            words_listed, words_hit, words_lost, percent);
    n = strlen(buf);
    for (i = 0; i < n; i++) {
        show_char(i, 24, buf[i], 0x17);
    }
}

void move_words_down(void) {
    int i;
    updating = 1; /* 在更新期间, 禁止int_9h()显示打中的字符 */
    /* 否则打中单词的下标即hit及坐标均有可能与屏幕上已显示的不对应 */
    for (i = 0; i < screen_words;
         i++) /* 屏幕上每个单词的y坐标加1, 表示向下移动一行 */
    {
        w[i].y++;
    }
    if (w[0].y >= 24) /* 若w[0]已掉到屏幕外 */
    {
        disable(); /* To ensure that there is no occurring of int_9h()
                      when we are updating array w and variable hit;
                      If we do not disable interrupts here, the int_9h()
                      occurring between memcpy() and hit-- will get the wrong
                      w[hit]. disable()相当于汇编语言中的cli指令
                     */
        memcpy(&w[0], &w[1],
               sizeof(w[0]) * (screen_words - 1)); /* 删除w[0]这个单词 */
        screen_words--;
        words_lost++;
        if (hit != -1) /* 打中单词的下标 */
            hit--;     /* 也要同步减1 */
        enable();      /* enable()相当于汇编语言中的sti指令 */
    }
    show_words();
    updating = 0; /* 更新结束 */
}

void get_char_color(int x, int y, char* pchar, char* pcolor) {
    char far* p = _vp + (y * 80 + x) * 2;
    *pchar = *p;
    *pcolor = *(p + 1);
}

/* 当w[i]的字母已全部打中时,即w[i].status==2时,
   int_08h()会调用本函数销毁w[i]这个单词, 但销毁
   单词并非一气呵成, 而是每过一个tick更新一下子弹
   的位置
 */
void draw_bullet(int i) {
    show_char(w[i].px, w[i].py, w[i].old_char, w[i].old_color);
    /* 在上次子弹的坐标(w[i].px, w[i].py)处以w[i].old_color这个颜色重画字符
       w[i].old_char, 即重画被子弹覆盖的字符
     */
    get_char_color(w[i].bx, w[i].by, &w[i].old_char, &w[i].old_color);
    /* 保存当前子弹坐标(w[i].bx, w[i].by)处的字符及颜色 */
    show_char(w[i].bx, w[i].by, 0x18,
              0x0C); /* 0x18=ascii of bullet, 0x0C=bright RED  */
    /* 在当前子弹坐标处画子弹 */
    w[i].px = w[i].bx; /* 更新上次子弹的x坐标 */
    w[i].py = w[i].by; /* 及y坐标 */
    w[i].by--; /* 当前子弹的y坐标减1,表示子弹继续向上移动 */
}

/* 时钟中断函数
   用来更新子弹的位置及对ticks_to_wait进行倒计数
 */
void interrupt int_8h(void) {
    int i;
    for (i = 0; i < screen_words; i++) /* search the word to be destroyed */
    {
        if (w[i].status == 2) /* 2=to_be_destroyed */
            break;
    }
    if (i < screen_words) /* found the word to be destroyed */
    {
        draw_bullet(i);
        if (w[i].by < w[i].y) /* the word has been hit by the bullet,
                                 子弹已向上穿过单词 */
        {
            memcpy(&w[i], &w[i + 1],
                   sizeof(w[0]) * (screen_words - 1 - i)); /* delete the word */
            if (hit != -1 && hit > i)
                hit--; /* Very important to update hit here!
                       // When there is a word being destroyed,
                       // there may be a new word being hit.
                       // In this case, when the previous word is deleted,
                       // if the new hit item is above the deleted one, the
                       // value of "hit" must be decremented.
                        */
            words_hit++;
            screen_words--;
        }
    }
    if (ticks_to_wait != 0)
        ticks_to_wait--;
    (*old_8h)(); /* transfer control to old clock interrupt */
}

/* 把键盘扫描码转化成ASCII码 */
unsigned char convert_key_to_ascii(unsigned char key) {
    static unsigned char alpha_table[26] = {
        /*a     b     c     d     e     f     g     h */
        0x1E, 0x30, 0x2E, 0x20, 0x12, 0x21, 0x22, 0x23,
        /*i     j     k     l     m     n     o     p */
        0x17, 0x24, 0x25, 0x26, 0x32, 0x31, 0x18, 0x19,
        /*q     r     s     t     u     v     w     x */
        0x10, 0x13, 0x1F, 0x14, 0x16, 0x2F, 0x11, 0x2D,
        /*y     z                                     */
        0x15, 0x2C};
    int i, n = sizeof(alpha_table) / sizeof(alpha_table[0]);
    for (i = 0; i < n; i++) {
        if (alpha_table[i] == key)
            break;
    }
    if (i < n)
        return 'a' + i;
    else
        return 0;
}

/* 初始化子弹 */
void prepare_for_firing(int i) {
    w[i].bx = w[i].x + strlen(w[i].letter) /
                           2; /* 子弹的当前x坐标设在w[i]这个单词的中间 */
    w[i].by = 23;             /* 子弹的当前y坐标设在23行 */
    w[i].px = w[i].bx; /* 子弹的上次x坐标 */
    w[i].py = 24;      /* 子弹的上次y坐标 */
    get_char_color(w[i].px, w[i].py, &w[i].old_char, &w[i].old_color);
    /* 保存子弹上次坐标(w[i].px, w[i].py)处的字符及颜色 */
}

/* 键盘中断函数 */
void interrupt int_9h(void) {
    unsigned char key, ascii;
    int i;
    key = inportb(0x60);            /* get current key's scan code */
    if (key == 0xE0 || key == 0xE1) /* extended key */
        goto key_done;
    if (key == 0x01) /* Esc is pressed */
    {
        stop = 1;
        goto key_done;
    }
    if ((key & 0x80) != 0) /* some key is released */
        goto key_done;
    ascii = convert_key_to_ascii(key);
    if (ascii == 0) /* non-alpha key */
        goto key_done;
    if (hit != -1) /* if the word was once hit */
    {
        if (w[hit].letter[hit_len] ==
            ascii) /* 判断w[hit]的剩余字母的首字母有没有打中 */
        {
            hit_len++;
            w[hit].hit_len = hit_len;
            if (!updating) /* 只有当move_words_down()函数没在更新屏幕内容时, */
                show_one_word(
                    hit); /* 才可以在int_9h()里面重画w[hit]更新刚打的字母颜色;
                             若当前move_words_down()函数正在更新屏幕内容,
                             则本次int_9h()函数暂时不更新刚打的字母颜色,
                             等到下次int_9h()时再更新。
                           */
            if (hit_len ==
                strlen(w[hit].letter)) /* 若w[hit]的全部字母都已打完 */
            {
                prepare_for_firing(hit); /* 准备发射子弹销毁该单词 */
                w[hit].status = 2; /* 2 = to be destroyed, w[hit]将被摧毁 */
                hit = -1; /* 当前打中单词的下标重新设成-1,表示没有单词被打中 */
                hit_len = 0; /* 当前打中单词的长度=0 */
            }
        } else /* wrong key was entered */
        {
            w[hit].status = 0;
            w[hit].hit_len = 0; /* 若打错字母,则已打的长度清零 */
            hit = -1;
            hit_len = 0;
        }
    } else /* if the word is hit for the 1st time */
    {
        for (i = 0; i < screen_words; i++) {
            if (w[i].letter[0] == ascii)
                break;
        }
        if (i < screen_words) {
            hit = i;
            hit_len = 1;
            w[hit].status = 1; /* being hit */
            w[hit].hit_len = hit_len;
            if (!updating)
                show_one_word(hit);
            if (hit_len == strlen(w[hit].letter)) {
                prepare_for_firing(hit);
                w[hit].status = 2; /* to be destroyed */
                hit = -1;
                hit_len = 0;
            }
        } /* if(i<screen_words) */
    }     /* if the word is hit for the 1st time */
key_done:
    outportb(0x20, 0x20); /* send EOI signal to interrupt controller */
}

main() {
    set_rand_seed();         /* 随机数初始化 */
    memset(w, 0, sizeof(w)); /* 清空25个单词 */
    screen_words = 0;        /* 目前屏幕上已显示的单词个数 */
    stop = 0;                /* 结束标志; 按Esc时, stop=1; */
    clrscr();                /* 清屏 */

    old_8h = getvect(8); /* 保存时钟中断向量 */
    old_9h = getvect(9); /* 保存键盘中断向量 */
    setvect(8, int_8h);  /* 修改时钟中断向量 */
    setvect(9, int_9h);  /* 修改键盘中断向量 */

    while (!stop) {
        ticks_to_wait = 12;
        while (ticks_to_wait != 0)
            ; /* wait 12 ticks */
              /* int_8h() will decrement ticks_to_wait on every tick */
        generate_one_word(); /* 数组末尾增加一个新单词 */
        move_words_down();   /* 屏幕上所有单词往下移动一行 */
        show_score();        /* 显示成绩 */
    }

    setvect(8, old_8h); /* 恢复时钟中断向量 */
    setvect(9, old_9h); /* 恢复键盘中断向量 */
    clrscr();
    puts("Done!");
    return 0;
}