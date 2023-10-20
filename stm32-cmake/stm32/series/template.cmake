# Each series must have a matching cmake file in this directory.
# The filename must match the two letters naming the series (ex. F7).
#
# The file must export some variables with value specific to the series.
#

# This list defines how the information is formatted in the STM32_SERIES_DEVICE_INFO.
set(STM32_SERIES_DEVICE_INFO_HEADERS LINE RAM)
set(STM32_SERIES_DEVICE_INFO
        # Ex. the STM32F767ZI has 512K RAM.
        77 512K
        # Ex. the STM32H757AI has RAM shared between its two cores.
        57_M7 128K
        57_M4 288K
)
