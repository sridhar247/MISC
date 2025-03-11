#!/bin/bash
# Script to calculate max, min, and average Memory utilization for the past 7 days

SA_DIR="/var/log/sa"

echo "Date        Mem Max(%)  Mem Min(%)  Mem Avg(%)"
echo "---------------------------------------------"

# Loop over the past 7 days
for i in {1..7}; do
    DAY=$(date --date="$i day ago" +%d)   # Get day in two-digit format
    DATE_LABEL=$(date --date="$i day ago" +%Y-%m-%d)  # Get readable date
    SA_FILE="$SA_DIR/sa$DAY"

    if [ -f "$SA_FILE" ]; then
        # Extract Memory utilization (Used Memory = (kbmemused / kbmemtotal) * 100)
        MEM_DATA=$(sar -r -f "$SA_FILE" | awk '$2 > 0 {print ($3 / $2) * 100}')

        # Validate Memory Data
        if [ -n "$MEM_DATA" ]; then
            # Compute Memory statistics
            MEM_MAX=$(echo "$MEM_DATA" | sort -nr | head -1)
            MEM_MIN=$(echo "$MEM_DATA" | sort -n | head -1)
            MEM_AVG=$(echo "$MEM_DATA" | awk '{sum+=$1; count+=1} END {if (count>0) print sum/count}')

            # Display results
            printf "%s  %.2f       %.2f       %.2f\n" \
                "$DATE_LABEL" "$MEM_MAX" "$MEM_MIN" "$MEM_AVG"
        else
            echo "$DATE_LABEL  No data available"
        fi
    else
        echo "$DATE_LABEL  SAR file not found"
    fi
done
