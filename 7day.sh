#!/bin/bash
# Script to calculate max, min, and average CPU utilization and percentage memory used (%memused) for the past 7 days

SA_DIR="/var/log/sa"

echo "Date        CPU Max(%)  CPU Min(%)  CPU Avg(%)  Mem Max(%)  Mem Min(%)  Mem Avg(%)"
echo "--------------------------------------------------------------------------------"

# Loop over the past 7 days
for i in {1..7}; do
    DAY=$(date --date="$i day ago" +%d)   # Get day in two-digit format
    DATE_LABEL=$(date --date="$i day ago" +%Y-%m-%d)  # Get readable date
    SA_FILE="$SA_DIR/sa$DAY"

    if [ -f "$SA_FILE" ]; then
        # Extract CPU utilization (100 - %idle)
        CPU_DATA=$(sar -u -f "$SA_FILE" | awk 'NR>3 {print 100 - $NF}')

        # Extract %memused directly from SAR (last column)
        MEM_DATA=$(sar -r -f "$SA_FILE" | awk 'NR>3 {print $NF}')

        # Validate that CPU and Memory data are not empty
        if [ -n "$CPU_DATA" ] && [ -n "$MEM_DATA" ]; then
            # Compute CPU statistics
            CPU_MAX=$(echo "$CPU_DATA" | sort -nr | head -1)
            CPU_MIN=$(echo "$CPU_DATA" | sort -n | head -1)
            CPU_AVG=$(echo "$CPU_DATA" | awk '{sum+=$1} END {if (NR>0) print sum/NR}')

            # Compute Memory statistics
            MEM_MAX=$(echo "$MEM_DATA" | sort -nr | head -1)
            MEM_MIN=$(echo "$MEM_DATA" | sort -n | head -1)
            MEM_AVG=$(echo "$MEM_DATA" | awk '{sum+=$1; count+=1} END {if (count>0) print sum/count}')

            # Format memory values to 2 decimal places
            MEM_MAX=$(printf "%.2f" "$MEM_MAX")
            MEM_MIN=$(printf "%.2f" "$MEM_MIN")
            MEM_AVG=$(printf "%.2f" "$MEM_AVG")

            # Display results using proper formatting
            printf "%s  %.2f%%       %.2f%%       %.2f%%       %.2f%%       %.2f%%       %.2f%%\n" \
                "$DATE_LABEL" "$CPU_MAX" "$CPU_MIN" "$CPU_AVG" "$MEM_MAX" "$MEM_MIN" "$MEM_AVG"
        else
            echo "$DATE_LABEL  No data available"
        fi
    else
        echo "$DATE_LABEL  SAR file not found"
    fi
done
