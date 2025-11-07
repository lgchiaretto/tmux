# Tmux Configuration & OpenShift Tools Copilot Instructions

## Project Overview
This is a tmux-based control plane for OpenShift cluster management that integrates FZF interactive menus with the `openshift4-automation` Ansible framework. It provides shell configuration, interactive resource browsers, cluster lifecycle automation, and real-time status monitoring for Red Hat OpenShift administrators.

## Architecture & Key Components

### Core Configuration System (`dotfiles/`, `configure-local.sh`)
- **Installation**: `./configure-local.sh --download-tmux --download-oc` sets up complete environment (clones fzf, installs dependencies, copies configs to `~/`)
- **Tmux Prefix**: `C-s` (NOT `C-b`) - all keybindings use this prefix
- **Key Bindings**: `C-t` new window, `S-Left/Right` window nav, `C-\` horizontal split, `C-Arrow` pane nav
- **Bashrc Conventions**: Gruvbox color scheme in PS1, extensive `GOVC_*` environment variables for VMware, FZF integration with exact matching
- **Bash Functions**: `tmux-sync-ssh` and `tmux-sync-ossh` create synchronized multi-pane SSH sessions (`tmux-sync-ssh host1 host2` or `tmux-sync-ssh host 3` for 3 panes)

### FZF Integration Layer (`fzf-files/`)
All FZF scripts follow a consistent pattern and create new tmux windows with descriptive names:

**Standard FZF Script Pattern:**
```bash
# 1. Action wrapper for multi-select operations
if [[ "$1" == "--action-wrapper" ]]; then
    action="$2"; shift 2
    for item in "$@"; do tmux new-window -n "action:$item" "oc command $item; bash"; done
    exit 0
fi

