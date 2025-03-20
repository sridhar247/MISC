#!/bin/bash
# System Utilization Script
#
# This script supports two modes:
#
#   1. monitor  - Monitors the current day’s CPU and memory utilization live for 5 minutes,
#                 capturing data at 1-minute intervals.
#                 It logs a timestamp (date and time), hostname, CPU utilization (100 - %idle),
#                 memory utilization (% used), allocated CPUs, and allocated Memory (MB)
#                 into a CSV file (current_day_utilization.csv).
#
#   2. report   - Generates a historic 14-day report using SAR logs. For each of the past 14 days,
#                 it calculates:
#                   • Average CPU utilization = 100 - average %idle (from sar -u)
#                   • Average memory utilization = average %memused (from sar -r)
#                 The report also shows how many CPUs and how much memory (in MB) the server is allocated.
#                 The results are written to historic_utilization.csv and displayed in tabular form.
#
# Usage:
#   ./system_utilization.sh monitor
#   ./system_utilization.sh report

usage() {
    echo "Usage: $0 {monitor|report}"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

MODE=$1

# Function to retrieve the allocated CPU and memory for the server
get_allocated_cpu() {
    nproc
}

get_allocated_mem() {
    free -m | awk '/Mem:/ {print $2}'
}

if [ "$MODE" == "monitor" ]; then
    # -------------------------------
    # Current Day Monitoring (1-min intervals for 5 minutes)
    # -------------------------------
    OUTPUT_FILE="current_day_utilization.csv"
    # Write header if file does not exist
    if [ ! -f "$OUTPUT_FILE" ]; then
        echo "Timestamp,Hostname,CPU Utilization (%),Memory Utilization (%),Allocated CPUs,Allocated Memory (MB)" > "$OUTPUT_FILE"
    fi

    echo "Starting live monitoring for 5 minutes at 1-minute intervals."

    # Get hostname and allocated resources (assumed constant during monitoring)
    HOSTNAME=$(hostname)
    ALLOCATED_CPU=$(get_allocated_cpu)
    ALLOCATED_MEM=$(get_allocated_mem)

    # Monitor for 5 iterations (1 minute each)
    for ((i=1; i<=5; i++)); do
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")

        # Get CPU idle percentage using top and then compute utilization as 100 - idle.
        cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
        if [ -z "$cpu_idle" ]; then
            cpu_util="N/A"
        else
            cpu_util=$(echo "scale=2; 100 - $cpu_idle" | bc)
        fi

        # Get memory utilization (%) using free.
        mem_usage=$(free | awk '/Mem:/ {printf "%.2f", $3/$2*100}')

        # Append current timestamp and metrics to the CSV log file.
        echo "$timestamp, $HOSTNAME, $cpu_util, $mem_usage, $ALLOCATED_CPU, $ALLOCATED_MEM" >> "$OUTPUT_FILE"
        echo "[$timestamp] Host: $HOSTNAME | CPU Utilization: $cpu_util% | Memory Utilization: $mem_usage% | Allocated CPUs: $ALLOCATED_CPU | Allocated Memory: ${ALLOCATED_MEM}MB"

        # Sleep for 1 minute (60 seconds) before next measurement unless it's the last iteration
        if [ $i -lt 5 ]; then
            sleep 60
        fi
    done

    echo "Live monitoring complete. Data saved in $OUTPUT_FILE."

elif [ "$MODE" == "report" ]; then
    # -------------------------------
    # Historic 14-Day Report (using SAR logs)
    # -------------------------------
    OUTPUT="historic_utilization.csv"
    allocated_cpu=$(get_allocated_cpu)
    allocated_mem=$(get_allocated_mem)
    echo "Date,CPU Utilization (%),Memory Utilization (%),Allocated CPUs,Allocated Memory (MB)" > "$OUTPUT"

    # Loop over the past 14 days (including today as 0 days ago)
    for i in {13..0}; do
        day_date=$(date -d "$i days ago" +%Y-%m-%d)
        day_num=$(date -d "$i days ago" +%d)
        sar_file="/var/log/sa/sa${day_num}"

        if [ ! -f "$sar_file" ]; then
            cpu_util="N/A"
            mem_util="N/A"
        else
            # --- CPU Utilization ---
            # Extract the average idle percentage from SAR and compute 100 - idle.
            cpu_idle=$(sar -u -f "$sar_file" | awk '/Average/ {print $NF}')
            if [ -z "$cpu_idle" ]; then
                cpu_util="N/A"
            else
                cpu_util=$(echo "scale=2; 100 - $cpu_idle" | bc)
            fi

            # --- Memory Utilization ---
            # Extract average %memused from SAR.
            header=$(sar -r -f "$sar_file" | head -n 3 | grep "%memused")
            col_num=4  # default column if header parsing fails
            if [ -n "$header" ]; then
                col_num=$(echo "$header" | awk '{for(i=1;i<=NF;i++){if($i=="%memused"){print i; exit}}}')
            fi
            mem_util=$(sar -r -f "$sar_file" | awk -v col="$col_num" '/Average/ {print $col}')
            if [ -z "$mem_util" ]; then
                mem_util="N/A"
            fi
        fi

        echo "$day_date, $cpu_util, $mem_util, $allocated_cpu, $allocated_mem" >> "$OUTPUT"
    done

    echo ""
    echo "Historic 14-Day System Utilization (using SAR):"
    column -s, -t "$OUTPUT"
else
    usage
fi
