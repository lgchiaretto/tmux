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
            risk_name = edge_group.get("risks", [{}])[0].get("name")
            risk_message = edge_group.get("risks", [{}])[0].get("message")
            risk_url = edge_group.get("risks", [{}])[0].get("url")
            graph.setdefault(from_v, []).append((to_v, True, risk_name, risk_message, risk_url))

    return graph, nodes

def bfs_path(graph, from_v, to_v):
    visited = set()
    prev = {}
    edge_type = {}
    risks = {}
    messages = {}
    urls = {}
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
                edge_type[neighbor] = is_conditional
                risks[neighbor] = risk_name
                messages[neighbor] = risk_message
                urls[neighbor] = risk_url
                queue.append(neighbor)

    if to_v not in prev and from_v != to_v:
        return None

    path = []
    v = to_v
    while v != from_v:
        path.append((v, edge_type.get(v, False), risks.get(v, "No Risk"), messages.get(v, "No Message"), urls.get(v, "No URL")))
        v = prev.get(v)
        if v is None:
            return None
    path.append((from_v, False, "No Risk", "No Message", "No URL"))
    path.reverse()
    return path

def calculate_and_show_path(graph, from_version, to_version, channel):
    path = bfs_path(graph, from_version, to_version)
    if path:
        formatted_path = " -> ".join(f"{v}" for v, _, _, _, _ in path)
        import textwrap
        detailed_info = "\n\n".join(
            f"Version: {v}\n\n  - Risk: {risk}\n  - Message: {'\n    '.join(textwrap.wrap(message, width=70))}\n  - URL: {url}"
            for v, is_conditional, risk, message, url in path if is_conditional
        )
        return f"Available path: {formatted_path}\n\n{detailed_info}" if detailed_info else f"Path: {formatted_path}"
    else:
        return f"No upgrade path found from {from_version} to {to_version} on channel {channel}"

def generate_preview(versions, from_version, channel):
    preview_lines = []
    # data = fetch_upgrade_graph(channel)
    # graph, _ = build_graph(data)
    for to_version in versions:
        # preview_lines.append(calculate_and_show_path(graph, from_version, to_version, channel))
        preview_lines.append(f"Path from {from_version} to {to_version} will be displayed here")
    return "\n---\n".join(preview_lines)

def main():
    parser = argparse.ArgumentParser(description="Find upgrade paths between OpenShift versions.")
    parser.add_argument("--from-version", required=True, help="Starting OpenShift version.")
    parser.add_argument("--to-version", required=True, help="Target OpenShift version.")
    parser.add_argument("--channel", required=True, help="The OpenShift update channel (e.g., stable-4.14).")

    args = parser.parse_args()

    data = fetch_upgrade_graph(args.channel)
    graph, _ = build_graph(data)
    
    result = calculate_and_show_path(graph, args.from_version, args.to_version, args.channel)
    print(result)

if __name__ == "__main__":
    main()