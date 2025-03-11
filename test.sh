#!/bin/bash

# System Utilization Report using SAR for the Last 7 Days on RHEL 8
# Fetches Average CPU (User+System) and Memory Utilization per Day

echo "============================================================="
echo "📊 Daily System Utilization Report (Last 7 Days)"
echo "============================================================="

# Function to calculate the average utilization
calculate_average() {
    local data=("$@")
    local total=0
    local count=${#data[@]}

    if [[ $count -eq 0 ]]; then
        echo "No data available."
        return
    fi

    for value in "${data[@]}"; do
        total=$(echo "$total + $value" | bc)
    done

    avg=$(echo "scale=2; $total / $count" | bc)
    echo "📊 Average Utilization: $avg%"
}

# Loop through the last 7 days
for i in {1..7}; do
    DATE=$(date --date="$i days ago" +%d)
    SAR_FILE="/var/log/sa/sa$DATE"

    if [[ -f "$SAR_FILE" ]]; then
        echo -e "\n📅 **Date: $(date --date="$i days ago" +'%Y-%m-%d')**"
        echo "-------------------------------------------------------------"

        # Collect CPU Utilization (User + System)
        echo -e "\n🔹 **CPU Utilization (User + System) (%)**"
        cpu_usage=($(sar -u -f "$SAR_FILE" | awk '/^[0-9]/ {print $3 + $4}'))
        calculate_average "${cpu_usage[@]}"

        # Collect Memory Utilization
        echo -e "\n🔹 **Memory Utilization (%)**"
        memory_usage=($(sar -r -f "$SAR_FILE" | awk '/^[0-9]/ && $2 > 0 {print ($3 / $2) * 100}'))
        calculate_average "${memory_usage[@]}"

        echo "-------------------------------------------------------------"
    else
        echo -e "\n📅 **Date: $(date --date="$i days ago" +'%Y-%m-%d')** - ❌ No SAR data available."
    fi
done

echo -e "\n✅ **Daily Report Generated Successfully!**"
echo "============================================================="
