# Tmux Configuration and Usage Guide

This repository contains a custom `.tmux.conf` configuration file and related scripts to enhance productivity using Tmux. This configuration is optimized for `OpenShift` administration.

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [Examples](#examples)
- [Usage](#usage)
- [Key Shortcuts](#key-shortcuts)
  - [Global Prefix](#global-prefix)
  - [Sessions](#sessions)
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

## Usage

- **Start Tmux**: Run `tmux` in the terminal.
- **Detach from a session**: `prefix + d`
- **Reattach to an existing session**: `tmux a`
- **Reload configuration**: `prefix + R`

---

## Key Shortcuts

The following keybindings are defined in the custom `.tmux.conf` file:

### Global Prefix

⚠️ The default Tmux prefix has been changed from `Ctrl + b` to `Ctrl + s`. All Tmux commands now use `Ctrl + s` as the prefix.

---

---

### Sessions

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

---

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

- **Copy selection**: Use the mouse to select text.
- **Copy selection to paste outside Tmux**: Use the mouse to select text while pressing `Shift`, then right-click.
- **Paste from clipboard**: `Ctrl + v`
- **Paste text copied outside Tmux**: `Ctrl + Shift + v`
- **Search backward in copy mode**: `prefix + /`
- **Copy entire window buffer to system clipboard**: `Ctrl + Shift + y`

---

### Fuzzy Search Utilities

- **Open a file or directory** (requires `locate` service): `Ctrl + x`
- **Search and print or open URLs/IPs**: `prefix + TAB`

---

### OpenShift Utilities

- **Select and change OpenShift context (project)**: `prefix + c`
- **View pod logs in the current project**: `prefix + l`
- **View pod logs in all projects**: `prefix + L`
- **Select and paste a node name**: `prefix + n`
- **Select and paste a cluster operator**: `prefix + O`
- **Select and paste an OpenShift API resource**: `prefix + o`
- **Select and paste a pod name**: `prefix + p`
- **Select and paste a project name**: `prefix + P`
- **Select and open a route**: `prefix + r`

---

## Additional Features

- **Mouse Support**: Enables mouse interaction for pane resizing, window switching, and scrolling.
- **Clipboard Integration**: Automatically copies selected text to the system clipboard.
- **Enhanced History**: Increases the scrollback buffer to 50,000 lines.
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