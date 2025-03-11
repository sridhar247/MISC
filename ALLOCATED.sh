#!/bin/bash
# Script to check allocated CPU and memory (in GB) on a Linux server

echo "========================================"
echo "  System Resource Allocation Summary"
echo "========================================"

# Get CPU count (vCPUs)
CPU_COUNT=$(nproc)

# Get total memory in GB
TOTAL_MEM_GB=$(awk '/MemTotal/ {printf "%.2f", $2/1024/1024}' /proc/meminfo)

# Get total swap in GB
TOTAL_SWAP_GB=$(awk '/SwapTotal/ {printf "%.2f", $2/1024/1024}' /proc/meminfo)

# Print results
echo "Allocated CPU (vCPUs):   $CPU_COUNT"
echo "Total Memory (GB):       $TOTAL_MEM_GB GB"
echo "Total Swap Memory (GB):  $TOTAL_SWAP_GB GB"

echo "========================================"
