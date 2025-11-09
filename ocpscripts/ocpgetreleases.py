#!/usr/bin/env python3

import os
import json

CACHE_DIR = "/opt/.ocpgraph"

def list_versions():
    seen = set()
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

    filtered_versions = [
        v for v in seen if not v.startswith("4.11.")
    ]

    for version in sorted(filtered_versions, key=lambda v: tuple(map(int, v.split(".")))):
        print(version)

if __name__ == "__main__":
    list_versions()