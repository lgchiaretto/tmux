#!/bin/bash

YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
WHITE="\033[1;37m"
RESET="\033[0m"
DATACENTER="CHIARETTO"
ICON_CPU="🖥️"
ICON_MEM="🧠"
ICON_DISK="💽"

get_color_by_percentage() {
  local percentage=$1
  local high_threshold=$2
  local medium_threshold=$3
  
  if (( $(echo "$percentage > $high_threshold" | bc -l) )); then
    echo "$RED"
  elif (( $(echo "$percentage >= $medium_threshold" | bc -l) )); then
    echo "$YELLOW"
  else
    echo "$GREEN"
  fi
}

process_host() {
  local host=$1
  local host_info=$(govc host.info -json "$host")
  
  local cpu_usage=$(echo "$host_info" | jq -r '.hostSystems[0].summary.quickStats.overallCpuUsage' | awk '{printf "%.2f", $1 / 1000}')
  local cpu_cores=$(echo "$host_info" | jq -r '.hostSystems[0].hardware.cpuInfo.numCpuCores')
  local cpu_hz=$(echo "$host_info" | jq -r '.hostSystems[0].hardware.cpuInfo.hz')
  local cpu_total=$(awk -v cores="$cpu_cores" -v hz="$cpu_hz" 'BEGIN { printf "%.2f", (cores * hz) / 1000000000 }')
  local mem_usage=$(echo "$host_info" | jq -r '.hostSystems[0].summary.quickStats.overallMemoryUsage' | awk '{printf "%.2f", $1 / 1024}')
  local mem_total=$(echo "$host_info" | jq -r '.hostSystems[0].hardware.memorySize' | awk '{printf "%.2f", $1 / 1024 / 1024 / 1024}')
  
  local cpu_percentage=$(awk "BEGIN {printf \"%.2f\", ($cpu_usage / $cpu_total) * 100}")
  local mem_percentage=$(awk "BEGIN {printf \"%.2f\", ($mem_usage / $mem_total) * 100}")
  
  local cpu_color=$(get_color_by_percentage "$cpu_percentage" 70 50)
  local mem_color=$(get_color_by_percentage "$mem_percentage" 70 50)
  
  echo -e "${WHITE}Host: $host${RESET}"
  echo -e "  ${WHITE}${ICON_CPU} CPU Usage:${RESET} $cpu_usage GHz (${cpu_color}${cpu_percentage}%${RESET})"
  echo -e "  ${WHITE}${ICON_MEM} Memory Usage:${RESET} $mem_usage GB / $mem_total GB (${mem_color}${mem_percentage}%${RESET})"
  
  local datastore_ids=$(echo "$host_info" | jq -r '.hostSystems[0].datastore[]?.value // empty' 2>/dev/null | grep -v "^$")
  
  if [ -n "$datastore_ids" ]; then
    while IFS= read -r datastore_id; do
      [ -z "$datastore_id" ] && continue
      
      local ds_info=$(govc datastore.info -json "$datastore_id" 2>/dev/null)
      [ "$ds_info" = "{}" ] && continue
      
      local datastore=$(echo "$ds_info" | jq -r '.datastores[0].name // empty')
      [ -z "$datastore" ] || [ "$datastore" = "null" ] && continue
      
      local ds_capacity=$(echo "$ds_info" | jq -r '.datastores[0].summary.capacity' | awk '{printf "%.0f", $1 / 1073741824}')
      local ds_free=$(echo "$ds_info" | jq -r '.datastores[0].summary.freeSpace' | awk '{printf "%.0f", $1 / 1073741824}')
      
      [[ ! "$ds_capacity" =~ ^[0-9]+$ ]] || [ "$ds_capacity" -eq 0 ] && continue
      
      local ds_used=$(awk "BEGIN {printf \"%.0f\", $ds_capacity - $ds_free}")
      local ds_percentage=$(awk "BEGIN {printf \"%.2f\", ($ds_used / $ds_capacity) * 100}")
      
      local ds_color=$(get_color_by_percentage "$ds_percentage" 80 60)
  echo -e "  ${WHITE}${ICON_DISK} $datastore:${RESET} ${ds_color}${ds_used}GB/${ds_capacity}GB${RESET}"
    done <<< "$datastore_ids"
  fi
  
  echo "-------------------------------------------------------------"
}

hosts=$(govc find -dc="$DATACENTER" -type h | awk -F'/' '{print $4}' | while read -r host; do
  power_state=$(govc host.info -json "$host" | jq -r '.hostSystems[0].runtime.powerState' 2>/dev/null || echo "unknown")
  [ "$power_state" = "poweredOn" ] && echo "$host"
done)

echo -e "${WHITE}CPU, Memory and Datastore Usage of VMware Hosts:${RESET}"
echo "-------------------------------------------------------------"

for host in $hosts; do
  process_host "$host"
done
