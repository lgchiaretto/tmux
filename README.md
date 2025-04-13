# Tmux Configuration and Usage Guide

This repository contains a custom `.tmux.conf` configuration file and related scripts to enhance productivity using Tmux. This Tmux is optimized for use with `OpenShift` administration.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Key Shortcuts](#key-shortcuts)
  - [Global Prefix](#global-prefix)
  - [Window Management](#window-management)
  - [Pane Management](#pane-management)
  - [Sessions](#sessions)
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

- **Tmux** version 3.4 or higher
- **Vim** for file editing (optional)
- **Tmux Plugin Manager (TPM)** for plugin management
- **Git**
- **Python 3** and `tmuxp` for session management
- **fzf** for fuzzy searching
- **OpenShift CLI (`oc`)** for OpenShift integration

## Installation

Clone this repository and execute the `configure-local.sh` script to set up the environment:

```bash
./configure-local.sh [OPTIONS]
```

The `configure-local.sh` script now supports the following optional parameters:

- `--download-tmux`: Installs the Tmux binary in `/usr/local/bin`.
- `--download-oc`: Installs the OpenShift CLI (`oc`) in `/usr/local/bin`.

### Examples

1. To perform a full setup:
  ```bash
  ./configure-local.sh --download-tmux --download-oc
  ```

2. To download OpenShift CLI without downloading tmux:
  ```bash
  ./configure-local.sh --download-oc
  ```

3. To download Tmux without downloading OpenShift CLI:
  ```bash
  ./configure-local.sh --download-tmux
  ```

4. To not download Tmux and OpenShift CLI:
  ```bash
  ./configure-local.sh
  ```

Run `./configure-local.sh --help` for more details on available options.

This script will:
- Copy `.bashrc`, `.vimrc`, and `.tmux.conf` to your home directory.
- Copy additional Tmux configuration files from `fzf-files/` to `~/.tmux/`.
- Install the Tmux binary and OpenShift CLI (`oc`) in `/usr/local/bin`.
- Install `tmuxp` for session management.
- Copy predefined Tmux sessions to your home directory.

Alternatively, you can manually copy the `.tmux.conf` file:

```bash
cp dotfiles/tmux.conf ~/.tmux.conf
```

## Usage

- Start Tmux: Run `tmux` in the terminal.
- Detach from a session: `prefix + d`
- Reattach to an existing session: `tmux a`
- Reload configuration: `prefix + R`

## Key Shortcuts

The following keybindings are defined in the custom `.tmux.conf` file:

### Global Prefix

⚠️ The default Tmux prefix has been changed from `Ctrl + b` to `Ctrl + s`. All Tmux commands now use `Ctrl + s` as the prefix.

### Window Management

- Create a new window:`Ctrl + t` or `prefix + t`
- Switch between windows:`Shift + ←` or `Shift + →`
- Change window position: `Ctrl + Shift + ←` or `Ctrl + Shift + →`
- Rename window: Press `prefix + ,` and enter the new name.
- Window tree: `prefix + w` to see a navigable window tree.
- Kill current window: ` prefix + k`

### Pane Management

- Horizontal split: `Ctrl + |` or `prefix + \`
- Vertical split: `prefix + -`
- Navigate between panes: Ctrl + ←, →, ↑, ↓
- Resize pane: Alt + Shift + ←, →, ↑, ↓
- Move pane positions: Alt + ↑, ↓
- Sync all panes: `prefix + a` (toggles synchronization on/off)
- Move pane to a new window: `prefix + m`

### Sessions

- Create a new session: `prefix + N` (prompts for a session name)
- Rename session: Press `prefix + .` and enter the new name.
- Select session: `prefix + s`
- Choose buffer to paste from: `prefix + b`
    - **TIP**: Use `fzf` to search for strings within the Tmux buffer. Type search terms to initiate a fuzzy search on all buffers
- Kill session: `prefix + K` (with confirmation prompt)
- Kill all sessions: `prefix + D` (with confirmation prompt)

## Additional Keybindings

- Reverse search in tmux pane/window: Press `prefix + /` to open search mode, then type search terms.
- Edit .tmux.conf: `prefix + e`
- Reload tmux configuration: `prefix + R`

### Clipboard and Search

- Copy selection: Use the mouse to select text.
- Copy a selection to be pasted outside tmux (i.e., a browser): use the mouse to select text while pressing `Shift` and press `right-click` mouse button.
- Paste from clipboard: `Ctrl + v`
- Paste a text copied outside of tmux (i.e., a browser): `Ctrl + Shift + v`
- Search backward in copy mode: `prefix + /`

### Fuzzy Search Utilities

- Open a file or directory (`locate` service must be running): `Ctrl + x`
- Search and open URLs (with http(s):// or not) in a pane:
  - Open: `prefix + u`
  - Copy: `prefix + y`

### OpenShift utilities:

 - Select and change to OpenShift context (project): `prefix + c`
 - View pod logs: `prefix + l`
 - Select and paste a node name: `prefix + n`
 - Select and paste a cluster operator: `prefix + o`
 - Select and paste an OpenShift API resource available in the cluster: `Ctrl + o`
 - Select and paste a pod name: `prefix + p`
 - Select and paste a project name: `prefix + P`
 - Select and open a route: `prefix + r`

## Additional Features

- **Mouse Support**: Enables mouse interaction for pane resizing, window switching, and scrolling.
- **Clipboard Integration**: Automatically copies selected text to the system clipboard.
- **Enhanced History**: Increases the scrollback buffer to 50,000 lines.
- **256-Color Support**: Improves theme visualization.
- **Custom Status Bar**: Displays session, cluster, and system information.

## Predefined Sessions

The `tmux-sessions` directory contains predefined session configurations for `tmuxp`. To load a session, run:

```bash
tmuxp load <session-name-file>
```

### Available Sessions

- **INSTALL**: For monitoring OpenShift installation.
- **UPGRADE**: For monitoring OpenShift upgrades.

## Plugins

This configuration includes the following plugins:

- `tmux-battery`: Displays battery status.
- `tmux-better-mouse-mode`: Enhances mouse support.
- `tmux-temp`: Displays CPU temperature.

To install plugins, open Tmux and press `prefix + I`.

---

For more details, refer to the `.tmux.conf` file or the scripts in the `fzf-files/` directory.