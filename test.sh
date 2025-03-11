#!/bin/bash

# Daily System Utilization Report using SAR for the Last 7 Days on RHEL 8
# Fetches Average, Highest, and Lowest CPU (User+System), Memory, and Disk Usage

echo "Gathering daily system utilization data for the past 7 days..."
echo "-------------------------------------------------------------"

# Function to calculate min, max, and average
calculate_stats() {
    local data=("$@")
    local total=0
    local count=${#data[@]}

    # Initialize min and max with the first element
    local min=${data[0]}
    local max=${data[0]}

    for value in "${data[@]}"; do
        total=$(echo "$total + $value" | bc)
        (( $(echo "$value < $min" | bc -l) )) && min=$value
        (( $(echo "$value > $max" | bc -l) )) && max=$value
    done

    avg=$(echo "scale=2; $total / $count" | bc)
    echo "Average: $avg%, Highest: $max%, Lowest: $min%"
}

# Loop through the last 7 days
for i in {1..7}; do
    DATE=$(date --date="$i days ago" +%d)
    SAR_FILE="/var/log/sa/sa$DATE"

    if [[ -f "$SAR_FILE" ]]; then
        echo -e "\n📅 **Date: $(date --date="$i days ago" +'%Y-%m-%d')**"
        
        # Collect CPU Utilization (User + System)
        echo -e "\n🔹 **CPU Utilization (User + System) (%)**"
        cpu_usage=($(sar -u -f "$SAR_FILE" | awk '/[0-9]/ {print $3 + $5}'))
        calculate_stats "${cpu_usage[@]}"

        # Collect Memory Utilization
        echo -e "\n🔹 **Memory Utilization (%)**"
        memory_usage=($(sar -r -f "$SAR_FILE" | awk '/[0-9]/ {print ($3+$4)/($2+$3+$4) * 100}'))
        calculate_stats "${memory_usage[@]}"

        # Collect Disk Utilization (I/O Wait)
        echo -e "\n🔹 **Disk I/O Wait (%)**"
        disk_io=($(sar -d -f "$SAR_FILE" | awk '/[0-9]/ {print $9}'))
        calculate_stats "${disk_io[@]}"

        echo "-------------------------------------------------------------"
    else
        echo -e "\n📅 **Date: $(date --date="$i days ago" +'%Y-%m-%d')** - No SAR data available."
    fi
done

echo -e "\n✅ Daily Report Generated Successfully!"
