#!/bin/bash

# Output file
OUTPUT_FILE="system_utilization_report.txt"

# Function to calculate CPU Utilization
cpu_utilization() {
    echo "CPU Utilization (User + System) for Past 7 Days:" >> $OUTPUT_FILE
    echo "------------------------------------------------" >> $OUTPUT_FILE
    echo "Date        | Avg CPU (%) | Max CPU (%) | Min CPU (%)" >> $OUTPUT_FILE
    echo "------------------------------------------------" >> $OUTPUT_FILE
    
    for i in {1..7}; do
        DATE=$(date --date="$i days ago" +%Y-%m-%d)
        FILE="/var/log/sa/sa$(date --date="$i days ago" +%d)"

        if [[ -f $FILE ]]; then
            CPU_VALUES=$(sar -u -f "$FILE" | awk 'NR>3 {print 100-$NF}')
            AVG=$(echo "$CPU_VALUES" | awk '{sum+=$1} END {if (NR>0) print sum/NR; else print 0}')
            MAX=$(echo "$CPU_VALUES" | sort -nr | head -1)
            MIN=$(echo "$CPU_VALUES" | sort -n | head -1)
            
            echo "$DATE | $AVG | $MAX | $MIN" >> $OUTPUT_FILE
        else
            echo "$DATE | Data not available" >> $OUTPUT_FILE
        fi
    done
    echo "------------------------------------------------" >> $OUTPUT_FILE
}

# Function to calculate Memory Utilization
memory_utilization() {
    echo "Memory Utilization for Past 7 Days:" >> $OUTPUT_FILE
    echo "------------------------------------------------" >> $OUTPUT_FILE
    echo "Date        | Avg Memory (%) | Max Memory (%) | Min Memory (%)" >> $OUTPUT_FILE
    echo "------------------------------------------------" >> $OUTPUT_FILE
    
    for i in {1..7}; do
        DATE=$(date --date="$i days ago" +%Y-%m-%d)
        FILE="/var/log/sa/sa$(date --date="$i days ago" +%d)"

        if [[ -f $FILE ]]; then
            MEM_VALUES=$(sar -r -f "$FILE" | awk 'NR>3 {print 100 * ($4 / ($2 + $4))}') # Correct % memory usage
            AVG=$(echo "$MEM_VALUES" | awk '{sum+=$1} END {if (NR>0) print sum/NR; else print 0}')
            MAX=$(echo "$MEM_VALUES" | sort -nr | head -1)
            MIN=$(echo "$MEM_VALUES" | sort -n | head -1)
            
            echo "$DATE | $AVG | $MAX | $MIN" >> $OUTPUT_FILE
        else
            echo "$DATE | Data not available" >> $OUTPUT_FILE
        fi
    done
    echo "------------------------------------------------" >> $OUTPUT_FILE
}

# Function to calculate Disk Utilization
disk_utilization() {
    echo "Disk Utilization for Past 7 Days:" >> $OUTPUT_FILE
    echo "------------------------------------------------" >> $OUTPUT_FILE
    echo "Date        | Avg Disk (%) | Max Disk (%) | Min Disk (%)" >> $OUTPUT_FILE
    echo "------------------------------------------------" >> $OUTPUT_FILE
    
    for i in {1..7}; do
        DATE=$(date --date="$i days ago" +%Y-%m-%d)
        FILE="/var/log/sa/sa$(date --date="$i days ago" +%d)"

        if [[ -f $FILE ]]; then
            DISK_VALUES=$(sar -d -f "$FILE" | awk 'NR>3 {print $NF}') # %disk busy
            AVG=$(echo "$DISK_VALUES" | awk '{sum+=$1} END {if (NR>0) print sum/NR; else print 0}')
            MAX=$(echo "$DISK_VALUES" | sort -nr | head -1)
            MIN=$(echo "$DISK_VALUES" | sort -n | head -1)
            
            echo "$DATE | $AVG | $MAX | $MIN" >> $OUTPUT_FILE
        else
            echo "$DATE | Data not available" >> $OUTPUT_FILE
        fi
    done
    echo "------------------------------------------------" >> $OUTPUT_FILE
}

# Run functions and save results
echo "System Utilization Report (Past 7 Days)" > $OUTPUT_FILE
echo "========================================" >> $OUTPUT_FILE

cpu_utilization
memory_utilization
disk_utilization

# Display the report
cat $OUTPUT_FILE
