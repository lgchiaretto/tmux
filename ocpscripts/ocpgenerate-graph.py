#!/usr/bin/env python3

import os
import json
import requests
import argparse
import textwrap
from collections import defaultdict
from time import time
import heapq

GRAPH_URL = "https://api.openshift.com/api/upgrades_info/graph"
CACHE_DIR = "/home/lchiaret/.cache/ocpgraph"
CACHE_TTL_SECONDS = 24 * 3600

CHANNELS = [
    "stable-4.12", "stable-4.13", "stable-4.14",
    "stable-4.15", "stable-4.16", "stable-4.17", "stable-4.18"
]

def fetch_graph(channel, refresh=False):
    os.makedirs(CACHE_DIR, exist_ok=True)
    cache_file = os.path.join(CACHE_DIR, f"{channel}.json")
    if not refresh and os.path.exists(cache_file):
        if time() - os.path.getmtime(cache_file) < CACHE_TTL_SECONDS:
            with open(cache_file) as f:
                return json.load(f)
    print(f"Fetching graph for {channel}...")
    resp = requests.get(GRAPH_URL, params={"channel": channel, "arch": "amd64"}, timeout=10)
    resp.raise_for_status()
    data = resp.json()
    with open(cache_file, "w") as f:
        json.dump(data, f)
    return data

def parse_version(version):
    return tuple(map(int, version.split(".")))

def build_supergraph(channels, refresh=False):
    temp_edges_info = defaultdict(lambda: {'is_conditional': False, 'risks': []})
    version_to_nodes = defaultdict(list)

    for channel in CHANNELS:
        data = fetch_graph(channel, refresh)
        nodes = data["nodes"]
        index_to_version = {i: node["version"] for i, node in enumerate(nodes)}

        for i, version_str in index_to_version.items():
            channel_node = f"{channel}:{version_str}"
            if channel_node not in version_to_nodes[version_str]:
                version_to_nodes[version_str].append(channel_node)

        for e in data.get("edges", []):
            f_version = index_to_version[e[0]]
            t_version = index_to_version[e[1]]
            from_node = f"{channel}:{f_version}"
            to_node = f"{channel}:{t_version}"
            if (from_node, to_node) not in temp_edges_info:
                temp_edges_info[(from_node, to_node)] = {'is_conditional': False, 'risks': []}

        for group in data.get("conditionalEdges", []):
            group_risks_raw = group.get("risks", [])
            processed_risks = []
            for risk_dict in group_risks_raw:
                name = risk_dict.get("name", "Unknown")
                msg = risk_dict.get("message", "No message")
                url = risk_dict.get("url", "No URL")
                processed_risks.append((name, msg, url))

            for e in group.get("edges", []):
                f_version = e["from"]
                t_version = e["to"]
                from_node = f"{channel}:{f_version}"
                to_node = f"{channel}:{t_version}"
                temp_edges_info[(from_node, to_node)]['is_conditional'] = True
                temp_edges_info[(from_node, to_node)]['risks'].extend(processed_risks)
                
    final_graph = defaultdict(list)
    for (from_node, to_node), info in temp_edges_info.items():
        unique_risks = []
        seen_risks = set()
        for risk_tuple in info['risks']:
            if risk_tuple not in seen_risks:
                unique_risks.append(risk_tuple)
                seen_risks.add(risk_tuple)
        if not info['is_conditional'] and not unique_risks:
            unique_risks.append(("No Risk", "No message", "No URL"))
        final_graph[from_node].append((to_node, info['is_conditional'], unique_risks))

    for version_str, nodes_list in version_to_nodes.items():
        unique_nodes_for_version = list(set(nodes_list))
        for i in range(len(unique_nodes_for_version)):
            for j in range(i + 1, len(unique_nodes_for_version)):
                node1 = unique_nodes_for_version[i]
                node2 = unique_nodes_for_version[j]
                if (node1, node2) not in temp_edges_info and (node2, node1) not in temp_edges_info:
                    final_graph[node1].append((node2, False, [("Channel Link", "Upgrade between equivalent versions in different channels.", "")]))
                    final_graph[node2].append((node1, False, [("Channel Link", "Upgrade between equivalent versions in different channels.", "")]))

    return final_graph, version_to_nodes


