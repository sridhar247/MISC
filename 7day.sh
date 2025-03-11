#!/bin/bash
# Script to calculate max, min, and average CPU utilization and percentage memory used for the past 7 days

SA_DIR="/var/log/sa"

echo "Date        CPU Max(%)  CPU Min(%)  CPU Avg(%)  Mem Used(%)"
echo "----------------------------------------------------------"

# Loop over the past 7 days
for i in {1..7}; do
    DAY=$(date --date="$i day ago" +%d)   # Get day in two-digit format
    DATE_LABEL=$(date --date="$i day ago" +%Y-%m-%d)  # Get readable date
    SA_FILE="$SA_DIR/sa$DAY"

    if [ -f "$SA_FILE" ]; then
        # Extract CPU utilization (100 - %idle)
        CPU_DATA=$(sar -u -f "$SA_FILE" | awk 'NR>3 {print 100 - $NF}')

        # Extract percentage memory used directly from sar -r (last column is %memused)
        MEM_USED=$(sar -r -f "$SA_FILE" | awk 'NR>3 {print $(NF)}' | tail -1)

        # Validate that CPU and Memory data are not empty and that MEM_USED is a valid number
        if [ -n "$CPU_DATA" ] && [[ "$MEM_USED" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            # Compute CPU statistics
            CPU_MAX=$(echo "$CPU_DATA" | sort -nr | head -1)
            CPU_MIN=$(echo "$CPU_DATA" | sort -n | head -1)
            CPU_AVG=$(echo "$CPU_DATA" | awk '{sum+=$1} END {if (NR>0) print sum/NR}')

            # Ensure proper formatting for memory usage with percentage symbol
            MEM_USED=$(printf "%.2f" "$MEM_USED")

            # Display results using proper formatting
            printf "%s  %.2f%%       %.2f%%       %.2f%%       %.2f%%\n" \
                "$DATE_LABEL" "$CPU_MAX" "$CPU_MIN" "$CPU_AVG" "$MEM_USED"
        else
            echo "$DATE_LABEL  No data available"
        fi
    else
        echo "$DATE_LABEL  SAR file not found"
    fi
done
