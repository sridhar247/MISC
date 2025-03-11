#!/bin/bash

echo -e "Date\t\tAvg CPU%"

for i in {1..7}; do
    DATE=$(date -d "$i days ago" +"%Y-%m-%d")
    SARFILE="/var/log/sa/sa$(date -d "$i days ago" +%d)"

    if [ -f "$SARFILE" ]; then
        CPU_DATA=$(sar -u -f "$SARFILE" | awk '/^[0-9]/ {print 100 - $8}')

        if [ -n "$CPU_DATA" ]; then
            AVG_CPU=$(echo "$CPU_DATA" | awk '{sum+=$1; cnt++} END {if(cnt>0) printf "%.2f", sum/cnt; else print "N/A"}')
            echo -e "$DATE\t$AVG_CPU%"
        else
            echo -e "$DATE\tNo Valid Data"
        fi
    else
        echo -e "$DATE\tNo Data"
    fi
done
