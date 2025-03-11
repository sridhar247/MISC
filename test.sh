#!/bin/bash

echo -e "Date\t\tAvg Mem%\tMax Mem%\tMin Mem%"

for i in {1..7}; do
    DATE=$(date -d "$i days ago" +"%Y-%m-%d")
    SARFILE="/var/log/sa/sa$(date -d "$i days ago" +%d)"

    if [ -f "$SARFILE" ]; then
        MEM_USAGE=$(sar -r -f "$SARFILE" | awk '/^[0-9]/ && $2>0 {printf "%.2f\n", ($3/$2)*100}')

        # Check if MEM_USAGE is not empty
        if [ -n "$MEM_USAGE" ]; then
            AVG_MEM=$(echo "$MEM_USAGE" | awk '{sum+=$1; count++} END {printf "%.2f", sum/count}')
            MAX_MEM=$(echo "$MEM_USAGE" | sort -nr | head -1)
            MIN_MEM=$(echo "$MEM_USAGE" | sort -n | head -1)

            echo -e "$DATE\t$AVG_MEM%\t\t$MAX_MEM%\t\t$MIN_MEM%"
        else
            echo -e "$DATE\tNo Data\t\tNo Data\t\tNo Data"
        fi
done
