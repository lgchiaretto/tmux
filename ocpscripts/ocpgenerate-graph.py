#!/usr/bin/env python3

import requests
from collections import deque
import sys
import argparse

GRAPH_URL = "https://api.openshift.com/api/upgrades_info/graph"

def fetch_upgrade_graph(channel):
    params = {"channel": channel, "arch": "amd64"}
    try:
        response = requests.get(GRAPH_URL, params=params)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"Error fetching graph: {e}")
        sys.exit(2)

def build_graph(data):
    nodes = [node["version"] for node in data["nodes"]]
    edges = data.get("edges", [])
    conditional_edges = data.get("conditionalEdges", [])

    graph = {}

    for e in edges:
        from_v = nodes[e[0]]
        to_v = nodes[e[1]]
        graph.setdefault(from_v, []).append((to_v, False, "No Risk", "No Message", "No URL"))

    for edge_group in conditional_edges:
        for edge in edge_group.get("edges", []):
            from_v = edge.get("from")
            to_v = edge.get("to")
            for risk in edge_group.get("risks", [{}]):
                risk_name = risk.get("name", "Unknown")
                risk_message = risk.get("message", "No message")
                risk_url = risk.get("url", "No URL")
                graph.setdefault(from_v, []).append((to_v, True, risk_name, risk_message, risk_url))

    return graph, nodes

def bfs_path(graph, from_v, to_v):
    visited = set()
    prev = {}
    edges_info = {}

    queue = deque([from_v])
    visited.add(from_v)

    while queue:
        current = queue.popleft()
        if current == to_v:
            break
        for neighbor, is_conditional, risk_name, risk_message, risk_url in sorted(graph.get(current, []), reverse=True, key=lambda v: list(map(int, v[0].split('.')))):
            if neighbor not in visited:
                visited.add(neighbor)
                prev[neighbor] = current
                edges_info.setdefault(neighbor, []).append((is_conditional, risk_name, risk_message, risk_url))
                queue.append(neighbor)
            elif prev.get(neighbor) == current:
                edges_info[neighbor].append((is_conditional, risk_name, risk_message, risk_url))

    if to_v not in prev and from_v != to_v:
        return None

    path = []
    v = to_v
    while v != from_v:
        path.append((v, edges_info.get(v, [])))
        v = prev.get(v)
        if v is None:
            return None
    path.append((from_v, []))
    path.reverse()
    return path


def calculate_and_show_path(graph, from_version, to_version, channel):
    import textwrap
    path = bfs_path(graph, from_version, to_version)
    if path:
        formatted_path = " -> ".join(v for v, _ in path)
        details = []
        for v, edges in path:
            for is_conditional, risk, msg, url in edges:
                if is_conditional:
                    wrapped_msg = '\n    '.join(textwrap.wrap(msg, width=65))
                    details.append(
                        f"Upgrade to Version: {v}\n\n"
                        f"  - Risk: {risk}\n"
                        f"  - Message: {wrapped_msg}\n"
                        f"  - URL: {url}\n"
                    )
        return f"Available path: {formatted_path}\n\n" + "\n".join(details) if details else f"Path: {formatted_path}"
    else:
        return f"No upgrade path found from {from_version} to {to_version} on channel {channel}"

def main():
    parser = argparse.ArgumentParser(description="Find upgrade paths between OpenShift versions.")
    parser.add_argument("--from-version", required=True, help="Starting OpenShift version (e.g., 4.16.1).")
    parser.add_argument("--to-version", required=True, help="Target OpenShift version (e.g., 4.18.14).")
    parser.add_argument("--channel", required=True, help="The OpenShift update channel (e.g., eus-4.18).")

    args = parser.parse_args()

    data = fetch_upgrade_graph(args.channel)
    graph, _ = build_graph(data)
    
    result = calculate_and_show_path(graph, args.from_version, args.to_version, args.channel)
    print(result)

if __name__ == "__main__":
    main()