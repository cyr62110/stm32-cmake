cmake_minimum_required(VERSION 3.21)

set(PROJECT_NAME stm32cmake)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/stm32-cmake")
include(stm32_cmake)

stm32_configure_and_check_toolchain()
project(${PROJECT_NAME} C CXX ASM)

find_package(STM32Cube REQUIRED COMPONENTS STM32F767ZI)
find_package(CMSIS REQUIRED)
find_package(HAL REQUIRED)

set(SOURCE_FILES sources/main.cpp)
stm32_configure_sources(${SOURCE_FILES} SOURCE_FILES)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})
target_include_directories(${PROJECT_NAME} PUBLIC sources)
stm32_configure_executable(${PROJECT_NAME})
