#!/bin/bash

# Function to calculate stats
calculate_stats() {
    data=("$@")
    total=0
    highest=${data[0]}
    lowest=${data[0]}

    for val in "${data[@]}"; do
        total=$(echo "$total + $val" | bc)
        if (( $(echo "$val > $highest" | bc -l) )); then
            highest=$val
        fi
        if (( $(echo "$val < $lowest" | bc -l) )); then
            lowest=$val
        fi
    done

    avg=$(echo "scale=2; $total / ${#data[@]}" | bc)
    echo "Average: $avg%"
    echo "Highest: $highest%"
    echo "Lowest: $lowest%"
}

# Get past 7 days utilization
echo "CPU Utilization (User + System):"
cpu_data=()
mem_data=()
disk_data=()

for i in {1..7}; do
    sar_file="/var/log/sa/sa$(date --date="$i days ago" +%d)"
    
    if [[ -f "$sar_file" ]]; then
        # Extract CPU Usage (User + System)
        cpu_values=$(sar -u -f "$sar_file" | awk 'NR>3 {print 100 - $8}' | grep -v "all")
        mem_values=$(sar -r -f "$sar_file" | awk 'NR>3 {print 100 * ($4 / ($2 + $4))}')
        disk_values=$(sar -d -f "$sar_file" | awk 'NR>3 {print $10}' | grep -v "DEV")

        cpu_data+=($cpu_values)
        mem_data+=($mem_values)
        disk_data+=($disk_values)
    fi
done

# Display CPU stats
calculate_stats "${cpu_data[@]}"

echo -e "\nMemory Utilization:"
calculate_stats "${mem_data[@]}"

echo -e "\nDisk Utilization:"
calculate_stats "${disk_data[@]}"
