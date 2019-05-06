ENTRY(_Reset)
SECTIONS
{
    . = 0x0;

    .text : {
        src/startup.o(.vector_table)
        *(.text)
        *(.rodata)
    }

    .bss : {
        _bss_start = .;
        *(.bss)
        . = ALIGN(8);
        _bss_end = .;
    }

    data : {
        _data_start = .;
        *(.data)
        . = ALIGN(8);
        _data_end = .;
    }

    . = ALIGN(8);
    _stack_start = .;
    . = . + 0x1000; /* 4kB of stack memory */
    _stack_end = .;
}
