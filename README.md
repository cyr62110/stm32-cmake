# stm32-cmake
Base project to build STM32 application using [CMake](https://cmake.org/) and GCC toolchain.

This project is designed to work with a single microcontroller for a project.
Changing the microcontroller requires to regenerate your Makefiles.

## Requirements

- CMake 3.21 or greater

## Build your project

Generate the Makefiles. 
Do not forget to configure the cross-compile toolchain with the option **CMAKE_TOOLCHAIN_FILE** 
according to your system (see [Toolchains](#cross-compile-toolchains)).

```bash
cmake -B . \
  -DEXECUTABLE_OUTPUT_PATH=output \
  -DCMAKE_TOOLCHAIN_FILE=cmake/stm32/toolchain/gcc.cmake
```

Generate the binaries in the **EXECUTABLE_OUTPUT_PATH** (output in this example).

```bash
make all
```

```bash
st-flash --format ihex write output/stm32cmake.elf
```

