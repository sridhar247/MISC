#!/bin/bash

# Daily System Utilization Report using SAR for the Last 7 Days on RHEL 8
# Fetches Daily Average, Highest, and Lowest CPU (User+System) and Memory Utilization

echo "Gathering daily system utilization data for the past 7 days..."
echo "--------------------------------------------------------------"

# Function to calculate min, max, and average per day
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

# Get the last 7 days
for day in {1..7}; do
    date=$(date --date="$day days ago" +%Y-%m-%d)
    sar_file="/var/log/sa/sa$(date --date="$day days ago" +%d)"

    if [ -f "$sar_file" ]; then
        echo -e "\n📅 **Date: $date**"

        # Collect CPU (User + System) Utilization
        echo -e "\n🔹 **CPU Utilization (User + System) (%)**"
        cpu_usage=($(sar -u -f "$sar_file" | awk '/^[0-9]/ {print $3 + $5}'))
        calculate_stats "${cpu_usage[@]}"

        # Collect Memory Utilization
        echo -e "\n🔹 **Memory Utilization (%)**"
        memory_usage=($(sar -r -f "$sar_file" | awk '/^[0-9]/ {print ($3+$4)/($2+$3+$4) * 100}'))
        calculate_stats "${memory_usage[@]}"

    else
        echo -e "\n📅 **Date: $date** - No SAR data available."
    fi
done

echo -e "\n✅ Daily Report Generated Successfully!"
