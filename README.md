# Tmux Configuration and Usage Guide

This repository contains a custom `.tmux.conf` configuration file and related scripts to enhance productivity using Tmux. This configuration is optimized for `OpenShift` administration.

---

## Table of Contents

- [Tmux Configuration and Usage Guide](#tmux-configuration-and-usage-guide)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Installation](#installation)
    - [Supported Options](#supported-options)
    - [Examples](#examples)
    - [What the Script Does](#what-the-script-does)
      - [Manual Setup](#manual-setup)
    - [Global Prefix](#global-prefix)
  - [Usage](#usage)
  - [Key Shortcuts](#key-shortcuts)
    - [Sessions Management](#sessions-management)
    - [Window Management](#window-management)
    - [Pane Management](#pane-management)
    - [Additional Keybindings](#additional-keybindings)
    - [Clipboard and Search](#clipboard-and-search)
    - [Fuzzy Search Utilities](#fuzzy-search-utilities)
    - [OpenShift Utilities](#openshift-utilities)
  - [Additional Features](#additional-features)
  - [Predefined Sessions](#predefined-sessions)
    - [Available Sessions](#available-sessions)
  - [Plugins](#plugins)

---

## Requirements

To use this configuration, ensure the following dependencies are installed:

- **Tmux** version 3.4 or higher
- **Vim** (optional, for file editing)
- **Tmux Plugin Manager (TPM)** for plugin management
- **Git**
- **Python 3** and `tmuxp` for session management
- **fzf** for fuzzy searching
- **OpenShift CLI (`oc`)** for OpenShift integration

---

## Installation

Clone this repository and execute the `configure-local.sh` script to set up the environment:

```bash
./configure-local.sh [OPTIONS]
```

### Supported Options

- `--download-tmux`: Installs the Tmux binary in `/usr/local/bin`.
- `--download-oc`: Installs the OpenShift CLI (`oc`) in `/usr/local/bin`.

### Examples

1. To perform a full setup:
   ```bash
   ./configure-local.sh --download-tmux --download-oc
   ```

2. To download only the OpenShift CLI:
   ```bash
   ./configure-local.sh --download-oc
   ```

3. To download only Tmux:
   ```bash
   ./configure-local.sh --download-tmux
   ```

4. To skip downloading both Tmux and OpenShift CLI:
   ```bash
   ./configure-local.sh
   ```

Run `./configure-local.sh --help` for more details on available options.

### What the Script Does

- Copies `.bashrc`, `.vimrc`, and `.tmux.conf` to your home directory.
- Copies additional Tmux configuration files from `fzf-files/` to `~/.tmux/`.
- Installs the Tmux binary and OpenShift CLI (`oc`) in `/usr/local/bin`.
- Installs `tmuxp` for session management.
- Copies predefined Tmux sessions to your home directory.

#### Manual Setup

Alternatively, you can manually copy the `.tmux.conf` file:

```bash
cp dotfiles/tmux.conf ~/.tmux.conf
```
---

### Global Prefix

⚠️ The default Tmux prefix has been changed from `Ctrl + b` to `Ctrl + s`. All Tmux commands now use `Ctrl + s` as the prefix.

---

## Usage

- **Start Tmux**: Run `tmux` in the terminal.
- **Detach from a session**: `prefix + d`
- **Reattach to an existing session**: `tmux a`
- **Reload configuration**: `prefix + R`

---

## Key Shortcuts

The following keybindings are defined in the custom `.tmux.conf` file:

---

### Sessions Management

- **Create a new session**: `prefix + N` (prompts for a session name)
- **Rename session**: Press `prefix + .` and enter the new name.
- **Select session**: `prefix + s`
- **Choose buffer to paste from**: `prefix + b`
  - **TIP**: Use `fzf` to search for strings within the Tmux buffer. Type search terms to initiate a fuzzy search on all buffers.
- **Kill session**: `prefix + K` (with confirmation prompt)
- **Kill all sessions**: `prefix + D` (with confirmation prompt)

### Window Management

- **Create a new window**: `Ctrl + t` or `prefix + t`
- **Switch between windows**: `Shift + ←` or `Shift + →`
- **Change window position**: `Ctrl + Shift + ←` or `Ctrl + Shift + →`
- **Rename window**: Press `prefix + ,` and enter the new name.
- **Window tree**: `prefix + w` to see a navigable window tree.
- **Kill current window**: `prefix + k`


### Pane Management

- **Horizontal split**: `Ctrl + |` or `prefix + \`
- **Vertical split**: `prefix + -`
- **Navigate between panes**: `Ctrl + ←`, `→`, `↑`, `↓`
- **Resize pane**: `Alt + Shift + ←`, `→`, `↑`, `↓`
- **Move pane positions**: `Alt + ↑`, `↓`
- **Sync all panes**: `prefix + a` (toggles synchronization on/off)
- **Move pane to a new window**: `prefix + m`

---

### Additional Keybindings

- **Reverse search in Tmux pane/window**: Press `prefix + /` to open search mode, then type search terms.
- **Edit `.tmux.conf`**: `prefix + e`
- **Reload Tmux configuration**: `prefix + R`

---

### Clipboard and Search

- **Copy selection**: 
  Use the mouse to select text within a Tmux pane. This copies the selected text to Tmux's internal clipboard.
- **Copy selection to paste outside Tmux**: 
  Use the mouse to select text while pressing `Shift`, then right-click to copy the text to the system clipboard for use outside Tmux.
- **Paste from clipboard**: `Ctrl + v`
  Paste text from the Tmux clipboard into the current pane.
- **Paste text copied outside Tmux**: `Ctrl + Shift + v` 
  Paste text from the system clipboard into the current Tmux pane.
- **Search backward in copy mode**: `prefix + /` to enter copy mode and search backward through the pane's scrollback buffer for a specific term.
- **Copy entire window buffer to system clipboard**: `Ctrl + Shift + y`
  Copy all the text in the current Tmux window's buffer to the system clipboard.

---

### Fuzzy Search Utilities

- **Open a file or directory** (requires `locate` service): `Ctrl + x`  
  This allows you to quickly open a file or directory by searching for it's name. The `locate` service is used to index and find files efficiently, so ensure it is installed and running on your system.

- **Search and print or open URLs/IPs**: `prefix + TAB`  
  This feature scans for URLs or IP addresses in the current context. You can either print them to the output or open them directly. The `prefix` key is a custom shortcut you define, followed by pressing `TAB` to trigger the action.

---
### OpenShift Utilities

This configuration includes several keybindings specifically designed to simplify OpenShift administration tasks. These bindings leverage `fzf` for efficient fuzzy searching and selection, enabling quick access to OpenShift resources. Below is a detailed explanation of the available keybindings and their functionality:

- **Select and change OpenShift context (project)**: `prefix + c`  
  Opens a list of available OpenShift projects. Use the arrow keys or type to search and select a project. The selected project becomes the active context. It's useful when you are working in more than one cluster simultaneously.

- **View pod logs in the current project**: `prefix + l`  
  Displays logs for pods in the current OpenShift project. Navigate through the logs using the keyboard or search for specific entries.

- **View pod logs in all projects**: `prefix + L`  
  Retrieves logs from pods across all OpenShift projects. Useful for cross-project debugging.

- **Select and paste a node name**: `prefix + n`  
  Opens a list of nodes in the OpenShift cluster. Select a node to copy its name to the clipboard or paste it directly into the terminal. After selecting a node, you can:
  - **Describe the node**: Press `Ctrl + d` to execute `oc describe node <node-name>`.
  - **Select the node name**: Press `Enter`

- **Select and paste a cluster operator**: `prefix + O`  
  Lists all cluster operators. Select one to copy its name or paste it into the terminal for further operations. After selecting an operator, you can:
  - **Describe the operator**: Press `Ctrl + d` to execute `oc describe co <operator-name>`.

- **Select and paste an OpenShift API resource**: `prefix + o`  
  Displays a list of API resources available in the OpenShift cluster. Select a resource to copy its name or paste it into the terminal. After selecting an api-resource, you can:
  - **Select the api-resource name**: Press `Enter`

- **Select and paste a pod name**: `prefix + p`  
  Lists all pods in the current project. Select a pod to copy its name or paste it into the terminal for quick access. After selecting a pod, you can:
  - **Describe the pod**: Press `Ctrl + d` to execute `oc describe pod <pod-name>`.
  - **Edit the pod**: Press `Ctrl + e` to execute `oc edit pod <pod-name>`.
  - **View pod logs**: Press `Ctrl + l` to execute `oc logs <pod-name>`.
  - **Select the pod name**: Press `Enter`

- **Select and paste a project name**: `prefix + P`  
  Opens a list of all OpenShift projects. Select a project to copy its name or paste it into the terminal.
  After selecting a project, you can:
  - **Switch to the project**: Press `Ctrl + p` to execute `oc project <project-name>`.
  - **Select the project name**: Press `Enter`

- **Select and open a route**: `prefix + r`  
  Lists all routes in the current project. Select a route to open it in the default web browser or copy its URL for sharing. After selecting a route, you can:
  - **Open the route in a browser**: Press `Ctrl + o` to open the route URL in the default web browser.
  - **Copy the route URL**: Press `Ctrl + c` to copy the route URL to the clipboard.
  - **Select the route name**: Press `Enter`

---

## Additional Features

- **Mouse Support**: Enables mouse interaction for pane resizing, window switching, and scrolling.
- **Clipboard Integration**: Automatically copies selected text to the system clipboard.
- **Enhanced History**: Increases the scrollback buffer to 1.000.000 lines.
- **256-Color Support**: Improves theme visualization.
- **Custom Status Bar**: Displays session, cluster, and system information.

---

## Predefined Sessions

The `tmux-sessions` directory contains predefined session configurations for `tmuxp`. To load a session, run:

```bash
tmuxp load <session-name-file>
```

### Available Sessions

- **INSTALL**: For monitoring OpenShift installation.
- **UPGRADE**: For monitoring OpenShift upgrades.

---

## Plugins

This configuration includes the following plugins:

- `tmux-battery`: Displays battery status.
- `tmux-better-mouse-mode`: Enhances mouse support.
- `tmux-temp`: Displays CPU temperature.

To install plugins, open Tmux and press `prefix + I`.

---

For more details, refer to the `.tmux.conf` file or the scripts in the `fzf-files/` directory.