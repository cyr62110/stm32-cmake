# Check if a HAL configuration header is present into target INCLUDE_DIRECTORIES.
# Otherwise copy from template into output directory.
#
# Output variables:
# - STM32_HAL_CONFIG_FILE: The path to the HAL configuration header. Not set if not found.
#
function(stm32_find_existing_hal_config target)
    if (NOT HAL_FOUND)
        return()
    endif ()

    get_target_property(INCLUDE_DIRECTORIES ${target} INCLUDE_DIRECTORIES)
    foreach (DIR IN LISTS INCLUDE_DIRECTORIES)
        if (EXISTS "${DIR}/${HAL_CONFIG_FILENAME}")
            set(EXISTING_HAL_CONFIG_FILE "${DIR}/${HAL_CONFIG_FILENAME}")
            break()
        endif ()
    endforeach ()

    set(STM32_HAL_CONFIG_FILE "${EXISTING_HAL_CONFIG_FILE}" PARENT_SCOPE)
endfunction()

function(stm32_copy_hal_from_template target)
    set(HAL_CONFIG_FILE "${STM32_GENERATED_OUTPUT_DIR}/${HAL_CONFIG_FILENAME}")
    set(TEMPLATE_INPUT_FILE "${HAL_ROOT_DIR}/Inc/${STM32_MCU_SERIES_L}_hal_conf_template.h")

    file(COPY_FILE ${TEMPLATE_INPUT_FILE} ${HAL_CONFIG_FILE})

    set(STM32_HAL_CONFIG_FILE "${HAL_CONFIG_FILE}" PARENT_SCOPE)
endfunction()

function(stm32_configure_hal_config target)
    # Check if the HAL configuration file already exists.
    stm32_find_existing_hal_config(${target})

    if (STM32_HAL_CONFIG_FILE)
        message(STATUS "Found existing HAL configuration ${STM32_HAL_CONFIG_FILE}")

        cmake_path(GET MYPROJECT_DIR PARENT_PATH PARENT_DIR)
    else ()
        stm32_copy_hal_from_template(${target})
        message(STATUS "Using template HAL configuration generated at ${STM32_HAL_CONFIG_FILE}")
    endif ()
endfunction()
