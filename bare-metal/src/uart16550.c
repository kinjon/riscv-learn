#include <uart16550.h>

volatile unsigned char* uart16550;
static unsigned int uart16550_clock = 10000000;

#define UART_BASE_ADDRESS   (0x10000000)
#define UART_DEFAULT_BAUD   (38400)
#define UART_REG_QUEUE      (0) // rx/tx fifo data
#define UART_REG_DLL        (0) // divisor latch (LSB)
#define UART_REG_IER        (1) // interrupt enable register
#define UART_REG_DLM        (1) // divisor latch (MSB)
#define UART_REG_FCR        (2) // fifo control register
#define UART_REG_LCR        (3) // line control register
#define UART_REG_MCR        (4) // modem control register
#define UART_REG_LSR        (5) // line status register
#define UART_REG_MSR        (6) // modem status register
#define UART_REG_SCR        (7) // scratch register
#define UART_REG_STATUS_RX  (0x01)
#define UART_REG_STATUS_TX  (0x20)

void uart16550_putchar(unsigned char ch)
{
    while ((uart16550[UART_REG_LSR] & UART_REG_STATUS_TX) == 0);
    uart16550[UART_REG_QUEUE] = ch;
}

int uart16550_getchar()
{
    if (uart16550[UART_REG_LSR] & UART_REG_STATUS_RX)
        return uart16550[UART_REG_QUEUE];
    return -1;
}

void uart16550_init(void)
{
    unsigned int divisor = uart16550_clock / (16 * UART_DEFAULT_BAUD);

    uart16550 = (void*)(unsigned int*)(UART_BASE_ADDRESS);
    uart16550[UART_REG_IER] = 0x00; // Disable all interrupts
    uart16550[UART_REG_LCR] = 0x80; // Enable DLAB (set baud rate divisor)
    uart16550[UART_REG_DLL] = (unsigned char)divisor; // Set divisor (lo byte)
    uart16550[UART_REG_DLM] = (unsigned char)(divisor >> 8); //     (hi byte)
    uart16550[UART_REG_LCR] = 0x03; // 8 bits, no parity, one stop bit
    uart16550[UART_REG_FCR] = 0xC7; // Enable FIFO, clear them, with 14-byte threshold
}