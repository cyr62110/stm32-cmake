include(stm32/device)

function(stm32_generic_get_linker_info
        linker_info
        size_output_var
        origin_output_var
)
    # Flash
    if (linker_info STREQUAL "FLASH")
        stm32_get_flash_size(FLASH_SIZE)
        if (FLASH_SIZE)
            set(${size_output_var} ${FLASH_SIZE} PARENT_SCOPE)
            set(${origin_output_var} 0x08000000 PARENT_SCOPE)
        endif ()
        return()
    endif ()

    # RAM
    if (linker_info STREQUAL "RAM")
        stm32_lookup_device_info(RAM RAM_SIZE)
        if (RAM_SIZE)
            set(${size_output_var} ${RAM_SIZE} PARENT_SCOPE)
            set(${origin_output_var} 0x20000000 PARENT_SCOPE)
        endif ()
    endif ()

    # TODO: CCRAM - ORIGIN 0x10000000
    # TODO: Shared RAM - ORIGIN 0x20030000

    # Heap
    if (linker_info STREQUAL "HEAP")
        stm32_get_linker_info("RAM" RAM_SIZE _)
        if (RAM_SIZE STREQUAL "2K")
            set(${size_output_var} 0x100 PARENT_SCOPE)
        else ()
            set(${size_output_var} 0x200 PARENT_SCOPE)
        endif ()
    endif ()

    # Stack
    if (linker_info STREQUAL "STACK")
        stm32_get_linker_info("RAM" RAM_SIZE _)
        if (RAM_SIZE STREQUAL "2K")
            set(${size_output_var} 0x200 PARENT_SCOPE)
        else ()
            set(${size_output_var} 0x400 PARENT_SCOPE)
        endif ()
    endif ()

endfunction()

function(stm32_get_linker_info
        linker_info
        size_output_var
        origin_output_var
)
    # TODO: Check if it exists a specific function of this function for series, line, MCU.
    # TODO: In this case, use this specific function.

    stm32_generic_get_linker_info(${linker_info} GENERIC_SIZE GENERIC_ORIGIN)

    if (GENERIC_SIZE)
        set(${size_output_var} ${GENERIC_SIZE} PARENT_SCOPE)
    endif ()

    if (GENERIC_ORIGIN)
        set(${origin_output_var} ${GENERIC_ORIGIN} PARENT_SCOPE)
    endif ()
endfunction()

