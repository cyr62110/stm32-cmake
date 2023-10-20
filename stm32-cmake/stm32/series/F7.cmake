set(STM32_SERIES_DEVICE_INFO_HEADERS "LINE" "RAM")
set(STM32_SERIES_DEVICE_INFO
        67 512K
)

set(STM32_MCU_OPTIONS
        "-mcpu=cortex-m7"
        "-mfpu=fpv5-sp-d16"
        "-mfloat-abi=hard")

set(STM32_COMPILE_OPTIONS "${STM32_MCU_OPTIONS}")
set(STM32_LINK_OPTIONS "${STM32_MCU_OPTIONS}")
