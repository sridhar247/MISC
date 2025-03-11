#!/bin/bash

# Function to calculate stats
calculate_stats() {
    data=("$@")
    total=0
    count=${#data[@]}
    
    if [[ $count -eq 0 ]]; then
        echo "No data available"
        return
    fi

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

    avg=$(echo "scale=2; $total / $count" | bc)
    echo "Average: $avg%"
    echo "Highest: $highest%"
    echo "Lowest: $lowest%"
}

# Loop for the past 7 days
for i in {1..7}; do
    DATE=$(date --date="$i days ago" +%Y-%m-%d)
    SAR_FILE="/var/log/sa/sa$(date --date="$i days ago" +%d)"

    echo -e "\n===== $DATE ====="

    if [[ -f "$SAR_FILE" ]]; then
        # Extract CPU Utilization (User + System)
        cpu_values=($(sar -u -f "$SAR_FILE" | awk 'NR>3 {print 100 - $8}'))
        
        echo "CPU Utilization:"
        calculate_stats "${cpu_values[@]}"

        # Extract Memory Utilization (used RAM percentage)
        mem_values=($(sar -r -f "$SAR_FILE" | awk 'NR>3 {print 100 * ($4 / ($2 + $4))}'))

        echo -e "\nMemory Utilization:"
        calculate_stats "${mem_values[@]}"
    else
        echo "No SAR data available for this day."
    fi
done
