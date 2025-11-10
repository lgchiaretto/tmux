# Tmux Configuration & OpenShift Tools

This repository contains a custom tmux configuration integrated with FZF interactive menus and OpenShift cluster management tools. It provides a complete control plane for Red Hat OpenShift administrators with shell configuration, interactive resource browsers, cluster lifecycle automation, and real-time status monitoring.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Executing](#executing)
- [Key Shortcuts](#key-shortcuts)
- [OpenShift Integration](#openshift-integration)
- [FZF Interactive Menus](#fzf-interactive-menus)
- [Additional Features](#additional-features)

---

## Requirements

- **Tmux** version 3.4 or higher
- **FZF** for interactive fuzzy finding
- **OpenShift CLI (oc)** for cluster management
- **Vim** for file editing
- **Git**
- **Python 3** with tmuxp package (`pip3 install tmuxp`)
- **bat** for syntax highlighting (optional)
- **VMware govc** for VM operations (optional)

## Installation

Clone this repository and execute the `configure-local.sh` script to set up the complete environment:

```bash
./configure-local.sh
```

This will:
- Install FZF and its dependencies
- Download and install tmux binary
- Install OpenShift CLI (oc)
- Copy dotfiles to your home directory (~/)
- Install FZF scripts to `~/.tmux/`
- Copy tmux session templates to `~/tmux-sessions/`
- Configure bash with Gruvbox color scheme and OpenShift helpers

Or manually copy configuration files:

```bash
cp dotfiles/tmux.conf ~/.tmux.conf
cp dotfiles/bashrc ~/.bashrc
cp dotfiles/vimrc ~/.vimrc
cp -r fzf-files ~/.tmux/
cp -r tmux-sessions ~/tmux-sessions/
```

### Configuration

After installation, you can customize the base paths used by the OpenShift cluster management tools.

**During Installation:**

The `configure-local.sh` script will prompt you to customize the cluster path and domain during installation. If you skip this step, the defaults will be used.

**After Installation:**

Edit the configuration file at any time:

```bash
vim ~/.tmux/config.sh
```

**Available Configuration Options:**

- `CLUSTERS_BASE_PATH`: Base directory where OpenShift clusters are stored (default: `/vms/clusters`)
- `OCP_CACHE_DIR`: Cache directory for OCP clients and other cached data (default: `${CLUSTERS_BASE_PATH}/.cache`)
- `CLUSTER_VARIABLES_DIR`: Directory for cluster template files (default: `${CLUSTERS_BASE_PATH}/variables-files`)
- `REMOTE_BASTION_HOST`: Remote host for cluster state synchronization (optional)
- `DEFAULT_BASE_DOMAIN`: Default base domain for clusters (default: `chiarettolabs.com.br`)
- `ANSIBLE_PLAYBOOK_KVM_PATH`: Path to Ansible playbook directory for cluster management

**Example:**

```bash
export CLUSTERS_BASE_PATH="/data/openshift/clusters"
export DEFAULT_BASE_DOMAIN="mycompany.com"
```

The configuration is automatically loaded by:
- `bash_functions` when you start a new shell
- All FZF scripts in `fzf-files/`
- All OCP management scripts in `ocpscripts/`

**Note:** The scripts will look for the configuration file in the following order:
1. `$HOME/git/tmux/config.sh` (development location)
2. `$HOME/.tmux/config.sh` (installed location)
3. `/usr/local/etc/tmux-ocp/config.sh` (system-wide location)

For detailed configuration information, see [CONFIGURATION.md](CONFIGURATION.md).

## Executing

- Run `tmux` in your terminal
- Detach tmux: `prefix + d`
- Attach an existing tmux session: `tmux a`

## Key Shortcuts

#### Global Prefix

⚠️ **The default Tmux prefix has been changed from `Ctrl + b` to `Ctrl + s`.** All Tmux commands now use `Ctrl + s` as the prefix.

- Switch to last session (when not in vim): `Ctrl + b`

#### Session Management

- **Create new session**: `prefix + N` (prompts for session name)
- **Rename session**: `prefix + .` (prompts for new name)
- **Select session**: `prefix + s` (opens session selector)
- **Choose tree**: `prefix + w` (opens window/session tree in zoom mode)
- **Double-click status left**: Opens choose-tree view
- **Kill current session**: `prefix + K` (with confirmation; handles last session gracefully)
- **Kill all sessions**: `prefix + D` (with confirmation prompt)

#### Window Management

- **Create new window**: `Ctrl + t` (in current path)
- **Next window**: `Shift + →`
- **Previous window**: `Shift + ←`
- **Swap window left**: `Ctrl + Shift + ←` (swaps and selects)
- **Swap window right**: `Ctrl + Shift + →` (swaps and selects)
- **Rename window**: `prefix + ,` (prompts for new name)
- **Kill current window**: `prefix + k` (with confirmation)
- **Click status bar window**: Select that window
- **Click status bar [+]**: Create new window in current path

#### Pane Management

- **Horizontal split**: `Ctrl + \` or `prefix + \` (in current path)
- **Vertical split**: `prefix + -` (in current path)
- **Move left**: `Ctrl + ←`
- **Move right**: `Ctrl + →`
- **Move up**: `Ctrl + ↑`
- **Move down**: `Ctrl + ↓`
- **Resize left**: `Alt + Shift + ←`
- **Resize right**: `Alt + Shift + →`
- **Resize up**: `Alt + Shift + ↑`
- **Resize down**: `Alt + Shift + ↓`
- **Swap pane up**: `Alt + ↑`
- **Swap pane down**: `Alt + ↓`
- **Synchronize panes**: `prefix + a` (toggle sync across all panes)

#### Copy Mode & Navigation

- **Enter copy mode & search**: `prefix + /` (starts backward search)
- **Page down**: `Ctrl + f` (in copy mode)
- **Page up**: `Ctrl + b` (in copy mode)
- **Vi mode keys**: Enabled in copy mode and status

#### Clipboard & Mouse

- **Paste from clipboard**: `Ctrl + v`
- **Middle-click paste**: Mouse button 2 (pastes from system clipboard)
- **Copy on selection**: Automatic copy to clipboard when selecting with mouse
- **Copy entire window buffer**: `Ctrl + Shift + y` (copies to clipboard)
- **Choose buffer**: `prefix + b` (shows buffer list or "Buffer is empty" message)

#### Configuration

- **Reload config**: `prefix + R` (displays "tmux.conf reloaded." message)
- **Edit config**: `prefix + e` (opens ~/.tmux.conf in vim)

#### OpenShift/Kubernetes Resources (FZF Integration)

- **Context selector**: `prefix + c` (select k8s context)
- **Pod logs (selected)**: `prefix + l` (logs for selected pods)
- **Pod logs (all)**: `prefix + L` (logs for all pods across namespaces)
- **Nodes browser**: `prefix + n` (browse and manage nodes)
- **Operators browser**: `prefix + O` (browse cluster operators)
- **API resources**: `prefix + o` (browse OCP api-resources)
- **Pods browser**: `prefix + p` (browse pods with actions)
- **Projects/Namespaces**: `prefix + P` (select and switch projects)
- **Routes browser**: `prefix + r` (search and open routes)
- **VMware usage**: `prefix + V` (view VMware resource usage)
- **OCP versions**: `prefix + C` (select OCP version)
- **Manage clusters**: `prefix + m` (cluster management menu)
- **Quay releases**: `prefix + q` (OCP versions on quay.chiaret.to)

#### File & Utility Operations

- **File browser**: `Ctrl + x` (opens file/directory with vim using FZF)
- **URL launcher**: `prefix + Tab` (opens URL from terminal using FZF)

## OpenShift Integration

This configuration includes specialized tools for OpenShift cluster management:

### Cluster Lifecycle Commands

- `ocpcreatecluster` - Create a new OpenShift cluster with interactive setup
- `ocpdestroycluster <cluster-name>` - Destroy an existing cluster
- `ocprecreatecluster <cluster-name>` - Recreate a cluster from scratch
- `ocpupgradecluster <cluster-name>` - Upgrade cluster to a new version
- `ocplifecycle` - View cluster lifecycle and version information

### Utility Commands

- `ocpgetclient` - Download OpenShift client tools
- `ocpgetreleases.py` - Fetch available OpenShift releases
- `ocpvariablesfiles` - Manage cluster variable files
- `ocpdocumentation` - Access OpenShift documentation
- `ocpreleasenotes` - View release notes for specific versions

### Dynamic Status Bar

The tmux status bar automatically detects your current cluster connection and displays:

- **Cluster version** (e.g., `4.16.21`)
- **Current user** (kubeconfig mode shown with `(k)`)
- **Active project** (namespace)
- **Status indicators**: Red for errors/disconnected, green for active connections

Example: `4.16.21:(k):openshift-config`

## FZF Interactive Menus

All FZF menus use the Gruvbox color scheme and support multi-select operations:

### Resource Browsers

- `fzf-pods.sh` - Browse pods with actions:
  - `Ctrl-l`: View logs in new window
  - `Ctrl-d`: Describe pod
  - `Ctrl-e`: Edit pod
  - `Ctrl-a`: Toggle select all

- `fzf-nodes.sh` - Browse cluster nodes:
  - `Ctrl-d`: Describe node
  - `Ctrl-e`: Edit node
  - `Ctrl-s`: SSH to node via oc debug

- `fzf-operators.sh` - Browse cluster operators:
  - `Ctrl-d`: Describe operator
  - `Ctrl-e`: Edit operator

- `fzf-projects.sh` - Browse and switch projects:
  - `Tab` or `Ctrl-p`: Switch to selected project

### Additional Menus

- `fzf-ocpversions.sh` - Browse available OpenShift versions
- `fzf-context.sh` - Switch kubeconfig contexts
- `fzf-routes.sh` - Browse OpenShift routes
- `fzf-vmwareusage.sh` - View VMware resource usage
- `fzf-tmuxp.sh` - Load tmuxp session templates

### Cluster Directory Structure

Clusters are stored in `/vms/clusters/$CLUSTERNAME/`:
- `auth/kubeconfig` - Cluster authentication
- `$CLUSTERNAME.json` - Cluster metadata
- `started` - Empty marker file (VMs are running)

## Additional Features

- **Mouse support**: Navigate and select using the mouse
- **Copy to clipboard**: Automatic copy on mouse selection
- **Quick paste**: `Ctrl-v` to paste from clipboard
- **256-color support**: Enhanced theme visualization with Gruvbox colors
- **Extended history**: 10,000 lines of scrollback buffer
- **Session templates**: Pre-configured layouts for cluster monitoring
- **Background process management**: Long-running operations with nohup
- **Automatic cache updates**: Systemd timers keep OpenShift versions and file database current

### Systemd Timers

The installation configures two systemd timers for automated maintenance:

1. **update-ocp-cache.timer** - Updates OpenShift version cache every 4 hours
   - Service: `update-ocp-cache.service`
   - Script: `/usr/local/bin/update_ocp_cache.py`
   - Cache file: `/opt/.ocp_versions_cache`
   - Fetches latest releases from mirror.openshift.com for versions 4.14-4.20

2. **updatedb.timer** - Updates mlocate file database hourly
   - Service: `updatedb.service`
   - Command: `/usr/sbin/updatedb`
   - Enables fast file searching with `locate` command

Both timers are automatically enabled and started during installation.

### Color Scheme

All components use the **Gruvbox** color palette:
- Dark background (`#1d2021`)
- Light foreground (`#ffffff`)
- Yellow highlights (`#d8a657`)
- Orange for versions
- Red for errors/warnings
- Green for active states
- Cyan (colour30) for projects

---
