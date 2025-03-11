#!/bin/bash
# Script to extract and display %memory used from SAR logs for the past 7 days

SA_DIR="/var/log/sa"

echo "Date        Avg Memory Used (%)"
echo "-------------------------------"

# Loop over the past 7 days
for i in {1..7}; do
    DAY=$(date --date="$i day ago" +%d)   # Get day in two-digit format
    DATE_LABEL=$(date --date="$i day ago" +%Y-%m-%d)  # Get readable date
    SA_FILE="$SA_DIR/sa$DAY"

    if [ -f "$SA_FILE" ]; then
        # Extract and compute %memused directly from SAR
        MEM_AVG_DAY=$(sar -r -f "$SA_FILE" | awk 'NR>3 {sum+=$NF; count+=1} END {if (count>0) print sum/count}')

        # Validate memory data and print result
        if [[ "$MEM_AVG_DAY" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            MEM_AVG_DAY=$(printf "%.2f" "$MEM_AVG_DAY")
            printf "%s  %s%%\n" "$DATE_LABEL" "$MEM_AVG_DAY"
        else
            echo "$DATE_LABEL  No data available"
        fi
    else
        echo "$DATE_LABEL  SAR file not found"
    fi
done
