#!/bin/bash
# Script to extract and sort percentage memory used (%memused) for the past 7 days

SA_DIR="/var/log/sa"

echo "Date        Memory Used (%)"
echo "---------------------------"

TEMP_FILE=$(mktemp)

# Loop over the past 7 days
for i in {1..7}; do
    DAY=$(date --date="$i day ago" +%d)   # Get day in two-digit format
    DATE_LABEL=$(date --date="$i day ago" +%Y-%m-%d)  # Get readable date
    SA_FILE="$SA_DIR/sa$DAY"

    if [ -f "$SA_FILE" ]; then
        # Extract and compute average %memused for the day
        MEM_AVG_DAY=$(sar -r -f "$SA_FILE" | awk 'NR>3 {sum+=$NF; count+=1} END {if (count>0) print sum/count}')

        # Validate memory data and store in temp file for sorting
        if [[ "$MEM_AVG_DAY" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            MEM_AVG_DAY=$(printf "%.2f" "$MEM_AVG_DAY")
            echo "$MEM_AVG_DAY $DATE_LABEL" >> "$TEMP_FILE"
        else
            echo "No data available for $DATE_LABEL"
        fi
    else
        echo "SAR file not found for $DATE_LABEL"
    fi
done

# Sort memory usage from highest to lowest and display it
sort -nr "$TEMP_FILE" | awk '{printf "%s  %s%%\n", $2, $1}'

# Cleanup temporary file
rm -f "$TEMP_FILE"
