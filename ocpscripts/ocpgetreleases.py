#!/usr/bin/env python3

import os
import json

CACHE_DIR = "/vms/clusters/.cache/ocpgraph"

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

    for version in sorted(seen, key=lambda v: tuple(map(int, v.split(".")))):
        print(version)

if __name__ == "__main__":
    list_versions()
