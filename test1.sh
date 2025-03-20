#!/bin/bash
# Historic 14-Day System Utilization Report using SAR
# This script extracts historical data from SAR log files for the last 14 days.
# It reports:
#   - CPU Utilization = 100 - average %idle (from sar -u)
#   - Memory Usage (%memused from sar -r)
#   - Disk Utilization (%util for device "sda" from sar -d)
#
# SAR log files are assumed to be located in /var/log/sa/ as saDD (where DD is day of month).

OUTPUT="./historic_utilization.csv"

# Write header to CSV file
echo "Date,CPU Utilization (%),Memory Usage (%),Disk Utilization (%)" > "$OUTPUT"

# Loop over the last 14 days (from 13 days ago to today)
for i in {13..0}; do
    # Get the date and day-of-month (with leading zero)
    day_date=$(date -d "$i days ago" +%Y-%m-%d)
    day_num=$(date -d "$i days ago" +%d)
    sar_file="/var/log/sa/sa${day_num}"

    # Check if SAR file exists; if not, mark as N/A
    if [ ! -f "$sar_file" ]; then
        echo "$day_date, N/A, N/A, N/A" >> "$OUTPUT"
        continue
    fi

    # --- CPU Utilization ---
    # Get the average idle percentage from sar -u and compute 100 - idle.
    # The "Average:" line in sar -u output typically has the idle percentage in the last column.
    cpu_idle=$(sar -u -f "$sar_file" | awk '/Average/ {print $NF}')
    if [ -z "$cpu_idle" ]; then
        cpu_util="N/A"
    else
        cpu_util=$(echo "scale=2; 100 - $cpu_idle" | bc)
    fi

    # --- Memory Usage ---
    # Using sar -r, the "Average:" line reports %memused as the 4th field.
    mem_usage=$(sar -r -f "$sar_file" | awk '/Average/ {print $4}')
    if [ -z "$mem_usage" ]; then
        mem_usage="N/A"
    fi

    # --- Disk Utilization ---
    # Using sar -d, extract the "Average:" line for device "sda"
    disk_util=$(sar -d -f "$sar_file" | awk '$1=="Average:" && $2=="sda" {print $NF}')
    if [ -z "$disk_util" ]; then
        disk_util="N/A"
    fi

    # Append the results for this day to the CSV file
    echo "$day_date, $cpu_util, $mem_usage, $disk_util" >> "$OUTPUT"
done

# Display the collected results in tabular form
echo ""
echo "14-Day Historic System Utilization (using SAR):"
column -s, -t "$OUTPUT"
