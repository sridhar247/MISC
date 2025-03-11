#!/bin/bash
# This script prints a snapshot of system+user CPU and memory utilization using sar on RHEL8

# Capture a one-time CPU utilization sample (sar -u 1 1)
# The output line should look similar to:
# 12:00:02 AM     all      3.00      0.00      1.50      0.10      0.00     95.40
cpu_line=$(sar -u 1 1 | tail -n 1)
if [[ -z "$cpu_line" ]]; then
    echo "No CPU data available."
    exit 1
fi

# Extract %user (column 3) and %system (column 5) values and calculate total CPU usage
cpu_user=$(echo "$cpu_line" | awk '{print $3}')
cpu_system=$(echo "$cpu_line" | awk '{print $5}')
cpu_total=$(echo "$cpu_user + $cpu_system" | bc -l)

# Capture a one-time Memory utilization sample (sar -r 1 1)
# The output line should look similar to:
# 12:00:02 AM    100000    200000      66.67      2000     50000     150000       50.00
mem_line=$(sar -r 1 1 | tail -n 1)
if [[ -z "$mem_line" ]]; then
    echo "No Memory data available."
    exit 1
fi

# Extract the %memused value.
# Considering the typical output, column 4 holds the %memused.
mem_usage=$(echo "$mem_line" | awk '{print $4}')

# Print the results in a clean format
echo "------------------------------------------"
echo "      System+User CPU and Memory Utilization"
echo "------------------------------------------"
printf "CPU Utilization (User + System): %.2f%%\n" "$cpu_total"
printf "Memory Utilization: %s%%\n" "$mem_usage"
