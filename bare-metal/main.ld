SECTIONS {
    . = 0x0;

    .startup : {
        src/startup.o(.vector_table)
    }

    . = 0x10000;

    .text : {
        *(.entry)
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

    init_array : {
        _init_array_start = .;
        *(.init_array)
        *(.init_array.*)
        _init_array_end = .;
    }

    fini_array : {
        _fini_array_start = .;
        *(.fini_array)
        *(.fini_array.*)
        _fini_array_end = .;
    }

    . = ALIGN(8);
    _stack_start = .;
    . = . + 0x1000; /* 4kB of stack memory */
    _stack_end = .;
}
