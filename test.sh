#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# List all physical internal and external disks with detailed information
echo "Available disks:"
diskutil list

# Prompt user to enter the device identifier
read -p "Enter the device identifier (e.g., disk2), be careful with the disk you want to test: " DEVICE
DEVICE="/dev/$DEVICE"

# Check the device exists
if ! diskutil info $DEVICE &> /dev/null; then
    echo "Error: Device $DEVICE does not exist."
    exit 1
fi

# Warn the user about data corruption
echo "WARNING: This operation will overwrite data on $DEVICE and cause data loss."
read -p "Are you sure you want to continue? (Y/n): " CONFIRM

if [ "$CONFIRM" != "Y" ]; then
    echo "Operation aborted."
    exit 1
fi

# Unmount the device
diskutil unmountDisk $DEVICE

# Test write speed
echo "Testing write speed..."
write_output=$(dd if=/dev/zero of=$DEVICE bs=1m count=1024 2>&1)
echo "$write_output"

# Test read speed
echo "Testing read speed..."
read_output=$(dd if=$DEVICE of=/dev/null bs=1m count=1024 2>&1)
echo "$read_output"

# Re-mount the device
diskutil mountDisk $DEVICE

echo "Speed test completed."