function(stm32_generate_linker_script)
    set(LINKER_FILE "${STM32_GENERATED_OUTPUT_DIR}/${STM32_MCU}.ld")

    stm32_get_linker_info("FLASH" FLASH_SIZE FLASH_ORIGIN)
    if (NOT FLASH_SIZE OR NOT FLASH_ORIGIN)
        message(FATAL_ERROR "Unable to determine Flash size and/or origin to generate linker script for ${STM32_MCU}.")
    endif ()

    stm32_get_linker_info("RAM" RAM_SIZE RAM_ORIGIN)
    if (NOT RAM_SIZE OR NOT RAM_ORIGIN)
        message(FATAL_ERROR "Unable to determine RAM size and/or origin to generate linker script for ${STM32_MCU}.")
    endif ()

    stm32_get_linker_info("HEAP" HEAP_SIZE _)
    stm32_get_linker_info("STACK" STACK_SIZE _)
    if (NOT HEAP_SIZE OR NOT STACK_SIZE)
        message(FATAL_ERROR "Unable to determine stack and/or heap size to generate linker script for ${STM32_MCU}.")
    endif ()

    file(WRITE ${LINKER_FILE} "ENTRY(Reset_Handler)\n")
    file(APPEND ${LINKER_FILE} "\n")

    # Highest address of the user mode stack: End of RAM
    file(APPEND ${LINKER_FILE} "_estack = ORIGIN(RAM) + LENGTH(RAM);\n")
    file(APPEND ${LINKER_FILE} "_Min_Heap_Size = ${HEAP_SIZE};\n")
    file(APPEND ${LINKER_FILE} "_Min_Stack_Size = ${STACK_SIZE};\n")
    file(APPEND ${LINKER_FILE} "\n")

    # Specify the memory areas
    file(APPEND ${LINKER_FILE} "MEMORY {\n")
    file(APPEND ${LINKER_FILE} "RAM (rwx) : ORIGIN = ${RAM_ORIGIN}, LENGTH = ${RAM_SIZE}\n")
    file(APPEND ${LINKER_FILE} "FLASH (rx) : ORIGIN = ${FLASH_ORIGIN}, LENGTH = ${FLASH_SIZE}\n")
    file(APPEND ${LINKER_FILE} "}\n")
    file(APPEND ${LINKER_FILE} "\n")

    # Define output sections
    file(APPEND ${LINKER_FILE} "SECTIONS {\n")

    # The startup code goes first into FLASH
    file(APPEND ${LINKER_FILE} ".isr_vector : {\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "KEEP(*(.isr_vector))\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "} >FLASH\n")
    file(APPEND ${LINKER_FILE} "\n")

    # The program code and other data goes into FLASH
    file(APPEND ${LINKER_FILE} ".text : {\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "*(.text)\n")
    file(APPEND ${LINKER_FILE} "*(.text*)\n")
    file(APPEND ${LINKER_FILE} "*(.glue_7)\n")
    file(APPEND ${LINKER_FILE} "*(.glue_7t)\n")
    file(APPEND ${LINKER_FILE} "*(.eh_frame)\n")
    file(APPEND ${LINKER_FILE} "\n")
    file(APPEND ${LINKER_FILE} "KEEP (*(.init))\n")
    file(APPEND ${LINKER_FILE} "KEEP (*(.fini))\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "_etext = .;\n") # define a global symbols at end of code
    file(APPEND ${LINKER_FILE} "} >FLASH\n")
    file(APPEND ${LINKER_FILE} "\n")

    # Constant data goes into FLASH
    file(APPEND ${LINKER_FILE} ".rodata : {\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "*(.rodata)\n")
    file(APPEND ${LINKER_FILE} "*(.rodata*)\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "} >FLASH\n")
    file(APPEND ${LINKER_FILE} "\n")

    file(APPEND ${LINKER_FILE} ".ARM.extab : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH\n")
    file(APPEND ${LINKER_FILE} ".ARM : {\n")
    file(APPEND ${LINKER_FILE} "__exidx_start = .;\n")
    file(APPEND ${LINKER_FILE} "*(.ARM.exidx*)\n")
    file(APPEND ${LINKER_FILE} "__exidx_end = .;\n")
    file(APPEND ${LINKER_FILE} "} >FLASH\n")
    file(APPEND ${LINKER_FILE} "\n")

    file(APPEND ${LINKER_FILE} ".preinit_array : {\n")
    file(APPEND ${LINKER_FILE} "PROVIDE_HIDDEN (__preinit_array_start = .);\n")
    file(APPEND ${LINKER_FILE} "KEEP (*(.preinit_array*))\n")
    file(APPEND ${LINKER_FILE} "PROVIDE_HIDDEN (__preinit_array_end = .);\n")
    file(APPEND ${LINKER_FILE} "} >FLASH\n")
    file(APPEND ${LINKER_FILE} ".init_array : {\n")
    file(APPEND ${LINKER_FILE} "PROVIDE_HIDDEN (__init_array_start = .);\n")
    file(APPEND ${LINKER_FILE} "KEEP (*(SORT(.init_array.*)))\n")
    file(APPEND ${LINKER_FILE} "KEEP (*(.init_array*))\n")
    file(APPEND ${LINKER_FILE} "PROVIDE_HIDDEN (__init_array_end = .);\n")
    file(APPEND ${LINKER_FILE} "} >FLASH\n")
    file(APPEND ${LINKER_FILE} ".fini_array : {\n")
    file(APPEND ${LINKER_FILE} "PROVIDE_HIDDEN (__fini_array_start = .);\n")
    file(APPEND ${LINKER_FILE} "KEEP (*(SORT(.fini_array.*)))\n")
    file(APPEND ${LINKER_FILE} "KEEP (*(.fini_array*))\n")
    file(APPEND ${LINKER_FILE} "PROVIDE_HIDDEN (__fini_array_end = .);\n")
    file(APPEND ${LINKER_FILE} "} >FLASH\n")
    file(APPEND ${LINKER_FILE} "\n")

    # used by the startup to initialize data
    file(APPEND ${LINKER_FILE} "_sidata = LOADADDR(.data);\n")
    file(APPEND ${LINKER_FILE} "\n")

    # Initialized data sections goes into RAM, load LMA copy after code
    file(APPEND ${LINKER_FILE} ".data : {\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "_sdata = .;\n") # create a global symbol at data start
    file(APPEND ${LINKER_FILE} "*(.data)\n")
    file(APPEND ${LINKER_FILE} "*(.data*)\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "_edata = .;\n") # define a global symbol at data end
    file(APPEND ${LINKER_FILE} "} >RAM AT> FLASH\n")
    file(APPEND ${LINKER_FILE} "\n")

    # Uninitialized data section
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} ".bss : {\n")
    file(APPEND ${LINKER_FILE} "_sbss = .;\n") # This is used by the startup in order to initialize the .bss secion
    file(APPEND ${LINKER_FILE} "__bss_start__ = _sbss;\n")
    file(APPEND ${LINKER_FILE} "*(.bss)\n")
    file(APPEND ${LINKER_FILE} "*(.bss*)\n")
    file(APPEND ${LINKER_FILE} "*(COMMON)\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(4);\n")
    file(APPEND ${LINKER_FILE} "_ebss = .;\n") # define a global symbol at bss end
    file(APPEND ${LINKER_FILE} "__bss_end__ = _ebss;\n")
    file(APPEND ${LINKER_FILE} "} >RAM\n")
    file(APPEND ${LINKER_FILE} "\n")

    # User_heap_stack section, used to check that there is enough RAM left
    file(APPEND ${LINKER_FILE} "._user_heap_stack : {\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(8);\n")
    file(APPEND ${LINKER_FILE} "PROVIDE ( end = . );\n")
    file(APPEND ${LINKER_FILE} "PROVIDE ( _end = . );\n")
    file(APPEND ${LINKER_FILE} ". = . + _Min_Heap_Size;\n")
    file(APPEND ${LINKER_FILE} ". = . + _Min_Stack_Size;\n")
    file(APPEND ${LINKER_FILE} ". = ALIGN(8);\n")
    file(APPEND ${LINKER_FILE} "} >RAM\n")
    file(APPEND ${LINKER_FILE} "\n")

    # Remove information from the standard libraries
    file(APPEND ${LINKER_FILE} "/DISCARD/ : {\n")
    file(APPEND ${LINKER_FILE} "libc.a ( * )\n")
    file(APPEND ${LINKER_FILE} "libm.a ( * )\n")
    file(APPEND ${LINKER_FILE} "libgcc.a ( * )\n")
    file(APPEND ${LINKER_FILE} "}\n")
    file(APPEND ${LINKER_FILE} "\n")

    file(APPEND ${LINKER_FILE} "}\n")

    set(STM32_LINKER_SCRIPT_FILE ${LINKER_FILE} PARENT_SCOPE)
endfunction()

function(stm32_configure_linker_script target)
    # Check if the linker script already exists.
    # TODO

    if (STM32_LINKER_SCRIPT_FILE)
        message(STATUS "Found existing linker script ${STM32_LINKER_SCRIPT_FILE}")
    else ()
        stm32_generate_linker_script()
        message(STATUS "Using linker script generated at ${STM32_LINKER_SCRIPT_FILE}")
    endif ()
    target_link_options(${PROJECT_NAME} PUBLIC "-T${STM32_LINKER_SCRIPT_FILE}")
endfunction()
