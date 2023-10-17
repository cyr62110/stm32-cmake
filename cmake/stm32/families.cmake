set(STM32_SUPPORTED_SHORT_FAMILIES
        F7)
set(STM32_SUPPORTED_FAMILIES
        STM32F7xx)

function(extract_stm32_short_family mcu output_variable)
    if(NOT ${mcu} MATCHES "STM32.*")
        message(FATAL_ERROR "MCU ${mcu} is not supported by this tool.")
    endif()

    string(SUBSTRING ${mcu} 5 2 short_mcu)
    if(NOT ${short_mcu} IN_LIST STM32_SUPPORTED_SHORT_FAMILIES)
        message(FATAL_ERROR "MCU family ${short_family} is not supported by this tool.")
    endif()
    set(${output_variable} ${short_mcu} PARENT_SCOPE)
endfunction()

function(compute_stm32_family short_family output_variable)
    list(FIND STM32_SUPPORTED_SHORT_FAMILIES ${short_family} index)
    if(${index} EQUAL -1)
        message(FATAL_ERROR "MCU family ${short_family} is not supported by this tool.")
    endif()

    list(GET STM32_SUPPORTED_FAMILIES ${index} family)
    set(${output_variable} ${family} PARENT_SCOPE)
endfunction()
