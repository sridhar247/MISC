#!/bin/bash
# Script to calculate max, min, and average CPU utilization and average memory used over the past 7 days

SA_DIR="/var/log/sa"

echo "Date        CPU Max(%)  CPU Min(%)  CPU Avg(%)  Mem Used(%)"
echo "----------------------------------------------------------"

TOTAL_MEM_USED=0
MEM_DAYS_COUNT=0

# Loop over the past 7 days
for i in {1..7}; do
    DAY=$(date --date="$i day ago" +%d)   # Get day in two-digit format
    DATE_LABEL=$(date --date="$i day ago" +%Y-%m-%d)  # Get readable date
    SA_FILE="$SA_DIR/sa$DAY"

    if [ -f "$SA_FILE" ]; then
        # Extract CPU utilization (100 - %idle)
        CPU_DATA=$(sar -u -f "$SA_FILE" | awk 'NR>3 {print 100 - $NF}')

        # Extract average %memused for the day
        MEM_AVG_DAY=$(sar -r -f "$SA_FILE" | awk 'NR>3 {sum+=$NF; count+=1} END {if (count>0) print sum/count}')

        # Validate that CPU and Memory data are not empty
        if [ -n "$CPU_DATA" ] && [[ "$MEM_AVG_DAY" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            # Compute CPU statistics
            CPU_MAX=$(echo "$CPU_DATA" | sort -nr | head -1)
            CPU_MIN=$(echo "$CPU_DATA" | sort -n | head -1)
            CPU_AVG=$(echo "$CPU_DATA" | awk '{sum+=$1} END {if (NR>0) print sum/NR}')

            # Format memory used to two decimal places
            MEM_AVG_DAY=$(printf "%.2f" "$MEM_AVG_DAY")

            # Add to total memory used for computing the overall average
            TOTAL_MEM_USED=$(echo "$TOTAL_MEM_USED + $MEM_AVG_DAY" | bc)
            MEM_DAYS_COUNT=$((MEM_DAYS_COUNT + 1))

            # Display daily results
            printf "%s  %.2f%%       %.2f%%       %.2f%%       %.2f%%\n" \
                "$DATE_LABEL" "$CPU_MAX" "$CPU_MIN" "$CPU_AVG" "$MEM_AVG_DAY"
        else
            echo "$DATE_LABEL  No data available"
        fi
    else
        echo "$DATE_LABEL  SAR file not found"
    fi
done

# Compute overall average memory usage across all 7 days
if [ "$MEM_DAYS_COUNT" -gt 0 ]; then
    MEM_AVG_TOTAL=$(echo "$TOTAL_MEM_USED / $MEM_DAYS_COUNT" | bc -l)
    MEM_AVG_TOTAL=$(printf "%.2f" "$MEM_AVG_TOTAL")
    echo "----------------------------------------------------------"
    printf "Overall Avg Memory Used Over 7 Days: %.2f%%\n" "$MEM_AVG_TOTAL"
fi
