#!/usr/bin/env python

import requests
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime
import re

channels = ["4.14", "4.16", "4.17", "4.18", "4.19", "4.20"]

def get_release_info(version):
    release_url = f"https://mirror.openshift.com/pub/openshift-v4/clients/ocp/{version}/release.txt"
    try:
        response = requests.get(release_url, timeout=10)
        response.raise_for_status()
        for line in response.text.splitlines():
            if line.startswith("Created:"):
                created_date_str = line.split(":", 1)[1].strip()
                try:
                    created_date = datetime.strptime(created_date_str, "%Y-%m-%dT%H:%M:%SZ")
                except ValueError:
                    try:
                        created_date = datetime.strptime(created_date_str, "%a %b %d %H:%M:%S %Z %Y")
                    except ValueError:
                        created_date = datetime.strptime(created_date_str.replace(" UTC", ""), "%a %b %d %H:%M:%S %Y")
                return f"{version:<10} {created_date.strftime('%c'):<30}"
    except requests.exceptions.RequestException as e:
        return f"Error fetching {version}: {e}"
    except ValueError:
        return f"Error parsing date for {version}"
    return f"{version:<10} Creation date not found"

def process_channel(channel):
    channel_output = []
    try:
        response = requests.get(f"https://mirror.openshift.com/pub/openshift-v4/clients/ocp/", timeout=10)
        response.raise_for_status()
        releases_html = response.text

        found_versions = re.findall(rf'href="{re.escape(channel)}\.([0-9]+)/"', releases_html)
        numeric_versions = sorted([int(v) for v in found_versions], reverse=True)[:5]
        latest_versions = [f"{channel}.{v}" for v in sorted(numeric_versions)]

        with ThreadPoolExecutor(max_workers=5) as executor: 
            results = list(executor.map(get_release_info, latest_versions))
            channel_output.extend(results)

    except requests.exceptions.RequestException as e:
        channel_output.append(f"Error fetching versions for channel {channel}: {e}")

    channel_output.append("---------------------------------------")
    return channel_output

if __name__ == "__main__":
    header = []

    all_outputs = header[:]

    with ThreadPoolExecutor(max_workers=len(channels)) as executor:
        results_per_channel = list(executor.map(process_channel, channels))
        for output_list in results_per_channel:
            all_outputs.extend(output_list)

    for line in all_outputs:
        print(line)

    with open("~/.ocp_versions_cache", "w", encoding="utf-8") as f:
        for line in all_outputs:
            f.write(line.replace("    ", "        ") + "\n")
