#!/bin/bash

YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
WHITE="\033[1;37m"
RESET="\033[0m"
DATACENTER="CHIARETTO"
CLUSTER="HOME"

hosts=$(govc find -dc="$DATACENTER" -type h | awk -F'/' '{print $4}' | while read -r host; do
  power_state=$(govc host.info -json "$host" | jq -r '.hostSystems[0].runtime.powerState' || echo "unknown")
  if [ "$power_state" == "poweredOn" ]; then
    echo "$host"
  fi
done)

tempfile=$(mktemp)

{
  echo -e "${WHITE}CPU and Memory Usage of Nodes in VMware:${RESET}"
  echo "-------------------------------------------------------------"
  for host in $hosts; do
    host_info=$(govc host.info -json "$host")
    cpu_usage=$(echo "$host_info" | jq '.hostSystems[0].summary.quickStats.overallCpuUsage' | awk '{printf "%.2f", $1 / 1000}')
    cpu_cores=$(echo "$host_info" | jq '.hostSystems[0].hardware.cpuInfo.numCpuCores')
    cpu_hz=$(echo "$host_info" | jq '.hostSystems[0].hardware.cpuInfo.hz')
    cpu_total=$(awk -v cores="$cpu_cores" -v hz="$cpu_hz" 'BEGIN { printf "%.2f", (cores * hz) / 1000000000 }')
    mem_usage=$(echo "$host_info" | jq '.hostSystems[0].summary.quickStats.overallMemoryUsage' | awk '{printf "%.2f", $1 / 1024}')
    mem_total=$(echo "$host_info" | jq '.hostSystems[0].hardware.memorySize' | awk '{printf "%.2f", $1 / 1024 / 1024 / 1024}')
    cpu_percentage_val=$(awk "BEGIN {printf \"%.2f\", ($cpu_usage / $cpu_total) * 100}")
    mem_percentage_val=$(awk "BEGIN {printf \"%.2f\", ($mem_usage / $mem_total) * 100}")

    if (( $(echo "$cpu_percentage_val > 70" | bc -l) )); then
      cpu_percentage="${RED}${cpu_percentage_val}%${RESET}"
    elif (( $(echo "$cpu_percentage_val >= 50" | bc -l) )); then
      cpu_percentage="${YELLOW}${cpu_percentage_val}%${RESET}"
    else
      cpu_percentage="${GREEN}${cpu_percentage_val}%${RESET}"
    fi

    if (( $(echo "$mem_percentage_val > 70" | bc -l) )); then
      mem_percentage="${RED}${mem_percentage_val}%${RESET}"
    elif (( $(echo "$mem_percentage_val >= 50" | bc -l) )); then
      mem_percentage="${YELLOW}${mem_percentage_val}%${RESET}"
    else
      mem_percentage="${GREEN}${mem_percentage_val}%${RESET}"
    fi

    echo -e "${WHITE}Host: $host${RESET}"
    echo -e "  ${WHITE}CPU Usage:${RESET} $cpu_usage GHz ($cpu_percentage)"
    echo -e "  ${WHITE}Memory Usage:${RESET} $mem_usage GB / $mem_total GB ($mem_percentage)"
    echo "-------------------------------------------------------------"
  done
} > "$tempfile"

tmux popup -E -w 50% -h 50% "cat $tempfile; read -n 1 -s -r -p 'Press any key to close...'"
rm -f "$tempfile"
