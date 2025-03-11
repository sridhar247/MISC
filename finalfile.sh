#!/bin/bash

# Function to calculate average, highest, and lowest utilization
calculate_stats() {
    local values=("$@")
    local total=0
    local highest=${values[0]}
    local lowest=${values[0]}

    for val in "${values[@]}"; do
        total=$(echo "$total + $val" | bc)
        (( $(echo "$val > $highest" | bc -l) )) && highest=$val
        (( $(echo "$val < $lowest" | bc -l) )) && lowest=$val
    done

    local avg=$(echo "scale=2; $total / ${#values[@]}" | bc)
    echo "Average: $avg%"
    echo "Highest: $highest%"
    echo "Lowest: $lowest%"
}

# Initialize arrays for CPU and memory utilization
cpu_utilization=()
memory_utilization=()

# Loop through the past 7 days
for i in {1..7}; do
    sar_file="/var/log/sa/sa$(date --date="$i days ago" +%d)"

    if [[ -f "$sar_file" ]]; then
        # CPU Utilization: (100 - %idle)
        cpu_values=$(sar -u -f "$sar_file" | awk 'NR>3 {print 100 - $NF}' | grep -Eo '[0-9.]+')
        
        # Memory Utilization: Used RAM % = 100 * (used_mem / total_mem)
        mem_values=$(sar -r -f "$sar_file" | awk 'NR>3 {print 100 * ($4 / ($2 + $4))}' | grep -Eo '[0-9.]+')

        # Append values to arrays
        cpu_utilization+=($cpu_values)
        memory_utilization+=($mem_values)
    fi
done

# Display CPU statistics
echo "CPU Utilization (User + System) Over Past 7 Days:"
calculate_stats "${cpu_utilization[@]}"

# Display Memory statistics
echo -e "\nMemory Utilization Over Past 7 Days:"
calculate_stats "${memory_utilization[@]}"
