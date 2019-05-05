void print_uart0(const char *s);

int main();

extern "C" {
    void entrypoint() {
        asm("ldr sp, =stack_top");
        main();
    }
}
