#!/bin/bash
# Script to calculate max, min, and average CPU utilization (excluding %idle) on RHEL 8

# Check if sar command is available
if ! command -v sar &> /dev/null; then
    echo "Error: sysstat package is not installed. Install it using: sudo yum install sysstat"
    exit 1
fi

# Get CPU utilization from sar (excluding %idle)
CPU_DATA=$(sar -u 1 5 | awk 'NR>3 {print 100 - $NF}')

# Check if data is available
if [ -z "$CPU_DATA" ]; then
    echo "Error: No CPU utilization data available."
    exit 1
fi

# Calculate min, max, and average utilization
MAX_UTIL=$(echo "$CPU_DATA" | sort -nr | head -1)
MIN_UTIL=$(echo "$CPU_DATA" | sort -n | head -1)
AVG_UTIL=$(echo "$CPU_DATA" | awk '{sum+=$1} END {if (NR>0) print sum/NR}')

# Display the results
echo "CPU Utilization Statistics (excluding %idle):"
echo "--------------------------------------------"
echo "Maximum Utilization: $MAX_UTIL %"
echo "Minimum Utilization: $MIN_UTIL %"
echo "Average Utilization: $AVG_UTIL %"
