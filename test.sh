#!/bin/bash

echo -e "Date\t\tAvg CPU%\tMax CPU%\tMin CPU%"

for i in {1..7}; do
    DATE=$(date -d "$i days ago" +"%Y-%m-%d")
    SARFILE="/var/log/sa/sa$(date -d "$i days ago" +%d)"

    if [ -f "$SARFILE" ]; then
        CPU_DATA=$(sar -u -f "$SARFILE" | awk 'NR>3 && $1 ~ /^[0-9]/ {print 100 - $8}')
        
        CPU_AVG=$(echo "$CPU_DATA" | awk '{sum+=$1; cnt++} END {if(cnt>0) printf "%.2f", sum/cnt; else print "N/A"}')
        CPU_MAX=$(echo "$CPU_DATA" | sort -nr | head -1)
        CPU_MIN=$(echo "$CPU_DATA" | sort -n | head -1)
        
        echo -e "$DATE\t$CPU_AVG%\t\t$CPU_MAX%\t\t$CPU_MIN%"
    else
        echo -e "$DATE\tNo Data\t\tNo Data\t\tNo Data"
    fi
done
