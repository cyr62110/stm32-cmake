# Find the HAL library and import its components into the project.
# If no components is defined, then all component will be linked resulting in a bigger executable.
#
# Usage: find_package(HAL) or find_package(HAL COMPONENTS <HAL components>)
#

if (NOT DEFINED stm32cube_SOURCE_DIR)
    message(FATAL_ERROR "Make sure to call find_package(STM32Cube COMPONENTS <MCU>) before calling this.")
endif ()

set(HAL_ROOT_DIR "${stm32cube_SOURCE_DIR}/Drivers/${STM32_MCU_FAMILY}_HAL_Driver")
string(TOLOWER ${STM32_MCU_FAMILY} HAL_SHORT_FAMILY)

set(HAL_INCLUDE_DIRS "${HAL_ROOT_DIR}/Inc")

if ("${HAL_FIND_COMPONENTS}" STREQUAL "")
    file(GLOB HAL_SOURCES "${HAL_ROOT_DIR}/Src/*.c")
    list(FILTER HAL_SOURCES EXCLUDE REGEX "^.*_template\.c$")
else ()
    # TODO
endif ()

set(HAL_FOUND 1)
