#!/bin/bash


function usage() {
    echo "Usage: $0 [-s] [device_name]"
    echo "  -s: Silent mode. Select the first device if only one is found."
    echo "  device_name: Name of the device to select."
    exit 1
}

# parse option
while getopts ":s" opt; do
  case $opt in
    s)
      SILENT=true
      shift $((OPTIND - 1))
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

function select_device() {
    # parameter $1: silent mode
    silent=$1

    # export variable
    export DEVICES=()
    export S_NAME=""

    while read -r line; do
        if [[ "$line" =~ ^([^\s]+)[[:space:]]+[a-z]+$ ]]; then
            DEVICES+=("${BASH_REMATCH[1]}")
            if ! [[ $silent ]]; then
                echo ${#DEVICES[@]}')' $line
            fi
        else 
            if ! [[ $silent ]]; then
                echo $line
            fi
        fi
    done < <(adb devices)

    #echo ${#DEVICES[@]} devices found.
    if [[ $SILENT ]]; then
        if [ ${#DEVICES[@]} -eq 1 ]; then
            S_NAME=${DEVICES[0]}
            return
        elif [ ${#DEVICES[@]} -eq 0 ]; then
            echo "No devices found. Please connect a device."
            exit 1
        elif [ ${#DEVICES[@]} -eq 1 ]; then
            S_NAME=${DEVICES[0]}
        else
            echo "Multiple devices found."
            exit 1
        fi
    fi
        
    echo "Select a device (number or name): "
    read input
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        if [ $input -ge 1 ] && [ $input -le ${#DEVICES[@]} ]; then
            S_NAME=${DEVICES[$((input-1))]}
        else
            echo "Invalid number. Please select a valid device number."
            exit 1
        fi
    else
        S_NAME=$input
    fi

}

function validate_device() {
    if [[ -z $(adb devices | grep -v "List of devices attached" | grep "device" | grep $S_NAME) ]]; then
        echo "Invalid device name. Please select a valid device."
        exit 1
    fi
}


if [ -z "$1" ]; then
    select_device $SILENT
else
    S_NAME=$1
fi

validate_device

echo $S_NAME > ~/.adb-selected-device

echo "Selected device: $(cat ~/.adb-selected-device)"