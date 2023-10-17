# Find the HAL library and import its components into the project.
# If no components is defined, then all component will be linked resulting in a bigger executable.
#
# Usage: find_package(HAL) or find_package(HAL COMPONENTS <HAL components>)
#

if (NOT DEFINED stm32cube_SOURCE_DIR)
    message(FATAL_ERROR "Make sure to call find_package(STM32Cube COMPONENTS <MCU>) before calling this.")
endif ()

set(HAL_ROOT_DIR "${stm32cube_SOURCE_DIR}/Drivers/${STM32_MCU_FAMILY}_HAL_Driver")

set(HAL_INCLUDE_DIRS "${HAL_ROOT_DIR}/Inc")
set(HAL_CONFIG_FILENAME "${STM32_MCU_FAMILY_L}_hal_conf.h")

if ("${HAL_FIND_COMPONENTS}" STREQUAL "")
    file(GLOB HAL_SOURCES "${HAL_ROOT_DIR}/Src/*.c")
    list(FILTER HAL_SOURCES EXCLUDE REGEX "^.*_template\.c$")
else ()
    # TODO
endif ()

set(HAL_FOUND 1)
