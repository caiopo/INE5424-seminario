volatile unsigned int* const UART0DR = (unsigned int*) 0x10009000;

void print_uart0(const char *s) {
    while (*s != '\0') { /* Loop until end of string */
        *UART0DR = (unsigned int)(*s); /* Transmit char */
        s++; /* Next char */
    }
}

class SideEffect {
public:
    SideEffect(const char* s): _s(s) {
        print_uart0("SideEffect created ");
        print_uart0(_s);
        print_uart0("\n");
    }

    ~SideEffect() {
        print_uart0("SideEffect destroyed ");
        print_uart0(_s);
        print_uart0("\n");
    }
private:
    const char* _s;
};

SideEffect se_global1("global 1");
SideEffect se_global2("global 2");
SideEffect se_global3("global 3");
SideEffect se_global4("global 4");
SideEffect se_global5("global 5");

extern "C" {
    int main() {
        SideEffect se_local("local");

        print_uart0("Hello world!\n");
    }

    void atexit() {}
}
