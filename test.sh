#!/bin/bash

echo -e "Date\t\tAvg CPU%\tMax CPU%\tMin CPU%"

for i in {1..7}; do
    # Get the date for past i days
    DATE=$(date --date="$i days ago" +"%Y-%m-%d")
    SAR_FILE="/var/log/sa/sa$(date --date="$i days ago" +%d)"

    # Check if SAR log file exists
    if [[ -f "$SAR_FILE" ]]; then
        # Extract CPU Utilization (User + System)
        CPU_VALUES=$(sar -u -f "$SAR_FILE" | awk 'NR>3 {print $3 + $5}')
        CPU_AVG=$(echo "$CPU_VALUES" | awk '{sum+=$1; count+=1} END {if(count>0) print sum/count; else print "N/A"}')
        CPU_MAX=$(echo "$CPU_VALUES" | sort -nr | head -1)
        CPU_MIN=$(echo "$CPU_VALUES" | sort -n | head -1)

        # Print results in tabular format
        echo -e "$DATE\t$CPU_AVG%\t$CPU_MAX%\t$CPU_MIN%"
    else
        echo -e "$DATE\tNo Data Available"
    fi
done
