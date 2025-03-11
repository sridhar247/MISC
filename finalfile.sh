#!/bin/bash

echo "Fetching CPU and Memory utilization for past 7 days..."

# Print table header
echo -e "\n================================================================================="
echo -e "Date\t\t| CPU Usage (%) \t\t| Memory Usage (%)"
echo -e "---------------------------------------------------------------------------------"
echo -e " \t\t  Avg\t| High\t| Low\t  ||  Avg\t| High\t| Low"
echo -e "================================================================================="

# Loop through past 7 days
for i in {1..7}; do
    # Get the date
    date_str=$(date --date="$i days ago" +"%Y-%m-%d")
    sar_file="/var/log/sa/sa$(date --date="$i days ago" +%d)"

    if [[ -f "$sar_file" ]]; then
        # CPU Utilization Calculation (100 - %idle)
        cpu_values=$(sar -u -f "$sar_file" | awk 'NR>3 {print 100 - $8}')
        cpu_avg=$(echo "$cpu_values" | awk '{sum+=$1} END {if (NR > 0) print sum/NR; else print "N/A"}')
        cpu_high=$(echo "$cpu_values" | sort -nr | head -1)
        cpu_low=$(echo "$cpu_values" | sort -n | head -1)

        # Memory Utilization Calculation (Used RAM %)
        mem_values=$(sar -r -f "$sar_file" | awk 'NR>3 {print 100 * ($4 / ($2 + $4))}')
        mem_avg=$(echo "$mem_values" | awk '{sum+=$1} END {if (NR > 0) print sum/NR; else print "N/A"}')
        mem_high=$(echo "$mem_values" | sort -nr | head -1)
        mem_low=$(echo "$mem_values" | sort -n | head -1)

        # Print row in tabular format
        printf "%s\t| %.2f\t| %.2f\t| %.2f\t  ||  %.2f\t| %.2f\t| %.2f\n" \
            "$date_str" "$cpu_avg" "$cpu_high" "$cpu_low" "$mem_avg" "$mem_high" "$mem_low"
    else
        # If sar log file doesn't exist for a day
        echo -e "$date_str\t| No data available"
    fi
done

echo -e "=================================================================================\n"
