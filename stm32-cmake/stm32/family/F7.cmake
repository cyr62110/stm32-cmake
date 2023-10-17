set(STM32_MCU_OPTIONS
        "-mcpu=cortex-m7"
        "-mfpu=fpv5-sp-d16"
        "-mfloat-abi=hard")

set(STM32_COMPILE_OPTIONS "${STM32_MCU_OPTIONS}")
set(STM32_LINK_OPTIONS "${STM32_MCU_OPTIONS}")
