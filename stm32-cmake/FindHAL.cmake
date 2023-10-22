# Find the HAL library and import its components into the project.
# If no components is defined, then all component will be linked resulting in a bigger executable.
#
# Usage: find_package(HAL) or find_package(HAL COMPONENTS <HAL components>)
#

if (NOT DEFINED stm32cube_SOURCE_DIR)
    message(FATAL_ERROR "Make sure to call find_package(STM32Cube COMPONENTS <MCU>) before calling this.")
endif ()

set(HAL_TARGET "HAL")
set(HAL_ROOT_DIR "${stm32cube_SOURCE_DIR}/Drivers/${STM32_MCU_SERIES_U}_HAL_Driver")
set(HAL_CONFIG_FILENAME "${STM32_MCU_SERIES_L}_hal_conf.h")

# List sources excluding template.
file(GLOB HAL_SOURCES "${HAL_ROOT_DIR}/Src/*.c")
list(FILTER HAL_SOURCES EXCLUDE REGEX "^.*_template\.c$")

add_library(${HAL_TARGET} INTERFACE ${HAL_SOURCES})

# Include generic headers and headers specific to the MCU series.
target_include_directories(${CMSIS_TARGET}
        INTERFACE "${HAL_ROOT_DIR}/Inc")

stm32_configure_target(${HAL_TARGET})

set(HAL_FOUND 1)
