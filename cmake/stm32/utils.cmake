# Utility function to compute the path of the output for the provided target.
function(get_executable_output_file target output_variable)
    # Get the executable output dir.
    if (EXECUTABLE_OUTPUT_PATH)
        set(TARGET_OUTPUT_PATH "${EXECUTABLE_OUTPUT_PATH}/")
    elseif ()
        set(TARGET_OUTPUT_PATH "")
    endif ()

    # Get the executable output name.
    get_target_property(OUTPUT_NAME_PROPERTY ${target} PREFIX)
    if (OUTPUT_NAME_PROPERTY)
        set(TARGET_OUTPUT_NAME ${OUTPUT_NAME_PROPERTY})
    else ()
        set(TARGET_OUTPUT_NAME ${target})
    endif ()

    # Check if there is a PREFIX configured for the target
    get_target_property(PREFIX_PROPERTY ${target} PREFIX)
    if (PREFIX_PROPERTY)
        set(TARGET_PREFIX ${PREFIX_PROPERTY})
    elseif ()
        set(TARGET_PREFIX "")
    endif ()

    # Check if there is a SUFFIX configured for the target
    get_target_property(SUFFIX_PROPERTY ${target} SUFFIX)
    if (SUFFIX_PROPERTY)
        set(TARGET_SUFFIX ${SUFFIX_PROPERTY})
    elseif (CMAKE_EXECUTABLE_SUFFIX_C)
        set(TARGET_SUFFIX ${CMAKE_EXECUTABLE_SUFFIX_C})
    endif ()

    set(${output_variable} "${TARGET_OUTPUT_PATH}${TARGET_PREFIX}${TARGET_OUTPUT_NAME}${TARGET_SUFFIX}" PARENT_SCOPE)
endfunction()
