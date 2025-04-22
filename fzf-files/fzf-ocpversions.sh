#!/bin/bash


API_URL="https://api.openshift.com/api/upgrades_info/v1/graph"
channels=("eus-4.16" "stable-4.17" "eus-4.18")

fetch_releases() {
  local channel=$1
  local output_file=$2
  {
    echo "-----------------------------------------------"
    echo "Fetching information for channel: $channel"
    echo "-----------------------------------------------"
    
    # Fetching data from the API
    response=$(curl -s "$API_URL?channel=$channel")
    
    # Checking if the request was successful
    if [ $? -ne 0 ]; then
      echo "Error accessing the OpenShift API for channel $channel."
      return
    fi

    version_prefix="${channel#*-}" # Extracting the version (e.g., 4.17 from stable-4.17)
    echo "$response" | jq -r --arg version_prefix "$version_prefix" '.nodes[] | select(.version | startswith($version_prefix)) | "\(.version)"' | sort -V | tail -n 5
  } > "$output_file"
}

temp_dir=$(mktemp -d)

pids=()
for channel in "${channels[@]}"; do
  output_file="$temp_dir/$channel.out"
  fetch_releases "$channel" "$output_file" &
  pids+=($!)
done

for pid in "${pids[@]}"; do
  wait "$pid"
done

combined_output="$temp_dir/combined.out"
for channel in "${channels[@]}"; do
  output_file="$temp_dir/$channel.out"
  echo "Channel: $channel" >> "$combined_output" >/dev/null 2>&1
  cat "$output_file" >> "$combined_output"
  echo "" >> "$combined_output" >/dev/null 2>&1
done

if [ -s "$combined_output" ]; then
  ocpversion=$(cat "$combined_output" | fzf-tmux \
              --layout=reverse \
              -h 40 \
              -p "38%,50%" \
              --bind enter:accept
  )
else
  echo "Error: Combined output is empty. No versions to select."
  exit 1
fi

if [ -n "$ocpversion" ]; then
  tmux send-keys $(echo "$ocpversion" | tail -n1)
fi


rm -rf "$temp_dir"