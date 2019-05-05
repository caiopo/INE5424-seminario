volatile unsigned int* const UART0DR = (unsigned int*) 0x10009000;

void print_uart0(const char *s) {
    while (*s != '\0') { /* Loop until end of string */
        *UART0DR = (unsigned int)(*s); /* Transmit char */
        s++; /* Next char */
    }
}

int main() {
    print_uart0("Hello world!\n");
    return 0;
}
