# Find and/or download the MCU Firmware Package associated to a MCU family.
#
# Usage: find_package(STM32Cube COMPONENTS <MCU>)
#
# Component:
# - MCU (required): Name of the MCU.
#
# Output variables:
# - STM32_MCU: Name of the MCU.
# - STM32_MCU_SERIES: Series of the MCU: ex. F7
# - STM32_MCU_LINE: Line of the MCU: ex. 67
# - stm32cube_SOURCE_DIR: The directory where the STM32Cube associated to the MCU family is available.
#

include(FetchContent)
include(stm32/device)

if ("${STM32Cube_FIND_COMPONENTS}" STREQUAL "")
    message(FATAL_ERROR "Usage: find_package(STM32Cube COMPONENTS <MCU>)")
endif ()

stm32_extract_device_info(
        ${STM32Cube_FIND_COMPONENTS}
        STM32_MCU
        STM32_MCU_SERIES
        STM32_MCU_LINE
        STM32_MCU_PACKAGING_CODE
        STM32_MCU_FLASH_CODE
)

# Generate all family and series variant that will be needed by this tool.
set(STM32_MCU_SERIES_U "STM32${STM32_MCU_SERIES}xx")
string(TOLOWER ${STM32_MCU_SERIES_U} STM32_MCU_SERIES_L)
set(STM32_MCU_LINE_U "STM32${STM32_MCU_SERIES}${STM32_MCU_LINE}xx")
string(TOLOWER ${STM32_MCU_LINE_U} STM32_MCU_LINE_L)

# Print info we were able to determine from the name of the MCU
message(STATUS "MCU: ${STM32_MCU}")
message(STATUS "MCU series: ${STM32_MCU_SERIES_U}")
message(STATUS "MCU line: ${STM32_MCU_LINE_U}")

# Download the SMT32Cube from Git repositories.
FetchContent_Declare(
        STM32Cube
        GIT_REPOSITORY "https://github.com/STMicroelectronics/STM32Cube${STM32_MCU_SERIES}"
        EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(STM32Cube)

include("stm32/series/${STM32_MCU_SERIES}")

# Print more info we have obtained.
stm32_get_flash_size(FLASH_SIZE)
stm32_lookup_device_info(RAM RAM_SIZE)
message(STATUS "MCU Flash size: ${FLASH_SIZE}")
message(STATUS "MCU RAM size: ${RAM_SIZE}")

# Create output directory where the configurations will be copied from the template:
# - HAL configuration
# - Linker script
set(STM32_GENERATED_OUTPUT_DIR "${CMAKE_BINARY_DIR}/_stm32_generated")
file(MAKE_DIRECTORY ${STM32_GENERATED_OUTPUT_DIR})
