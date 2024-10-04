#include <uart16550.h>

int main()
{
    uart16550_init();
    uart16550_putchar('H');
    uart16550_putchar('e');
    uart16550_putchar('l');
    uart16550_putchar('l');
    uart16550_putchar('o');
    uart16550_putchar(',');
    uart16550_putchar('R');
    uart16550_putchar('I');
    uart16550_putchar('S');
    uart16550_putchar('C');
    uart16550_putchar('V');
    uart16550_putchar('\n');
    while(1) {
        int ret;
        unsigned char c;
        ret = uart16550_getchar();
        if (-1 != ret) {
            c = (unsigned char)(ret);
            uart16550_putchar(c);
        }
    }
    return 0;
}
