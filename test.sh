#!/bin/bash
# Script to calculate max, min, and average CPU utilization (excluding %idle) for the past 7 days

SA_DIR="/var/log/sa"

echo "Date        Max(%)  Min(%)  Avg(%)"
echo "-----------------------------------"

# Loop over the past 7 days
for i in {1..7}; do
    DAY=$(date --date="$i day ago" +%d)   # Get day in two-digit format
    DATE_LABEL=$(date --date="$i day ago" +%Y-%m-%d)  # Get readable date
    SA_FILE="$SA_DIR/sa$DAY"

    if [ -f "$SA_FILE" ]; then
        # Extract CPU utilization (100 - %idle) from sar log
        CPU_DATA=$(sar -u -f "$SA_FILE" | awk 'NR>3 {print 100 - $NF}')

        if [ -n "$CPU_DATA" ]; then
            # Compute min, max, and average utilization
            MAX_UTIL=$(echo "$CPU_DATA" | sort -nr | head -1)
            MIN_UTIL=$(echo "$CPU_DATA" | sort -n | head -1)
            AVG_UTIL=$(echo "$CPU_DATA" | awk '{sum+=$1} END {if (NR>0) print sum/NR}')

            printf "%s  %.2f    %.2f    %.2f\n" "$DATE_LABEL" "$MAX_UTIL" "$MIN_UTIL" "$AVG_UTIL"
        else
            echo "$DATE_LABEL  No data available"
        fi
    else
        echo "$DATE_LABEL  SAR file not found"
    fi
done
