# Tmux Configuration

This repository contains a custom `.tmux.conf` configuration file to improve productivity while using Tmux

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Executing](#executing)
- [Key Shortcuts](#key-shortcuts)
- [Additional Features](#additional-features)

---

## Requirements

- **Tmux** version 3.4
- **Vim** for file editing (optional).
- **Tmux Plugin Manager (TPM)** for plugin management
- **Git**


## Installation

  Clone this repository, execute configure-local.sh script or copy the .tmux.conf file to your home directory:

  ```
  ./configure-local.sh
  ```
  
  or 

  ```
    cp .tmux.conf ~/.tmux.conf
  ```

## Executing

- Run `tmux` on terminal
- Dettach tmux: `prefix + d`
- Attach an existing tmux session run `tmux a` on terminal 

## Key Shortcuts

#### Global Prefix

⚠️ The default Tmux prefix has been changed from `Ctrl + b` to `Ctrl + s`. This means that any Tmux command that typically requires `Ctrl + b` now uses `Ctrl + s` instead.

#### Window Management

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
  - Join pane in a window: `prefix + p` and select the pane to join in a window

### Sessions and Navigation

  - Create a new session: `prefix + n` (prompts for a session name)
  - Rename session: Press `prefix + .` and enter the new name.
  - Select session: `prefix + s`
  - Choose buffer to paste from: `prefix + b`
  - Reverse search terminal history: Press `prefix + /` to open search mode, then type search terms.
  - Reload tmux configuration: `prefix + r`
  - Edit .tmux.conf: `prefix + e`
  - Kill session: `prefix + K` (with confirmation prompt)
  - Kill all sessions: `prefix + D` (with confirmation prompt)

## Additional Keybindings

  - Quick copy with mouse: Enables direct copy to clipboard upon selection.
  - Paste from clipboard: `C-v`

## Additional Features

- Mouse support: Navigate and select using the mouse.
- Copy to clipboard automatically on mouse selection.
- 256-color support for better theme visualization.
- Extended history limit of 10,000 lines.
- Plugins:
  - tmux-open: Opens URLs directly in the browser.
  - tmux-better-mouse-mode: Enhanced mouse support.
  - tmux-temp: Displays CPU temperature.

To install plugins, open Tmux, clone the `tmux-plugins` repo and press `prefix + I`.

  ```
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ```

