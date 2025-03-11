#!/bin/bash

# Check if sysstat (SAR) is installed
if ! command -v sar &> /dev/null; then
    echo "Error: 'sar' command not found. Please install the sysstat package."
    exit 1
fi

# Initialize variables
TOTAL_CPU=0
MAX_CPU=0
MIN_CPU=100
TOTAL_MEM=0
MAX_MEM=0
MIN_MEM=100
DAYS=0

# Iterate through the last 7 days
for i in {0..6}; do
    LOG_FILE="/var/log/sa/sa$(date --date="$i days ago" +%d)"
    
    if [ -f "$LOG_FILE" ]; then
        # Get CPU Usage (Subtract Idle CPU from 100)
        CPU_VALUES=$(sar -u -f "$LOG_FILE" | awk '/^[0-9]/ {print 100 - $NF}')
        for val in $CPU_VALUES; do
            TOTAL_CPU=$(awk "BEGIN {print $TOTAL_CPU + $val}")
            if (( $(echo "$val > $MAX_CPU" | bc -l) )); then MAX_CPU=$val; fi
            if (( $(echo "$val < $MIN_CPU" | bc -l) )); then MIN_CPU=$val; fi
        done

        # Get Memory Usage (Used/Total * 100)
        MEM_VALUES=$(sar -r -f "$LOG_FILE" | awk '/^[0-9]/ {print ($4/$2)*100}')
        for val in $MEM_VALUES; do
            TOTAL_MEM=$(awk "BEGIN {print $TOTAL_MEM + $val}")
            if (( $(echo "$val > $MAX_MEM" | bc -l) )); then MAX_MEM=$val; fi
            if (( $(echo "$val < $MIN_MEM" | bc -l) )); then MIN_MEM=$val; fi
        done

        ((DAYS++))
    fi
done

# Calculate Averages
if [ $DAYS -gt 0 ]; then
    AVG_CPU=$(awk "BEGIN {printf \"%.2f\", $TOTAL_CPU / (DAYS * 24)}")
    AVG_MEM=$(awk "BEGIN {printf \"%.2f\", $TOTAL_MEM / (DAYS * 24)}")
else
    AVG_CPU="No data"
    AVG_MEM="No data"
fi

# Get Current Disk Utilization (SAR does not log disk usage, using df instead)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

# Print Results
echo "--------------------------------------------"
echo "📊 7-Day System Utilization Report"
echo "--------------------------------------------"
echo "🖥️  CPU Usage:"
echo "     🔹 Average:  $AVG_CPU%"
echo "     🔺 Highest:  $MAX_CPU%"
echo "     🔻 Lowest:   $MIN_CPU%"
echo ""
echo "💾  Memory Usage:"
echo "     🔹 Average:  $AVG_MEM%"
echo "     🔺 Highest:  $MAX_MEM%"
echo "     🔻 Lowest:   $MIN_MEM%"
echo ""
echo "📂  Disk Utilization (Current): $DISK_USAGE"
echo "--------------------------------------------"