def best_path(graph, start_nodes, target_versions, version_to_nodes):
    visited = set()
    prev = {}
    edge_info = defaultdict(list)
    heap = []

    for node in start_nodes:
        version_tuple = parse_version(node.split(":")[1])
        heapq.heappush(heap, (tuple(-x for x in version_tuple), node))
        prev[node] = None

    target_nodes = set()
    for v in target_versions:
        target_nodes.update(version_to_nodes.get(v, []))

    while heap:
        _, current = heapq.heappop(heap)
        if current in visited:
            continue
        visited.add(current)

        if current in target_nodes:
            path = []
            temp_current = current
            while temp_current:
                path.append((temp_current, edge_info.get(temp_current, [])))
                temp_current = prev.get(temp_current)
            return path[::-1]

        for neighbor, is_cond, risks_list in graph.get(current, []):
            if neighbor not in visited:
                prev[neighbor] = current
                version_tuple = parse_version(neighbor.split(":")[1])
                heapq.heappush(heap, (tuple(-x for x in version_tuple), neighbor))
                edge_info[neighbor].extend([(is_cond, r[0], r[1], r[2]) for r in risks_list])
    return None

def resolve_start_nodes(version, version_to_nodes):
    return version_to_nodes.get(version, [])

def format_path(path):
    if not path:
        return "No upgrade path found."

    cleaned_path_nodes = []
    seen_versions_in_path = set()
    for node, _ in path:
        version_only = node.split(":")[1]
        if version_only not in seen_versions_in_path:
            cleaned_path_nodes.append(version_only)
            seen_versions_in_path.add(version_only)
    
    steps = " -> ".join(cleaned_path_nodes)
    
    detail = []
    for i in range(len(path)):
        current_node_with_channel, incoming_edge_infos = path[i]
        current_version_only = current_node_with_channel.split(":")[1]

        if i > 0:
            prev_node_with_channel = path[i-1][0]
            prev_version_only = prev_node_with_channel.split(":")[1]

            actual_risks = [
                (risk, msg, url) for is_cond, risk, msg, url in incoming_edge_infos
                if is_cond and risk not in ("No Risk", "Channel Link")
            ]
            
            is_channel_link_only = all(r[0] == "Channel Link" for is_cond, r, msg, url in incoming_edge_infos) and len(incoming_edge_infos) > 0

            if prev_version_only != current_version_only:
                if actual_risks:
                    detail.append(f"Upgrade from {prev_version_only} to {current_version_only} (via {current_node_with_channel}):\n")
                    for risk, msg, url in actual_risks:
                        wrapped_msg = "\n    ".join(textwrap.wrap(msg, width=55))
                        detail.append(
                            f"  - Risk: {risk}\n"
                            f"    Message: {wrapped_msg}\n"
                            f"    URL: {url}\n"
                        )
            elif is_channel_link_only and prev_version_only == current_version_only:
                if prev_node_with_channel.split(":")[0] != current_node_with_channel.split(":")[0]:
                    detail.append(f"Channel hop from {prev_node_with_channel.split(':')[0]} to {current_node_with_channel.split(':')[0]} (version {current_version_only}):")
                    for is_cond, link_name, link_msg, link_url in incoming_edge_infos:
                        if link_name == "Channel Link":
                            wrapped_msg = "\n    ".join(textwrap.wrap(link_msg, width=65))
                            detail.append(f"  - {link_name}: {wrapped_msg}")

    wrapped_steps = "\n".join(textwrap.wrap(steps, width=75))
    return f"Path:\n{wrapped_steps}\n\n" + ("\n".join(detail) if detail else "No specific conditional risks found for this path.")

def main():
    parser = argparse.ArgumentParser(description="Find OpenShift upgrade path")
    parser.add_argument("--from-version")
    parser.add_argument("--to-version")
    parser.add_argument("--refresh-cache", action="store_true")
    args = parser.parse_args()

    os.makedirs(CACHE_DIR, exist_ok=True)

    if args.refresh_cache and (not args.from_version or not args.to_version):
        print("Refreshing cache...")
        for channel in CHANNELS:
           fetch_graph(channel, refresh=True)
        print("Cache has been recreated...")
        exit(0)

    graph, version_to_nodes = build_supergraph(CHANNELS, refresh=args.refresh_cache)
    start_nodes = resolve_start_nodes(args.from_version, version_to_nodes)

    if not start_nodes:
        print(f"Starting version {args.from_version} not found in any channel.")
        return

    path = best_path(graph, start_nodes, [args.to_version], version_to_nodes)
    print(format_path(path))

if __name__ == "__main__":
    main()