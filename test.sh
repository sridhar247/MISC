#!/bin/bash

echo -e "Date\t\tAvg CPU%\tMax CPU%\tMin CPU%\tAvg Mem%\tMax Mem%\tMin Mem%"

for i in {1..7}; do
    # Get the date for past i days
    DATE=$(date --date="$i days ago" +"%Y-%m-%d")
    SAR_FILE="/var/log/sa/sa$(date --date="$i days ago" +%d)"

    # Check if SAR log file exists
    if [[ -f "$SAR_FILE" ]]; then
        # Extract CPU Utilization (User + System)
        CPU_VALUES=$(sar -u -f "$SAR_FILE" | awk 'NR>3 {print 100 - $8}')
        CPU_AVG=$(echo "$CPU_VALUES" | awk '{sum+=$1; count+=1} END {if(count>0) print sum/count; else print "N/A"}')
        CPU_MAX=$(echo "$CPU_VALUES" | sort -nr | head -1)
        CPU_MIN=$(echo "$CPU_VALUES" | sort -n | head -1)

        # Extract Memory Utilization
        MEM_VALUES=$(sar -r -f "$SAR_FILE" | awk 'NR>3 {print 100 * ($4 / ($2 + $4))}')
        MEM_AVG=$(echo "$MEM_VALUES" | awk '{sum+=$1; count+=1} END {if(count>0) print sum/count; else print "N/A"}')
        MEM_MAX=$(echo "$MEM_VALUES" | sort -nr | head -1)
        MEM_MIN=$(echo "$MEM_VALUES" | sort -n | head -1)

        # Print results in tabular format
        echo -e "$DATE\t$CPU_AVG%\t$CPU_MAX%\t$CPU_MIN%\t$MEM_AVG%\t$MEM_MAX%\t$MEM_MIN%"
    else
        echo -e "$DATE\tNo Data Available"
    fi
done
