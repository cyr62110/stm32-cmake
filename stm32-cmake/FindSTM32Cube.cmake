# Find and/or download the MCU Firmware Package associated to a MCU family.
#
# Usage: find_package(STM32Cube COMPONENTS <MCU>)
#
# Component:
# - MCU (required): Name of the MCU.
#
# Output variables:
# - STM32_MCU: Name of the MCU.
# - STM32_MCU_FAMILY: Family of the MCU: ex. STM32F7xx
# - STM32_MCU_FAMILY_L: Lower case version of STM32_MCU_FAMILY: ex. stm32f7xx
# - STM32_MCU_SHORT_FAMILY: Short name of the MCU family: ex. F7
# - STM32_MCU_SERIES: Series of the MCU: ex. STM32F767xx
# - STM32_MCU_SERIES_L: Lower case version of STM32_MCU_SERIES: ex. stm32f767xx
# - stm32cube_SOURCE_DIR: The directory where the STM32Cube associated to the MCU family is available.

include(FetchContent)
include(stm32/families)
include(stm32/series)

if ("${STM32Cube_FIND_COMPONENTS}" STREQUAL "")
    message(FATAL_ERROR "Usage: find_package(STM32Cube COMPONENTS <MCU family>)")
endif ()

string(TOUPPER ${STM32Cube_FIND_COMPONENTS} STM32_MCU)
extract_stm32_short_family(${STM32_MCU} STM32_MCU_SHORT_FAMILY)
compute_stm32_family(${STM32_MCU_SHORT_FAMILY} STM32_MCU_FAMILY)
string(TOLOWER ${STM32_MCU_FAMILY} STM32_MCU_FAMILY_L)

message(STATUS "MCU: ${STM32_MCU}")
message(STATUS "MCU family: (${STM32_MCU_SHORT_FAMILY}) ${STM32_MCU_FAMILY}")

# Download the SMT32Cube from Git repositories.
FetchContent_Declare(
        STM32Cube
        GIT_REPOSITORY "https://github.com/STMicroelectronics/STM32Cube${STM32_MCU_SHORT_FAMILY}"
        EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(STM32Cube)

compute_stm32_mcu_series(${STM32_MCU} ${STM32_MCU_FAMILY} STM32_MCU_SERIES)
string(TOLOWER ${STM32_MCU_SERIES} STM32_MCU_SERIES_L)
message(STATUS "MCU series: ${STM32_MCU_SERIES}")

# Export the compile & link options for the MCU.
include("stm32/family/${STM32_MCU_SHORT_FAMILY}")
