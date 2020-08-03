#!/bin/sh

# Filter the FS related log
awk '{if ($6 == "[FS]") print $0;}' /var/log/messages > fs_only_log.txt

# Processing the log file
awk -f calc_cpu_time.awk fs_only_log.txt > fs_output.txt

cat fs_output.txt

#gnuplot raw_data
