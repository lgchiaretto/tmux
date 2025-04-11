# Tmux Configuration

This repository contains a custom `.tmux.conf` configuration file and related scripts to enhance productivity while using Tmux.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Executing](#executing)
- [Key Shortcuts](#key-shortcuts)
- [Additional Features](#additional-features)

---

## Requirements

- **Tmux** version 3.4 or higher
- **Vim** for file editing (optional)
- **Tmux Plugin Manager (TPM)** for plugin management
- **Git**
- **Python 3** and `tmuxp` for session management

## Installation

Clone this repository and execute the `configure-local.sh` script to set up the environment:

```bash
./configure-local.sh
```

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

## Executing

- Start Tmux: Run `tmux` in the terminal.
- Detach from a session: `prefix + d`
- Reattach to an existing session: `tmux a`

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
  - Join pane in a window: `prefix + p` and select the pane to join in a window

### Sessions

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

- **Mouse Support**: Enables mouse interaction for pane resizing, window switching, and scrolling.
- **Clipboard Integration**: Automatically copies selected text to the system clipboard.
- **Enhanced History**: Increases the scrollback buffer to 50,000 lines.
- **256-Color Support**: Improves theme visualization.
- **Plugins**:
  - `tmux-open`: Opens URLs directly in the browser.
  - `tmux-better-mouse-mode`: Enhances mouse support.
  - `tmux-temp`: Displays CPU temperature.

To install plugins, open Tmux, clone the `tmux-plugins` repo and press `prefix + I`.

1. Clone the TPM repository:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```
2. Open Tmux and press `prefix + I` to install the plugins.

## Predefined Sessions

The `tmux-sessions` directory contains predefined session configurations for `tmuxp`. To load a session, run:

```bash
tmuxp load <session-name>
```

## Additional Notes

- The `configure-local.sh` script downloads the Tmux binary and OpenShift CLI (`oc`) for convenience.
- Ensure you have `sudo` privileges to execute the script.

---