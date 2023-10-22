if (NOT DEFINED stm32cube_SOURCE_DIR)
    message(FATAL_ERROR "Make sure to call find_package(STM32Cube COMPONENTS <MCU>) before calling this.")
endif ()

include(stm32_cmake)

set(CMSIS_TARGET "CMSIS")
set(CMSIS_ROOT_DIR "${stm32cube_SOURCE_DIR}/Drivers/CMSIS")
set(CMSIS_DEVICE_ROOT_DIR "${CMSIS_ROOT_DIR}/Device/ST/${STM32_MCU_SERIES_U}")

# Append the startup source in assembler associated to the device line.
set(CMSIS_STARTUP_SOURCE "${CMSIS_DEVICE_ROOT_DIR}/Source/Templates/gcc/startup_${STM32_MCU_LINE_L}.s")

# List C source files associated to the MCU series.
file(GLOB CMSIS_SOURCES "${CMSIS_DEVICE_ROOT_DIR}/Source/Templates/*.c")
list(APPEND CMSIS_SOURCES ${CMSIS_STARTUP_SOURCE})

add_library(${CMSIS_TARGET} INTERFACE ${CMSIS_SOURCES})

# Include generic headers and headers specific to the MCU series.
target_include_directories(${CMSIS_TARGET}
        INTERFACE "${CMSIS_ROOT_DIR}/Include"
        INTERFACE "${CMSIS_ROOT_DIR}/Device/ST/${STM32_MCU_SERIES_U}/Include")

stm32_configure_target(INTERFACE ${CMSIS_TARGET})

set(CMSIS_FOUND 1)
