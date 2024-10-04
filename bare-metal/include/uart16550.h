#ifndef __UART_16550_H__
#define __UART_16550_H__

void uart16550_init(void);
void uart16550_putchar(unsigned char ch);
int uart16550_getchar();
#endif
