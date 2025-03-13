#!/bin/bash
# Script to calculate the total number of threads running on a RHEL8 system

# Method 1: Using the 'ps' command.
# The '--no-headers' option removes the header line, so each remaining line represents a thread.
total_threads_ps=$(ps -eLf --no-headers | wc -l)
echo "Total threads (using ps): $total_threads_ps"

# Method 2: Using the /proc filesystem.
# This command finds all directories under /proc/[PID]/task, where each such directory represents a thread.
total_threads_proc=$(find /proc/[0-9]*/task -mindepth 1 -maxdepth 1 -type d | wc -l)
echo "Total threads (using /proc): $total_threads_proc"
