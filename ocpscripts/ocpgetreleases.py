#!/usr/bin/env python3

import os
import json
import re
import requests

CACHE_DIR = "/opt/.ocpgraph"
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


def fetch_mirror_versions(major):
    url = MIRROR_URLS.get(major)
    if not url:
        return set()
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        pattern = rf'href="({major}\.\d+\.[^"/]+)/"'
        return set(re.findall(pattern, response.text))
    except (requests.RequestException, ValueError):
        return set()


def list_versions():
    seen = set()
    if os.path.isdir(CACHE_DIR):
        for filename in os.listdir(CACHE_DIR):
            if filename.endswith(".json"):
                path = os.path.join(CACHE_DIR, filename)
                try:
                    with open(path) as f:
                        data = json.load(f)
                        for node in data.get("nodes", []):
                            version = node.get("version")
                            if version and version not in seen:
                                seen.add(version)
                except Exception:
                    continue

    for major in MIRROR_URLS:
        seen.update(fetch_mirror_versions(major))

    filtered_versions = [
        v for v in seen if not v.startswith("4.11.")
    ]

    for version in sorted(filtered_versions, key=version_sort_key, reverse=True):
        print(version)


if __name__ == "__main__":
    list_versions()
