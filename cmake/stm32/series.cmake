function(list_stm32_mcu_series mcu_family output_variable)
    if(NOT DEFINED stm32cube_SOURCE_DIR)
        message(FATAL_ERROR "Make sure to call find_package(STM32Cube COMPONENTS <MCU>) before calling this function.")
    endif()

    set(SERIES_LIST "")

    # Determine the series depending on the startup script available in STM32Cube.
    set(STARTUP_FILE_DIR "${stm32cube_SOURCE_DIR}/Drivers/CMSIS/Device/ST/${mcu_family}/Source/Templates/gcc")
    file(GLOB STARTUP_FILES
            RELATIVE ${STARTUP_FILE_DIR}
            "${STARTUP_FILE_DIR}/*.s")
    foreach(STARTUP_FILE IN LISTS STARTUP_FILES)
        # Extract the series from the startup file name.
        string(REGEX MATCH "^startup_(.*)\.s$" _ ${STARTUP_FILE})
        string(TOUPPER ${CMAKE_MATCH_1} SERIES_U)
        string(REPLACE "X" "x" SERIES ${SERIES_U})

        list(APPEND SERIES_LIST ${SERIES})
    endforeach()

    set(${output_variable} ${SERIES_LIST} PARENT_SCOPE)
endfunction()

function(compute_stm32_mcu_series mcu mcu_family output_variable)
    list_stm32_mcu_series(${mcu_family} SERIES_LIST)

    foreach(SERIES IN LISTS SERIES_LIST)
        # Replace x by . to create the regex matching the series. To support: H7B3xxQ.
        string(REPLACE "x" "." SERIES_REGEX ${SERIES})
        if(${mcu} MATCHES "${SERIES_REGEX}")
            set(MATCHED_SERIES ${SERIES})
            break()
        endif()
    endforeach()

    if(NOT ${MATCHED_SERIES} STREQUAL "")
        set(${output_variable} ${MATCHED_SERIES} PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Unable to determine MCU series for ${mcu}. Available series: ${SERIES_LIST}")
    endif()
endfunction()
