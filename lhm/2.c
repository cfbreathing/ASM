/* 请把本文件拖到XP虚拟机的桌面上,
   再把它拖给虚拟机桌面上的TC快捷方式即可打开TC编译器，
   最后选菜单Alt+R -> Run
   即可运行程序。
 */
#include <stdio.h>
#include <bios.h>
unsigned char remove_quotation_mark(unsigned char c)
{
   if(c >= '0' && c <= '9')
      c -= '0';
   else /* c >= 'A' && c <= 'F' */
      c = c - 'A' + 10;
   return c;
}

unsigned char add_quotation_mark(unsigned char c)
{
   if(c >= 0 && c <= 9)
      c += '0';
   else /* c >= 10 && c <= 15 */
      c = c - 10 + 'A';
   return c;
}

main()
{
   unsigned char a, c, buf[2], hex[2];
   unsigned char far *p=(char far *)0xB8000000, far *q;
   /* unsigned char far *用来定义远指针。
      远指针是指既包含段地址又包含偏移地址的指针, 近指针是指仅包含偏移地址的指针。
      远指针的值以32位整数的形式存储, 近指针则以16位整数的形式存储。
      p的值等于0xB8000000用来表示汇编语言中的地址B800:0000。
    */
   int i;
   buf[0] = getchar();
   buf[1] = getchar();
   buf[0] = remove_quotation_mark(buf[0]);
   buf[1] = remove_quotation_mark(buf[1]);
   a = (buf[0] << 4) | buf[1]; /* 汇编语言中, 用shl指令做左移, or指令做或运算 */
   q = p;
   for(i=0; i<16; i++)
   {
      c = a + i;
      q[0] = c;          /* 在(0,i)坐标处输出字符c */
      q[1] = 0x7C;       /* 白色背景, 高亮红色前景 */
      hex[0] = c >> 4;   /* 汇编语言中, 用shr指令实现右移 */
      hex[1] = c & 0x0F; /* 汇编语言中, 用and指令实现与运算 */
      hex[0] = add_quotation_mark(hex[0]);
      hex[1] = add_quotation_mark(hex[1]);
      q[2] = hex[0];     /* 在(1,i)坐标处输出c的十六进制ASCII码 */
      q[3] = 0x1A;       /* 蓝色背景, 高亮绿色前景 */
      q[4] = hex[1];
      q[5] = 0x1A;
      q += 160;          /* q指向下一行的行首, 注意显卡的每行有80*2即160字节 */
   }
   bioskey(0);           /* 敲任意键 */
                         /* 汇编语言中可以用mov ah, 0; int 16h;实现bioskey(0)的功能 */
}