#!/usr/bin/env python

import requests
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime
import re
import os

GRAPH_URL = "https://api.openshift.com/api/upgrades_info/graph"
channels = ["4.16", "4.18", "4.19", "4.20", "4.21", "4.22", "5.0"]
MIRROR_URLS = {
    4: "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/",
    5: "https://mirror.openshift.com/pub/openshift-v5/x86_64/clients/ocp/",
}


def version_sort_key(version):
    parts = []
    for segment in version.split("."):
        if "-rc." in segment:
            base, rc = segment.split("-rc.", 1)
            parts.append((int(base), int(rc), 1))
        elif "-ec." in segment:
            base, ec = segment.split("-ec.", 1)
            parts.append((int(base), int(ec), 2))
        elif segment.isdigit():
            parts.append((int(segment), 0, 0))
        else:
            parts.append((segment,))
    return parts


def mirror_url_for_channel(channel):
    major = int(channel.split(".")[0])
    return MIRROR_URLS.get(major, MIRROR_URLS[4])


def mirror_url_for_version(version):
    major = int(version.split(".")[0])
    return MIRROR_URLS.get(major, MIRROR_URLS[4])


def fetch_stable_versions(channel):
    try:
        response = requests.get(
            GRAPH_URL,
            params={"channel": f"stable-{channel}", "arch": "amd64"},
            timeout=10,
        )
        response.raise_for_status()
        return {node["version"] for node in response.json().get("nodes", [])}
    except requests.exceptions.RequestException:
        return set()


def load_stable_versions_by_channel():
    stable_by_channel = {}
    with ThreadPoolExecutor(max_workers=len(channels)) as executor:
        futures = {executor.submit(fetch_stable_versions, channel): channel for channel in channels}
        for future in futures:
            stable_by_channel[futures[future]] = future.result()
    return stable_by_channel


def find_channel_versions(channel, releases_html):
    major = channel.split(".")[0]
    if channel == "5.0":
        suffixes = re.findall(r'href="5\.0\.(0(?:-rc|-ec)\.[0-9]+)/"', releases_html)
        return [f"5.0.{suffix}" for suffix in suffixes]

    patch_levels = re.findall(rf'href="{re.escape(channel)}\.([0-9]+)/"', releases_html)
    return [f"{channel}.{patch}" for patch in patch_levels]


def get_release_info(version, stable_versions=None):
    stable_marker = "(s)" if stable_versions and version in stable_versions else "   "
    release_url = f"{mirror_url_for_version(version)}{version}/release.txt"
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
                return f"{version:<14} {stable_marker}  {created_date.strftime('%c'):<30}"
    except requests.exceptions.RequestException as e:
        return f"Error fetching {version}: {e}"
    except ValueError:
        return f"Error parsing date for {version}"
    return f"{version:<14} {stable_marker}  Creation date not found"


def process_channel(channel, stable_by_channel):
    channel_output = []
    try:
        response = requests.get(mirror_url_for_channel(channel), timeout=10)
        response.raise_for_status()
        releases_html = response.text

        all_versions = find_channel_versions(channel, releases_html)
        latest_versions = sorted(
            sorted(all_versions, key=version_sort_key, reverse=True)[:5],
            key=version_sort_key,
        )

        stable_versions = stable_by_channel.get(channel, set())
        with ThreadPoolExecutor(max_workers=5) as executor:
            results = list(executor.map(
                lambda version: get_release_info(version, stable_versions),
                latest_versions,
            ))
            channel_output.extend(results)

    except requests.exceptions.RequestException as e:
        channel_output.append(f"Error fetching versions for channel {channel}: {e}")

    channel_output.append("---------------------------------------")
    return channel_output


if __name__ == "__main__":
    header = []
    stable_by_channel = load_stable_versions_by_channel()

    all_outputs = header[:]

    with ThreadPoolExecutor(max_workers=len(channels)) as executor:
        results_per_channel = list(executor.map(
            lambda channel: process_channel(channel, stable_by_channel),
            channels,
        ))
        for output_list in results_per_channel:
            all_outputs.extend(output_list)

    for line in all_outputs:
        print(line)

    cache_file_path = os.path.expanduser("/opt/.ocp_versions_cache")
    with open(cache_file_path, "w", encoding="utf-8") as f:
        for line in all_outputs:
            f.write(line + "\n")
