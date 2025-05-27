#!/usr/bin/env bash

channels=("4.14" "4.16" "4.17" "4.18")
CACHE_FILE="/vms/clusters/.ocp_versions_cache"

#clean cache
> "$CACHE_FILE"

temp_dir=$(mktemp -d)
combined_output="$temp_dir/combined.out"
#printf "%s\n" "-----------------------------------------------" >> "$combined_output"
#printf "%-20s %-30s\n" "Version" "Created Date" >> "$combined_output"
for channel in "${channels[@]}"; do
    {
        #printf "%-10s %-30s\n" "-------" "------------------------------------"
                                
        releases=$(curl -s "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/" | \
          grep -oP "href=\"$channel\.[0-9]+/" | \
          sed 's/href="//;s/\/$//' | \
          sort -V | \
          tail -n 5
        )
        for version in $releases; do
            release_url="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$version/release.txt"
            created_date=$(curl -s "$release_url" | grep "^Created:" | cut -d':' -f2- | xargs -I{} date -d "{}" +"+%c")
            printf "%-10s %-30s\n" "$version" "$created_date"
        done
        echo ""-----------------------------------------------""
    } >> "$combined_output"
done

cp "$combined_output" "$CACHE_FILE"

rm -rf "$temp_dir"