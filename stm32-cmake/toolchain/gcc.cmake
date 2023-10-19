set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

find_program(CMAKE_C_COMPILER NAMES arm-none-eabi-gcc)
find_program(CMAKE_CXX_COMPILER NAMES arm-none-eabi-g++)
find_program(CMAKE_ASM_COMPILER NAMES arm-none-eabi-gcc)
find_program(CMAKE_OBJCOPY NAMES arm-none-eabi-objcopy)
find_program(CMAKE_OBJDUMP NAMES arm-none-eabi-objdump)
find_program(CMAKE_SIZE NAMES arm-none-eabi-size)
find_program(CMAKE_DEBUGGER NAMES arm-none-eabi-gdb)
find_program(CMAKE_CPPFILT NAMES arm-none-eabi-c++filt)

set(CMAKE_EXECUTABLE_SUFFIX_C .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)
set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)

# This should be safe to set for a bare-metal cross-compiler
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