# 2. FZF menu with keybindings
selected=$(data_source | fzf-tmux \
    --header='Help text' \
    --bind 'ctrl-l:execute-silent('"$0"' --action-wrapper logs {+1})+abort' \
    --color=fg:#ffffff,bg:#1d2021,hl:#d8a657)
```

**Key Scripts:**
- `fzf-pods.sh`: `Ctrl-l` logs, `Ctrl-d` describe, `Ctrl-e` edit - all create `logs:podname` or `desc:podname` windows
- `fzf-manageclusters.sh`: Master cluster menu - `c` create, `d` destroy, `s` start VMs, `S` stop VMs, `k` switch to cluster session with KUBECONFIG set
- `fzf-nodes.sh`, `fzf-operators.sh`: Similar pattern with resource-specific actions
- **Tmux Command Patterns**: Use `tmux send-keys "command" C-m` to execute in current window, `tmux new-window -n "name" "command; bash"` for new windows

### OpenShift Automation Bridge (`ocpscripts/`)
Scripts that call Python automation in `/home/lchiaret/git/openshift4-automation`:

**Integration Points:**
```bash
# ocpcreatecluster - shows FZF menu, opens vim for cluster vars, then:
tmux send-keys "/home/lchiaret/git/openshift4-automation/createcluster.py -i $file -n $cluster_name" C-m

# ocpdestroycluster - directly calls destroy playbooks:
tmux send-keys "/home/lchiaret/git/openshift4-automation/run-playbooks-destroy.py $1" C-m

# ocprecreatecluster - background execution pattern:
tmux send-keys "nohup /home/lchiaret/git/openshift4-automation/run-playbooks-recreate.py '$1' > /tmp/nohup-recreate.out 2>&1 &" C-m
```

**Hostname Restriction:** `ocpcreatecluster` exits if not on `bastion.chiaret.to` (hostname check at script start)

### Session Templates (`tmux-sessions/*.yaml`)
Tmuxp YAML templates with pre-configured layouts for cluster monitoring:

**Standard 4-pane Layout:**
```yaml
layout: 990d,318x81,0,0[318x40,0,0,7,318x40,0,41{159x40,0,41,8,158x40,160,41[158x24,160,41,9,158x15,160,66,10]}]
shell_command_before:
  - export KUBECONFIG=$(pwd)/auth/kubeconfig
panes:
  - watch -n2 "oc get pods -A | grep -E '0/|CrashLoopBackOff|Terminating'"
  - watch -n2 oc get co
  - while true; do oc adm certificate approve $(oc get csr | grep Pending | awk '{print $1}'); sleep 5; done
  - watch -n2 oc get nodes
```

### Dynamic Status Bar (`ocp-cluster.tmux`, `ocp-project.tmux`)
Context-aware tmux status bar that auto-detects cluster connection:

**Detection Logic:**
1. Check `/vms/clusters/$SESSION_NAME/auth/kubeconfig` (if tmux session matches cluster name)
2. Fall back to `oc whoami` for active context
3. Display: `#[fg=orange]4.16.21#[fg=white]:#[fg=green](k)#[fg=white]:#[fg=colour30]openshift-config` (version:user:project)
4. Error states: `#[fg=red]N/A` or `#[fg=red]<no-project>` or `#[fg=red]<deleted>`

## Development Patterns

### Tmux Window/Session Naming Conventions
- **Sessions**: Named after cluster names - automation creates `install-clustername` or `upgrade-clustername` sessions
- **Windows**: Descriptive action:target format - `logs:podname`, `desc:resource`, `edit:nodename`, `create check`
- **Multi-select Actions**: Use `--action-wrapper` pattern to process multiple selections (see `fzf-pods.sh` for reference implementation)

### FZF Script Architecture
Every FZF script implements this two-part structure:

1. **Action Wrapper** (handles multi-select via `--action-wrapper` flag):
```bash
if [[ "$1" == "--action-wrapper" ]]; then
    action="$2"; shift 2
    for item in "$@"; do
        case "$action" in
            logs) tmux new-window -n "logs:$item" "oc logs $item; bash" ;;
            describe) tmux new-window -n "desc:$item" "oc describe $item; bash" ;;
        esac
    done
    exit 0
fi
```

2. **FZF Menu** (binds keys to call wrapper with `{+1}` for multi-select):
```bash
--bind 'ctrl-l:execute-silent('"$0"' --action-wrapper logs {+1})+abort'
--bind 'ctrl-d:execute-silent('"$0"' --action-wrapper describe {+1})+abort'
```

### Tmux Command Patterns
- **Execute in current window**: `tmux send-keys "command" C-m` (appends C-m for Enter)
- **New window with keepalive**: `tmux new-window -n "name" "command; bash"` (bash prevents auto-close)
- **Wait for editor**: `tmux new-window -n "vim" "vim file; tmux wait-for -S vim-done"` then `tmux wait-for vim-done`
- **Session switching**: `tmux has-session -t name || tmux new-session -d -s name -e KUBECONFIG=path; tmux switch-client -t name`

### File System Conventions
- **Cluster directories**: `/vms/clusters/$CLUSTERNAME/` (contains `auth/kubeconfig`, `$CLUSTERNAME.json`, optional `started` marker)
- **Variable files**: `/vms/clusters/variables-files/ansible-vars-*.json` (templates for cluster creation)
- **Metadata structure**: JSON files store `vmwarenotes`, `ocpversion`, `clustertype`, `sno`, `platform`, `n_worker`, `vmwaredatastore`, `vmwarenetwork`, `basedomain`
- **Cache files**: `/tmp/` for background processes, `/data/.ocp_versions_cache` for release tracking
- **Status markers**: Empty `started` file indicates cluster VMs are running (checked by `fzf-manageclusters.sh` to show `*` suffix)

### Color & UI Standards
- **Tmux status colors**: Orange for versions, red for errors/disconnected, green for kubeconfig mode, colour30 for projects
- **FZF Gruvbox theme**: `--color=fg:#ffffff,bg:#1d2021,hl:#d8a657` (white text, dark bg, yellow highlights)
- **Border labels**: `--border-label=" chiarettolabs.com.br "` centered on all FZF menus
- **Pod status coloring**: Non-Running/Succeeded/Completed pods shown in red ANSI (`\033[31m`)

### Background Process Patterns
```bash
# Nohup background execution (for long-running cluster operations)
tmux send-keys "nohup /path/to/script.py > /tmp/nohup-output.out 2>&1 &" C-m

# Systemd timer integration (update-ocp-cache)
update_ocp_cache.py fetches releases to /data/.ocp_versions_cache
fzf-ocpversions.sh reads cache file for instant display
```

## Key Workflows

### Initial Environment Setup
```bash
./configure-local.sh --download-tmux --download-oc  # Full installation
# Installs: fzf, tmux binary, oc client, dotfiles to ~/, scripts to /usr/local/bin/
# Creates: ~/.tmux/ with FZF scripts, ~/tmux-sessions/ with templates
```

### Cluster Creation Workflow
1. Run `ocpcreatecluster` (only on bastion.chiaret.to)
2. Select cluster type from FZF menu (IPI/UPI, baremetal/vSphere/none)
3. Vim opens with JSON variable file - edit and save
4. Automation calls `/home/lchiaret/git/openshift4-automation/createcluster.py -i $file`
5. Tmux session auto-created with name `install-clustername` using `create-cluster-sessions.yaml`
6. 4-pane monitoring: failing pods, cluster operators, CSR approvals, nodes

### Cluster Management with FZF
- Run `fzf-manageclusters.sh` to see all clusters with metadata (version, type, workers, datastore, status)
- Clusters with `started` file show `*` suffix (VMs running)
- Press `k` to switch tmux session with KUBECONFIG set to `/vms/clusters/$NAME/auth/kubeconfig`
- Press `s`/`S` to start/stop VMs (creates/removes `started` marker)
- Press `d` to destroy (calls `ocpdestroycluster` -> `run-playbooks-destroy.py`)

### Resource Browser Patterns
All resource FZF scripts support multi-select (Ctrl-a toggle all):
- `fzf-pods.sh`: Ctrl-l logs, Ctrl-d describe, Ctrl-e edit
- `fzf-nodes.sh`: Ctrl-d describe, Ctrl-e edit, Ctrl-s ossh
- `fzf-operators.sh`: Ctrl-d describe, Ctrl-e edit
- `fzf-projects.sh`: Tab or Ctrl-p to switch project

### Multi-Host SSH Synchronization
```bash
# Synchronized panes to 3 hosts
tmux-sync-ssh host1 host2 host3

# 4 panes to same host (numeric shorthand)
tmux-sync-ssh hostname 4

# Uses ossh instead of ssh (OpenShift debug pods)
tmux-sync-ossh master-0 master-1 master-2
```

## Integration with OpenShift4-Automation

### Communication Flow
1. **User selects action** in FZF menu (`fzf-manageclusters.sh`)
2. **Wrapper script** translates to automation command (`ocpcreatecluster`, `ocpdestroycluster`, etc.)
3. **Automation execution**: Python scripts in `/home/lchiaret/git/openshift4-automation` run Ansible playbooks
4. **Session creation**: Automation creates tmux session using templates from `tmux-sessions/`
5. **Status monitoring**: `ocp-cluster.tmux` shows live cluster state in status bar

### Key Integration Points
- **Variable file handoff**: FZF opens vim for editing, path passed to `createcluster.py -i $file`
- **Session naming contract**: Automation must create sessions named `install-$CLUSTER` or `upgrade-$CLUSTER`
- **KUBECONFIG injection**: Sessions created with `-e KUBECONFIG=/vms/clusters/$NAME/auth/kubeconfig`
- **Shared metadata**: JSON files in `/vms/clusters/$NAME/` used by both systems
- **Log organization**: Automation output structured for tmux window consumption

### Script Execution Patterns
```bash
# Foreground with feedback (ocpcreatecluster)
tmux send-keys "/home/lchiaret/git/openshift4-automation/createcluster.py -i $file" C-m

# Background with nohup (ocprecreatecluster)
tmux send-keys "nohup /home/lchiaret/git/openshift4-automation/run-playbooks-recreate.py '$1' > /tmp/nohup-recreate.out 2>&1 &" C-m

# Remote execution (when not on bastion.chiaret.to)
tmux send-keys "ssh -t user@bastion 'command'" C-m
```

## Dependencies & External Systems
- **FZF**: Must be installed via `~/.fzf/install` (handled by configure-local.sh)
- **tmuxp**: Python package for YAML session templates (`pip3 install tmuxp`)
- **bat**: Syntax highlighting for file previews in FZF
- **OpenShift CLI (oc)**: Downloaded to `/usr/local/bin/`, version from mirror.openshift.com
- **VMware govc**: Uses `GOVC_*` environment variables from bashrc for VM operations
- **Systemd**: `update-ocp-cache.timer` runs `update_ocp_cache.py` periodically to refresh `/data/.ocp_versions_cache`

## Project-Specific Conventions
- **Hostname restriction**: `ocpcreatecluster` only runs on `bastion.chiaret.to` (early exit otherwise)
- **No emojis**: Documentation and scripts use text-only formatting
- **English only**: All content, comments, and output in English
- **Bash style**: Functions use `snake_case`, avoid creating new markdown summaries unless requested
- **Window persistence**: Commands end with `; bash` to keep tmux windows open after execution
- **Automation repo path**: Hardcoded as `/home/lchiaret/git/openshift4-automation` in wrapper scripts