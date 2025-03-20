#!/bin/bash
# Historic 14-Day System Utilization Report using SAR
# This script extracts historical data from SAR log files for the last 14 days.
# It reports:
#   - CPU Utilization = 100 - average %idle (from sar -u)
#   - Memory Usage = average %memused (from sar -r)
#   - Disk Utilization (%util for a specified disk device from sar -d)
#
# SAR log files are assumed to be located in /var/log/sa/ as saDD (where DD is day of month).
#
# Note: Adjust the DISK_DEVICE variable if your system uses a different disk identifier.
#

# Set the disk device to monitor (change if necessary, e.g., nvme0n1, sda1, etc.)
DISK_DEVICE="sda"

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
    cpu_idle=$(sar -u -f "$sar_file" | awk '/Average/ {print $NF}')
    if [ -z "$cpu_idle" ]; then
        cpu_util="N/A"
    else
        cpu_util=$(echo "scale=2; 100 - $cpu_idle" | bc)
    fi

    # --- Memory Usage ---
    # Using sar -r, dynamically determine the column for "%memused".
    header=$(sar -r -f "$sar_file" | head -n 3 | grep "%memused")
    col_num=4  # default column if header parsing fails
    if [ -n "$header" ]; then
        col_num=$(echo "$header" | awk '{for(i=1;i<=NF;i++){if($i=="%memused"){print i; exit}}}')
    fi
    mem_usage=$(sar -r -f "$sar_file" | awk -v col="$col_num" '/Average/ {print $col}')
    if [ -z "$mem_usage" ]; then
        mem_usage="N/A"
    fi

    # --- Disk Utilization ---
    # Using sar -d, search for the "Average:" line that mentions our disk device,
    # then extract the last field (assumed to be the %util column).
    disk_util=$(sar -d -f "$sar_file" | awk -v dev="$DISK_DEVICE" '$0 ~ "Average:" && $0 ~ dev {print $NF}')
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
