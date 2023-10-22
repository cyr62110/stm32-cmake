include(stm32/hal)
include(stm32/linker)
include(stm32/utils)

# Check the cross compilation toolchain is properly configured.
# And configure some options to avoid common issues with cross-compilation toolchain.
# MUST BE CALLED BEFORE THE project() in your CMakeLists.
function(stm32_configure_and_check_toolchain)
    # Change the type executable cmake uses to test if the toolchain is working.
    # Mandatory because the cross-toolchain is missing some functions like printf.
    # https://stackoverflow.com/questions/53633705/cmake-the-c-compiler-is-not-able-to-compile-a-simple-test-program
    set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY" PARENT_SCOPE)
endfunction()

# Append the sources from the CMSIS and the HAL libraries to the provided sources lists.
# Then output the appended list to the output_variable.
function(stm32_configure_sources sources output_variable)
    set(APPENDED_SOURCES "${sources}")
    if (${CMSIS_FOUND} EQUAL 1)
        list(APPEND APPENDED_SOURCES ${CMSIS_SOURCES})
        list(APPEND APPENDED_SOURCES ${STM32_STARTUP_SOURCE})
    endif ()

    if (${HAL_FOUND} EQUAL 1)
        list(APPEND APPENDED_SOURCES ${HAL_SOURCES})
    endif ()
    set(${output_variable} ${APPENDED_SOURCES} PARENT_SCOPE)
endfunction()

function(stm32_generate_additional_binary target target_bfdname)
    if (${target_bfdname} STREQUAL "ihex")
        set(OUTPUT_EXTENSION "hex")
    elseif (${target_bfdname} STREQUAL "binary")
        set(OUTPUT_EXTENSION "bin")
    elseif (${target_bfdname} STREQUAL "srec")
        set(OUTPUT_EXTENSION "srec")
    else ()
        message(FATAL_ERROR "Unsupported target bfdname: ${target_bfdname}. Supported values are: ihex, binary and srec.")
    endif ()

    get_executable_output_file(${target} TARGET_INPUT_FILE)
    string(REGEX REPLACE "(.*)(\\..*)$" "\\1.${OUTPUT_EXTENSION}" TARGET_OUTPUT_FILE ${TARGET_INPUT_FILE})
    cmake_path(GET TARGET_OUTPUT_FILE FILENAME TARGET_OUTPUT_FILENAME)

    add_custom_command(
            TARGET ${target}
            POST_BUILD
            COMMAND ${CMAKE_OBJCOPY} ${TARGET_INPUT_FILE} -O ${target_bfdname} ${TARGET_OUTPUT_FILE}
            BYPRODUCTS ${TARGET_OUTPUT_FILE}
            COMMENT "Generating ${target_bfdname} output ${TARGET_OUTPUT_FILENAME}.${OUTPUT_EXTENSION}"
    )
endfunction()

# Add compile & linker options to compile a target for the architecture.
# The scope is INTERFACE, PUBLIC and PRIVATE.
function(stm32_configure_target scope target)
    # Add C define with the line of the target.
    target_compile_definitions(${target} ${scope} "${STM32_MCU_LINE_U}")

    target_compile_options(${target}
            ${scope} -Wall
            ${scope} -fdata-sections
            ${scope} -ffunction-sections)

    # Add linker flags indicating we are running on baremetal
    target_link_options(${target}
            ${scope} -lnosys
            ${scope} --specs=nosys.specs)

    # Link with standard libraries: C, math.h
    target_link_options(${target}
            ${scope} -lc
            ${scope} -lm)

    # Configure the compile & linked options for the MCU declared in find_package(STM32Cube COMPONENTS <MCU>)
    target_compile_options(${target} ${scope} ${STM32_COMPILE_OPTIONS})
    target_link_options(${target} ${scope} ${STM32_LINK_OPTIONS})
endfunction()

# Configure the executable target by doing the following operation depending on whether the CMSIS and/or HAL are linked:
# - Add the compile & linker options to target the architecture.
# - [CMSIS & HAL] Add include directories for the library if it is included.
# - [HAL] Check if the configuration header is present or use one from t
function(stm32_configure_executable target)
    stm32_configure_target(PUBLIC ${target})
    stm32_configure_hal_config(${target})
    stm32_configure_linker_script(${target})

    # Add headers that may have been generated from templates (ex. HAL config).
    target_include_directories(${target} PUBLIC ${STM32_GENERATED_OUTPUT_DIR})

    # Add postcompile commands to generate .hex & .bin files used for programming.
    stm32_generate_additional_binary(${target} ihex)
    stm32_generate_additional_binary(${target} binary)
    stm32_generate_additional_binary(${target} srec)

    # Configure the CMSIS if find_package(CMSIS) has been called and the CMSIS has been found.
    if (${CMSIS_FOUND} EQUAL 1)
        target_link_libraries(${PROJECT_NAME} ${CMSIS_TARGET})
    endif ()

    # Configure the HAL if find_package(HAL) has been called and the HAL has been found.
    if (${HAL_FOUND} EQUAL 1)
        target_compile_definitions(${target} PUBLIC "USE_HAL_DRIVER")
        target_link_libraries(${PROJECT_NAME} ${HAL_TARGET})
    endif ()
endfunction()
