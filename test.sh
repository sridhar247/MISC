#!/bin/bash
# This script displays the average CPU utilization for each of the past 7 days.
# It uses the SAR log files stored in /var/log/sa/saDD (where DD is the day of month)
# and computes CPU utilization as (100 - average %idle) from the sar -u report.
#
# Note: Adjust the script if your SAR files or output format differs.

SA_DIR="/var/log/sa"

echo "Date        CPU Utilization (%)"
echo "-------------------------------"

# Loop over the past 7 days (excluding today)
for i in {1..7}; do
    # Get day (in 2-digit format) for the file name and date label
    DAY=$(date --date="$i day ago" +%d)
    DATE_LABEL=$(date --date="$i day ago" +%Y-%m-%d)
    SA_FILE="$SA_DIR/sa$DAY"
    
    if [ -f "$SA_FILE" ]; then
        # Use sar to display CPU stats from the log file.
        # The "Average:" line contains the summary for the day.
        # We assume the last field is %idle.
        AVG_IDLE=$(sar -u -f "$SA_FILE" | awk '/^Average:/ {print $(NF)}')
        
        if [ -z "$AVG_IDLE" ]; then
            echo "$DATE_LABEL  No data available"
        else
            # Calculate CPU utilization as (100 - %idle)
            UTIL=$(echo "scale=2; 100 - $AVG_IDLE" | bc)
            printf "%s  %.2f\n" "$DATE_LABEL" "$UTIL"
        fi
    else
        echo "$DATE_LABEL  SAR file not found"
    fi
done
