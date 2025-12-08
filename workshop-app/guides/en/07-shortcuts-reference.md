# Shortcuts Reference

This is a quick reference of all tmux shortcuts used in this workshop.

---

## Prefix Key

The prefix key is configured as:

```
Ctrl+s
```

Most commands require pressing the prefix first.

---

## Sessions

| Action | Shortcut |
|--------|----------|
| New session | `Ctrl+s N` |
| List sessions | `Ctrl+s s` |
| Rename session | `Ctrl+s .` |
| Detach | `Ctrl+s d` |
| Delete session | `Ctrl+s K` |

---

## Windows

| Action | Shortcut |
|--------|----------|
| New window | Click `[+]` in status bar |
| Next window | `Shift →` |
| Previous window | `Shift ←` |
| Go to window N | `Ctrl+s 0-9` |
| Rename window | `Ctrl+s ,` |
| Close window | `Ctrl+s k` |
| Window list | `Ctrl+s w` |
| Move window left | `Ctrl+Shift ←` |
| Move window right | `Ctrl+Shift →` |

---

## Panes - Create

| Action | Shortcut |
|--------|----------|
| Split horizontal | `Ctrl+\` |
| Split vertical | `Ctrl+s -` |
| Close pane | `exit` or `Ctrl+d` |

---

## Panes - Navigate

| Action | Shortcut |
|--------|----------|
| Left pane | `Ctrl ←` |
| Right pane | `Ctrl →` |
| Pane above | `Ctrl ↑` |
| Pane below | `Ctrl ↓` |

---

## Panes - Resize

| Action | Shortcut |
|--------|----------|
| Expand left | `Alt+Shift ←` |
| Expand right | `Alt+Shift →` |
| Expand up | `Alt+Shift ↑` |
| Expand down | `Alt+Shift ↓` |

---

## Panes - Other

| Action | Shortcut |
|--------|----------|
| Zoom (maximize) | `Ctrl+s z` |
| Swap with above | `Alt ↑` |
| Swap with below | `Alt ↓` |
| Convert to window | `Ctrl+s !` |
| Synchronize panes | `Ctrl+s a` |

---

## Copy Mode

| Action | Shortcut |
|--------|----------|
| Enter copy mode | `Ctrl+s [` |
| Start selection | `v` |
| Line selection | `V` |
| Block selection | `Ctrl+v` |
| Copy | `y` or `Enter` |
| Paste | `Ctrl+s ]` |
| Exit | `Esc` or `q` |
| Search | `/text` |
| Next search | `n` |
| Previous search | `N` |

---

## fzf and Popups

| Action | Shortcut |
|--------|----------|
| File search | `Ctrl+x` |
| View buffers | `Ctrl+s b` |
| URLs in terminal | `Ctrl+s Tab` |
| List sessions | `Ctrl+s s` |

---

## Command History

| Action | Shortcut |
|--------|----------|
| Search history | `Ctrl+r` |

---

## Useful tmux Commands

```bash
# Create session (if outside tmux)
tmux new-session -s name
tmux new -s name

# Attach to session (if outside tmux)
tmux attach -t name
tmux a -t name

# Kill tmux server (use with caution)
tmux kill-server

# Reload configuration
tmux source-file ~/.tmux.conf

# View all keys
tmux list-keys

# View options
tmux show-options -g
```

---

## Buffer Commands

```bash
# List buffers
tmux list-buffers

# View buffer content
tmux show-buffer

# Save buffer to file
tmux save-buffer /path/file.txt

# Load file to buffer
tmux load-buffer /path/file.txt

# Capture pane to buffer
tmux capture-pane -p
```

---

## Popup Commands

```bash
# Simple popup
tmux display-popup -E "command"

# Popup with size
tmux display-popup -E -w 80% -h 80% "command"

# Popup with title
tmux display-popup -E -T "Title" "command"
```

---

## Vim in tmux

| Action | Shortcut |
|--------|----------|
| Open file | `vim file` |
| Save | `:w` |
| Quit | `:q` |
| Save and quit | `:wq` or `ZZ` |
| Quit without saving | `:q!` |

---

## Final Tips

1. **Prefix + ?** - Shows all tmux shortcuts
2. **tmux list-keys** - Lists shortcuts in terminal
3. **tmux show-options** - Shows configurations

---

## Next Steps

- Explore the `~/.tmux.conf` file
- Create your own shortcuts
- Add plugins with TPM
- Customize colors and status bar

---

> **Congratulations!** You completed the tmux workshop!
