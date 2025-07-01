#!/bin/bash

if [[ -z $(adb devices | grep -v "List of devices attached" | grep "device" | grep $(cat ~/.adb-selected-device)) ]]; then
    echo "No device selected. Select device with silent mode automatically."
    adb-select.sh -s
fi

# echo adb -s $(cat ~/.adb-selected-device) $@
adb -s $(cat ~/.adb-selected-device) $@