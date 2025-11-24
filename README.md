# Tmux Configuration & OpenShift Tools

This repository contains a custom tmux configuration integrated with FZF interactive menus and OpenShift cluster management tools. It provides a complete control plane for Red Hat OpenShift administrators with shell configuration, interactive resource browsers, cluster lifecycle automation, and real-time status monitoring.

**🌍 GLOBAL CONFIGURATION**: This project is designed to provide a unified experience for **all users** on a system. All configurations, scripts, and tools are shared globally.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Executing tmux](#executing)
- [Key Shortcuts](#key-shortcuts)
- [OpenShift Integration](#openshift-integration)
- [FZF Interactive Menus](#fzf-interactive-menus)
- [Additional Features](#additional-features)
- [Global Configuration](#global-configuration)

---

## Requirements

- **Tmux** version 3.4 or higher
- **FZF** for interactive fuzzy finding
- **OpenShift CLI (oc)** for cluster management
- **Vim** for file editing
- **Git**
- **Python 3** with tmuxp package (`pip3 install tmuxp`)
- **bat** for syntax highlighting (optional)
- **VMware govc** for VM operations on Chiaretto Labs (optional)

## Installation

Clone this repository and execute the `configure-local.sh` script:

### Local Installation (Default - Current User Only)

```bash
sudo ./configure-local.sh
```

This will:
- **Install all scripts** to `/usr/local/bin/` (accessible to everyone)
- **Install dotfiles ONLY for current user**
- **Create configuration** at `~/.tmux/config.sh` for current user
- Install FZF globally
- Download and install tmux binary (if needed)
- Install OpenShift CLI (oc) if it doesn't exist
- Install systemd services for cache updates
- Configure bash with Gruvbox color scheme and OpenShift helpers

### System-Wide Installation (All Users)

To install for ALL users (including new users):

```bash
sudo ./configure-local.sh --update-users
```

This will:
- Install dotfiles to `/etc/skel/` (template for new users)
- Update ALL existing users with the configuration
- New users created with `useradd -m` automatically inherit the setup

**WARNING**: This will overwrite existing dotfiles for ALL users.

### Additional Options

View all available options:
```bash
sudo ./configure-local.sh --help
```

Install with all options:
```bash
sudo ./configure-local.sh --update-users --download-tmux --download-oc
```

### For New Users

If you installed with `--update-users`, new users automatically get the configuration:

```bash
sudo useradd -m newuser
```

Dotfiles are copied from `/etc/skel/` automatically.

**Note**: If you used the default installation (without `--update-users`), new users will NOT get the configuration. Each user must run the installation separately.

### Configuration

After installation, **each user has their own independent configuration** at `~/.tmux/config.sh`.

**Edit your configuration**:
```bash
vim $HOME/.tmux/config.sh
```

**Note**: Each user's configuration is independent. Scripts are installed globally at `/usr/local/bin/`, but each user has their own `~/.tmux/config.sh` file.

**Available Configuration Options:**

**Paths:**
- `CLUSTERS_BASE_PATH`: Base directory where OpenShift clusters are stored (default: `/vms/clusters`)
- `OCP_CACHE_DIR`: Cache directory for OCP clients and other cached data (default: `${CLUSTERS_BASE_PATH}/.cache`)
- `CLUSTER_VARIABLES_DIR`: Directory for vSphere cluster template files (default: `${CLUSTERS_BASE_PATH}/variables-files`)
- `KVM_VARIABLES_DIR`: Directory for KVM cluster template files in YAML format (default: `${CLUSTERS_BASE_PATH}/variables-files-kvm`)
- `ANSIBLE_PLAYBOOK_KVM_PATH`: Path to Ansible playbook directory for KVM cluster management

**Remote Synchronization:**
- `REMOTE_BASTION_HOST`: Remote host for cluster state synchronization (optional, format: `user@host`)

**VMware/vSphere Credentials:**
- `VSPHERE_USERNAME`: Username for VMware vSphere/govc operations (default: `administrator@chiaretto.local`)
- `VSPHERE_PASSWORD`: Password for vSphere user
- `GOVC_URL`: vSphere vCenter URL (default: `https://chiaretto-vcsa01.chiaret.to`)

**OpenShift Credentials:**
- `OCP_USERNAME`: Username for OpenShift cluster login (non-kubeadmin) (default: `chiaretto`)
- `OCP_PASSWORD`: Password for OpenShift admin user

**UI Customization:**
- `FZF_BORDER_LABEL`: Border label for all FZF interactive menus (default: `chiarettolabs.com.br`)
- `CHECK_BASTION_HOST`: Enforce bastion host check before cluster operations (default: `false`)

**Security Note:** The `config.sh` file contains sensitive credentials and is excluded from git via `.gitignore`. Keep this file secure with appropriate permissions (600).

The configuration is automatically loaded by:
- `bash_functions` when you start a new shell
- All FZF scripts in `fzf-files/`
- All OCP management scripts in `ocpscripts/`

**Note:** The scripts will look for the configuration file `$HOME/.tmux/config.sh`

## Executing tmux

- Run `tmux` or `t` in your terminal
- Detach tmux: `prefix + d`
- Attach an existing tmux session: `tmux a` or `t`

## Key Shortcuts

#### Global Prefix

⚠️ **The default Tmux prefix has been changed from `Ctrl + b` to `Ctrl + s`.** All Tmux commands now use `Ctrl + s` as the prefix.

#### Session Management

- **Create new session**: `prefix + N` (prompts for session name)
- **Rename session**: `prefix + .` (prompts for new name)
- **Select session**: `prefix + s` (opens session selector)
- **Choose tree**: `prefix + w` (opens window/session tree in zoom mode)
- **click status left (session name)**: Opens choose-tree view
- **Kill current session**: `prefix + K` (with confirmation; handles last session gracefully)
- **Kill all sessions**: `prefix + D` (with confirmation prompt)
- **Switch to last session (when not in vim)**: `Ctrl + b`

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

### Dynamic Status Bar

The tmux status bar automatically detects your current cluster connection and displays:

- **Cluster version** (e.g., `4.19.19`)
- **Current user** (kubeconfig mode shown with `(k)`)
- **Active project** (namespace)
- **Status indicators**: Red for errors/disconnected, green for active connections

Example: `4.19.19:(k):openshift-config`

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

If you are using the repo https://github.com/lgchiaretto/ocp4_setup_upi_kvm_ansible

Clusters are stored in `${CLUSTERS_BASE_PATH}/$CLUSTERNAME/`:
- `auth/kubeconfig` - Cluster authentication
- `$CLUSTERNAME.json` - Cluster metadata
- `started` - Empty marker file (VMs are running)

The base path is configurable via the `CLUSTERS_BASE_PATH` variable in `~/.tmux/config.sh`.

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

---
