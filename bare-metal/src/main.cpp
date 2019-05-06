volatile unsigned int* const UART0DR = (unsigned int*) 0x10009000;

void print_uart0(const char *s) {
    while (*s != '\0') { /* Loop until end of string */
        *UART0DR = (unsigned int)(*s); /* Transmit char */
        s++; /* Next char */
    }
}

// class Teste {
// public:
//     const char* str;

//     Teste(const char* _str) : str{_str} {}
// };

// const char* j = "Oi tudo bem?";

// Teste t{j};

extern "C" {
    int main() {
        asm("movt r3, 0xAAAA");
        print_uart0("Hello world!\n");
        asm("movt r4, 0xDDDD");
        while(1);
    }
}
