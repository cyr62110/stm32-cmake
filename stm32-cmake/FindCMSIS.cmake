if (NOT DEFINED stm32cube_SOURCE_DIR)
    message(FATAL_ERROR "Make sure to call find_package(STM32Cube COMPONENTS <MCU>) before calling this.")
endif ()

set(CMSIS_ROOT_DIR "${stm32cube_SOURCE_DIR}/Drivers/CMSIS")
set(CMSIS_DEVICE_ROOT_DIR "${CMSIS_ROOT_DIR}/Device/ST/${STM32_MCU_FAMILY}")

set(CMSIS_INCLUDE_DIRS
        "${CMSIS_ROOT_DIR}/Include"
        "${CMSIS_ROOT_DIR}/Device/ST/${STM32_MCU_FAMILY}/Include")

# List C source files associated to the device family.
file(GLOB CMSIS_SOURCES
        "${CMSIS_DEVICE_ROOT_DIR}/Source/Templates/*.c")

# Append the startup source in assembler associated to the device family.
set(CMSIS_STARTUP_SOURCE
        "${CMSIS_DEVICE_ROOT_DIR}/Source/Templates/gcc/startup_${STM32_MCU_SERIES_L}.s")

list(APPEND CMSIS_SOURCES ${CMSIS_STARTUP_SOURCE})

set(CMSIS_FOUND 1)
