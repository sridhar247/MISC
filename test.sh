#!/bin/bash
# This script collects CPU (User+System) and Memory utilization samples using SAR on RHEL8
# and displays the average, minimum, and maximum values in a tabular format.

# Check that sysstat (which provides sar) is installed
if ! command -v sar &>/dev/null; then
    echo "sar command not found. Please install the sysstat package."
    exit 1
fi

# Number of samples and interval (seconds)
SAMPLES=10
INTERVAL=1

# Collect CPU utilization samples using sar -u
# We calculate CPU usage as (user + system).
# Skip header lines and any 'Average' line at the end.
cpu_samples=$(sar -u $INTERVAL $SAMPLES | awk 'NR>3 && $1 != "Average:" {print $3 + $5}')

# Collect Memory utilization samples using sar -r
# We assume the %memused is in the 4th column.
mem_samples=$(sar -r $INTERVAL $SAMPLES | awk 'NR>3 && $1 != "Average:" {print $4}')

# Function to calculate avg, min, and max from a list of numbers
calculate_stats() {
    local sum=0 count=0 min="" max=""
    for val in $1; do
        # Sum the values
        sum=$(echo "$sum + $val" | bc -l)
        count=$((count + 1))
        # Set the initial min and max values if not already set
        if [ -z "$min" ] || (( $(echo "$val < $min" | bc -l) )); then
            min=$val
        fi
        if [ -z "$max" ] || (( $(echo "$val > $max" | bc -l) )); then
            max=$val
        fi
    done

    if [ $count -gt 0 ]; then
        avg=$(echo "scale=2; $sum / $count" | bc -l)
    else
        avg="N/A"
        min="N/A"
        max="N/A"
    fi
    echo "$avg $min $max"
}

# Calculate statistics for CPU and Memory
read cpu_avg cpu_min cpu_max <<< $(calculate_stats "$cpu_samples")
read mem_avg mem_min mem_max <<< $(calculate_stats "$mem_samples")

# Print the results in tabular format
echo -e "Metric\t\t\tAvg\tMin\tMax"
echo -e "CPU (User+System)\t${cpu_avg}%\t${cpu_min}%\t${cpu_max}%"
echo -e "Memory Utilization\t${mem_avg}%\t${mem_min}%\t${mem_max}%"
