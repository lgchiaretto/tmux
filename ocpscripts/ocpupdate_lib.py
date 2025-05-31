#!/usr/bin/env python3

import requests
from collections import deque
import sys
import argparse
import textwrap

GRAPH_URL = "https://api.openshift.com/api/upgrades_info/graph"

def fetch_upgrade_graph(channel):
    params = {"channel": channel, "arch": "amd64"}
    try:
        response = requests.get(GRAPH_URL, params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching graph: {e}", file=sys.stderr)
        sys.exit(2)

def build_graph(data):
    nodes = {i: node["version"] for i, node in enumerate(data["nodes"])}
    graph = {}

    for edge in data.get("edges", []):
        from_v = nodes[edge[0]]
        to_v = nodes[edge[1]]
        graph.setdefault(from_v, []).append((to_v, False, "No Risk", "No Message", "No URL"))

    for edge_group in data.get("conditionalEdges", []):
        risk_info = edge_group.get("risks", [{}])[0]
        risk_name = risk_info.get("name", "No Risk")
        risk_message = risk_info.get("message", "No Message")
        risk_url = risk_info.get("url", "No URL")
        
        for edge in edge_group.get("edges", []):
            from_v = edge.get("from")
            to_v = edge.get("to")
            graph.setdefault(from_v, []).append((to_v, True, risk_name, risk_message, risk_url))
            
    return graph

def find_upgrade_path(graph, from_v, to_v):
    if from_v == to_v:
        return [(from_v, False, "No Risk", "No Message", "No URL")]

    queue = deque([(from_v, [])])
    visited = {from_v}

    while queue:
        current_version, path_so_far = queue.popleft()

        for neighbor, is_conditional, risk_name, risk_message, risk_url in sorted(
            graph.get(current_version, []), 
            reverse=True, 
            key=lambda v: list(map(int, v[0].split('.')))
        ):
            if neighbor not in visited:
                new_path = path_so_far + [(current_version, is_conditional, risk_name, risk_message, risk_url)]
                
                if neighbor == to_v:
                    return new_path + [(to_v, False, "No Risk", "No Message", "No URL")]
                
                visited.add(neighbor)
                queue.append((neighbor, new_path))
                
    return None

def main():
    parser = argparse.ArgumentParser(description="Find upgrade paths between OpenShift versions.")
    parser.add_argument("--from-version", required=True, help="Starting OpenShift version.")
    parser.add_argument("--to-version", required=True, help="Target OpenShift version.")
    parser.add_argument("--channel", required=True, help="The OpenShift update channel (e.g., stable-4.14).")

    args = parser.parse_args()

    graph_data = fetch_upgrade_graph(args.channel)
    upgrade_graph = build_graph(graph_data)
    
    path = find_upgrade_path(upgrade_graph, args.from_version, args.to_version)

    if path:
        formatted_path = " -> ".join(v for v, _, _, _, _ in path)
        print(f"Available path: {formatted_path}")

        detailed_info_lines = []
        for v, is_conditional, risk, message, url in path[1:]:
            if is_conditional:
                wrapped_message = '\n    '.join(textwrap.wrap(message, width=70))
                detailed_info_lines.append(f"Version: {v}\n  - Risk: {risk}\n  - Message: {wrapped_message}\n  - URL: {url}")
        
        if detailed_info_lines:
            print("\n---")
            print("Detailed Information on Conditional Upgrades:")
            print("\n---\n".join(detailed_info_lines))
    else:
        print(f"No upgrade path found from {args.from_version} to {args.to_version} on channel {args.channel}")

if __name__ == "__main__":
    main()