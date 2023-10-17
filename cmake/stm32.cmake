# Check the cross compilation toolchain is properly configured.
# And configure some options to avoid common issues with cross-compilation toolchain.
# MUST BE CALLED BEFORE THE project() in your CMakeLists.
function(stm32_configure_and_check_toolchain)
    file(REAL_PATH ${CMAKE_MODULE_PATH}/stm32/toolchain/gcc.cmake EXPECTED_TOOLCHAIN_FILE)

    if ("${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
        message(FATAL_ERROR "Set CMAKE_TOOLCHAIN_FILE environment variable to: ${EXPECTED_TOOLCHAIN_FILE}")
    endif()

    file(REAL_PATH ${CMAKE_TOOLCHAIN_FILE} TOOLCHAIN_FILE)
    if(NOT ${TOOLCHAIN_FILE} STREQUAL ${EXPECTED_TOOLCHAIN_FILE})
        message(FATAL_ERROR "Change CMAKE_TOOLCHAIN_FILE environment variable to: ${EXPECTED_TOOLCHAIN_FILE}")
    endif()

    # Change the type executable cmake uses to test if the toolchain is working.
    # Mandatory because the cross-toolchain is missing some functions like printf.
    # https://stackoverflow.com/questions/53633705/cmake-the-c-compiler-is-not-able-to-compile-a-simple-test-program
    set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY" PARENT_SCOPE)
endfunction()

# Append the sources from the CMSIS and the HAL libraries to the provided sources lists.
# Then output the appended list to the output_variable.
function(stm32_configure_sources sources output_variable)
    set(APPENDED_SOURCES "${sources}")
    if(${CMSIS_FOUND} EQUAL 1)
        list(APPEND APPENDED_SOURCES ${CMSIS_SOURCES})
        list(APPEND APPENDED_SOURCES ${STM32_STARTUP_SOURCE})
    endif()

    if(${HAL_FOUND} EQUAL 1)
        list(APPEND APPENDED_SOURCES ${HAL_SOURCES})
    endif()
    set(${output_variable} ${APPENDED_SOURCES} PARENT_SCOPE)
endfunction()

# Configure the compile & linker options.
function(stm32_configure_target target)
    # Add C define with the series of the target.
    target_compile_definitions(${target} PUBLIC "${STM32_MCU_SERIES}")

    target_compile_options(${target}
        PUBLIC -Wall
        PUBLIC -fdata-sections
        PUBLIC -ffunction-sections)

    # Link with standard libraries: C, math.h
    target_link_options(${target}
        PUBLIC -lc
        PUBLIC -lm)

    # Add linker flags indicating we are running on baremetal
    target_link_options(${target}
        PUBLIC -lnosys
        PUBLIC --specs=nosys.specs)

    # Configure the compile & linked options for the MCU declared in find_package(STM32Cube COMPONENTS <MCU>)
    target_compile_options(${target} PUBLIC ${STM32_COMPILE_OPTIONS})
    target_link_options(${target} PUBLIC ${STM32_LINK_OPTIONS})

    #add_link_options(${targer} "-T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections")

    # Configure the CMSIS if find_package(CMSIS) has been called and the CMSIS has been found.
    if(${CMSIS_FOUND} EQUAL 1)
        # Add compile options for the assembler startup script.
        # FIXME set_source_files_properties(${STM32_STARTUP_SOURCE} PROPERTIES COMPILE_OPTIONS "-x assembler-with-cpp")

        # Include headers from the CMSIS
        target_include_directories(${target} PUBLIC ${CMSIS_INCLUDE_DIRS})
    endif()

    # Configure the HAL if find_package(HAL) has been called and the HAL has been found.
    if(${HAL_FOUND} EQUAL 1)
        target_compile_definitions(${target} PUBLIC "USE_HAL_DRIVER")
        target_include_directories(${target} PUBLIC ${HAL_INCLUDE_DIRS})
    endif()
endfunction()
