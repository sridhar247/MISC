#!/bin/bash

echo -e "Date\t\tAvg Mem%\tMax Mem%\tMin Mem%"

for i in {1..7}; do
    DATE=$(date -d "$i days ago" +"%Y-%m-%d")
    SARFILE="/var/log/sa/sa$(date -d "$i days ago" +%d)"

    if [ -f "$SARFILE" ]; then
        MEM_DATA=$(sar -r -f "$SARFILE" | awk 'NR>3 && $1 ~ /^[0-9]/ {print 100*($4/($2+$4))}')

        MEM_AVG=$(echo "$MEM_DATA" | awk '{sum+=$1; cnt++} END {if(cnt>0) printf "%.2f", sum/cnt; else print "N/A"}')
        MEM_MAX=$(echo "$MEM_DATA" | sort -nr | head -1)
        MEM_MIN=$(echo "$MEM_DATA" | sort -n | head -1)

        echo -e "$DATE\t$MEM_AVG%\t\t$MEM_MAX%\t\t$MEM_MIN%"
    else
        echo -e "$DATE\tNo Data\t\tNo Data\t\tNo Data"
    fi
done
