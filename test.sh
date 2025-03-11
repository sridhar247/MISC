#!/bin/bash

echo -e "Date\t\tAverage CPU Utilization (%)"

for i in {1..7}; do
    DATE=$(date -d "$i days ago" +"%Y-%m-%d")
    SARFILE="/var/log/sa/sa$(date -d "$i days ago" +%d)"

    if [ -f "$SARFILE" ]; then
        AVG_CPU=$(sar -u -f "$SARFILE" | \
                  awk '/^[0-9]/ {usage+=(100 - $8); count++} END {if(count>0) printf "%.2f", usage/count; else print "N/A"}')
        echo -e "$DATE\t$AVG_CPU%"
    else
        echo -e "$DATE\tNo Data"
    fi
done
