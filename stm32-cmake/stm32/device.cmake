# Extract information about the series, line from the name of the MCU.
#
# STM32 family of product follow this naming convention:
# https://www.digikey.fr/en/maker/tutorials/2020/understanding-stm32-naming-conventions
#
# Output variables: Name of the variable where the value will be output in the parent scope. (example based on STM32F777ZI)
# - mcu_output_variable: The name of the microcontroller.
# - series_output_variable: The series of the microcontroller: ex. F7
# - line_output_variable: The line of the microcontroller: ex. 77
# - packaging_code_output_variable: A letter describing the number of pins of the microcontroller: ex. Z (144)
# - flash_code_output_variable: A letter describing the flash size of the microcontroller: ex. I (2048kb)
#
function(stm32_extract_device_info mcu
        mcu_output_variable
        series_output_variable
        line_output_variable
        packaging_code_output_variable
        flash_code_output_variable
)
    string(TOUPPER ${mcu} MCU_U)
    if (NOT ${MCU_U} MATCHES "^STM32([A-Z0-9][A-Z0-9])([A-Z0-9]+)([A-Z0-9])([A-Z0-9])$")
        message(FATAL_ERROR "MCU ${mcu} is not supported by this tool.")
    endif ()

    set(${mcu_output_variable} ${MCU_U} PARENT_SCOPE)
    set(${series_output_variable} ${CMAKE_MATCH_1} PARENT_SCOPE)
    set(${line_output_variable} ${CMAKE_MATCH_2} PARENT_SCOPE)
    set(${packaging_code_output_variable} ${CMAKE_MATCH_3} PARENT_SCOPE)
    set(${flash_code_output_variable} ${CMAKE_MATCH_4} PARENT_SCOPE)
endfunction()

# Extract all the values associated to the current MCU from the STM32_SERIES_DEVICE_INFO hardcoded table.
function(stm32_extract_device_info_line output_variable)
    if (NOT STM32_SERIES_DEVICE_INFO_HEADERS OR NOT STM32_SERIES_DEVICE_INFO)
        message(FATAL_ERROR "No device information available for series ${STM32_SERIES_U}.")
    endif ()

    if (NOT STM32_MCU_CORE)
        set(LOOKUP ${STM32_MCU_LINE})
    else ()
        set(LOOKUP "${STM32_MCU_LINE}_${STM32_MCU_CORE}")
    endif ()

    list(FIND STM32_SERIES_DEVICE_INFO ${LOOKUP} INDEX)
    if (INDEX EQUAL -1)
        return()
    endif ()

    set(OUTPUT "")
    foreach (HEADER IN LISTS STM32_SERIES_DEVICE_INFO_HEADERS)
        list(GET STM32_SERIES_DEVICE_INFO ${INDEX} DEVICE_INFO)
        list(APPEND OUTPUT ${DEVICE_INFO})
        math(EXPR INDEX "${INDEX} + 1")
    endforeach ()

    set(${output_variable} ${OUTPUT} PARENT_SCOPE)
endfunction()

# Lookup the selected device info from the hardcoded table.
# Available info are:
# - RAM
# - CCRAM
#
function(stm32_lookup_device_info header output_variable)
    if (NOT STM32_SERIES_DEVICE_INFO_HEADERS)
        message(FATAL_ERROR "No device information available for series ${STM32_SERIES_U}.")
    endif ()

    list(FIND STM32_SERIES_DEVICE_INFO_HEADERS ${header} HEADER_INDEX)
    if (HEADER_INDEX EQUAL -1)
        return()
    endif ()

    stm32_extract_device_info_line(LINE_INFO)
    if (NOT LINE_INFO)
        return()
    endif ()

    list(GET LINE_INFO ${HEADER_INDEX} HEADER_INFO)
    set(${output_variable} "${HEADER_INFO}" PARENT_SCOPE)
endfunction()

# Return the size of the flash of the microcontroller in the output variable.
function(stm32_get_flash_size output_variable)
    if("${STM32_MCU_FLASH_CODE}" STREQUAL "3")
        set(${output_variable} "8K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "4")
        set(${output_variable} "16K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "6")
        set(${output_variable} "32K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "8")
        set(${output_variable} "64K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "B")
        set(${output_variable} "128K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "C")
        set(${output_variable} "256K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "D")
        set(${output_variable} "384K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "E")
        set(${output_variable} "512K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "F")
        set(${output_variable} "768K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "G")
        set(${output_variable} "1024K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "H")
        set(${output_variable} "1536K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "I")
        set(${output_variable} "2048K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "Y")
        set(${output_variable} "640K" PARENT_SCOPE)
    elseif("${STM32_MCU_FLASH_CODE}" STREQUAL "Z")
        set(${output_variable} "192K" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Unable to determine the size of the flash for ${STM32_MCU}.")
    endif()
endfunction()
