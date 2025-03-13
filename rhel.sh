#!/bin/bash
# Script to compute the average, min, and max values for:
#   - CPU utilization (calculated as 100 - %idle)
#   - Thread utilization (using run queue size from sar -q)
#   - Memory utilization (%memused from sar -r)
#   - Disk utilization (%util from sar -d)
#   - Swap activity (sum of pswpin/s and pswpout/s from sar -W)
#
# The script uses SAR’s historical data for the current day (since midnight).

# Check if sar command is available
if ! command -v sar >/dev/null 2>&1; then
  echo "Error: 'sar' command not found. Please install the sysstat package."
  exit 1
fi

# Define start time as midnight for today's data
START_TIME="00:00:00"

# Function to compute stats (avg, min, max) from a given SAR command and an awk expression for the value.
# The awk expression should assign the value to a variable (e.g. "val = ...").
calc_stats() {
  # $1 is the SAR command (with options) to run
  # $2 is the awk expression that computes the desired value from each line.
  eval "$1" | awk -v expr="$2" '
    # Process only lines that begin with a digit (ignoring headers and "Average:" lines)
    $1 ~ /^[0-9]/ {
      # Evaluate the expression to compute the metric value.
      # (For our use, expr will be something like "val = 100 - $NF")
      eval(expr);
      sum += val;
      if (NR==1 || val < min) { min = val }
      if (NR==1 || val > max) { max = val }
      count++
    }
    END {
      if (count > 0)
        printf "%.2f %.2f %.2f", sum/count, min, max;
      else
        printf "N/A N/A N/A"
    }
  '
}

# CPU Utilization: Use sar -u; compute busy = 100 - %idle (assumed to be the last column)
cpu_stats=$(calc_stats "sar -u -s $START_TIME" 'val = 100 - $NF')

# Thread Utilization: Use sar -q; we take the run queue size (assumed to be column 2)
thread_stats=$(calc_stats "sar -q -s $START_TIME" 'val = $2')

# Memory Utilization: Use sar -r; we take %memused (assumed to be in column 4; note: column order: time, kbmemfree, kbmemused, %memused, ...)
mem_stats=$(calc_stats "sar -r -s $START_TIME" 'val = $4')

# Disk Utilization: Use sar -d; we take %util (assumed to be the last column)
disk_stats=$(calc_stats "sar -d -s $START_TIME" 'val = $NF')

# Swap Activity: Use sar -W; sum pswpin/s and pswpout/s (assumed columns: time, pswpin/s, pswpout/s)
swap_stats=$(calc_stats "sar -W -s $START_TIME" 'val = $2 + $3')

# Print the results in a table
printf "\n%-25s %-15s %-15s %-15s\n" "Metric" "Average" "Minimum" "Maximum"
printf "%-25s %-15s %-15s %-15s\n" "-------------------------" "---------------" "---------------" "---------------"
read cpu_avg cpu_min cpu_max <<< "$cpu_stats"
printf "%-25s %-15s %-15s %-15s\n" "CPU Utilization (%)" "$cpu_avg" "$cpu_min" "$cpu_max"

read thr_avg thr_min thr_max <<< "$thread_stats"
printf "%-25s %-15s %-15s %-15s\n" "Thread (Run Queue)" "$thr_avg" "$thr_min" "$thr_max"

read mem_avg mem_min mem_max <<< "$mem_stats"
printf "%-25s %-15s %-15s %-15s\n" "Memory Utilization (% used)" "$mem_avg" "$mem_min" "$mem_max"

read disk_avg disk_min disk_max <<< "$disk_stats"
printf "%-25s %-15s %-15s %-15s\n" "Disk Utilization (%util)" "$disk_avg" "$disk_min" "$disk_max"

read swap_avg swap_min swap_max <<< "$swap_stats"
printf "%-25s %-15s %-15s %-15s\n" "Swap Activity (pswpin+pswpout)" "$swap_avg" "$swap_min" "$swap_max"
printf "\n"
