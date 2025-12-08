# fzf Integration

In this guide you will learn to use fzf popups inside tmux for fast navigation.

---

## What is fzf?

fzf is a fuzzy finder - an interactive search tool that filters lists quickly.

Combined with tmux, it opens in elegant popups over your session.

---

## Step 1: File Search

Press:

```
Ctrl+x
```

**What happens:**
- Opens a popup with all files in the directory
- Type to filter
- Enter to open in vim
- Esc to cancel

**Practice:** Open the popup and search for "bashrc".

---

## Step 2: Navigate tmux Sessions

```
Ctrl+s  then  s
```

**What happens:**
- Lists all sessions
- Preview of session on the right side
- Navigate and select to switch

**Practice:** 
1. Create a new session: `Ctrl+s N` and name it "test"
2. Use `Ctrl+s s` to see and switch

---

## Step 3: Buffer Manager

```
Ctrl+s  then  b
```

**What happens:**
- Lists tmux buffers (copy history)
- Select to paste
- Useful for accessing previous copies

---

## Step 4: URLs in Terminal

```
Ctrl+s  then  Tab
```

**What happens:**
- Extracts all visible URLs in the terminal
- Select to open in browser
- Useful for links in logs or outputs

---

## Step 5: Command History

Inside the terminal, press:

```
Ctrl+r
```

**What happens:**
- Searches command history
- Type to filter
- Enter to execute

---

## Available fzf Scripts

| Shortcut | Function |
|----------|----------|
| `Ctrl+x` | File search |
| `Ctrl+s b` | tmux buffers |
| `Ctrl+s Tab` | URLs in terminal |
| `Ctrl+s s` | tmux sessions |

---

## Step 6: Run a Script Manually

You can run fzf scripts directly:

```bash
# List files
/usr/local/share/tmux-ocp/fzf-files/fzf-files.sh

# View buffers
/usr/local/share/tmux-ocp/fzf-files/fzf-buffer.sh
```

---

## Creating Your Own fzf Script

Basic structure of an fzf popup script:

```bash
#!/bin/bash
# Generate list | fzf with options | process selection

ls -la | fzf --preview 'file {}' | xargs echo "Selected:"
```

To open in tmux popup:

```bash
tmux display-popup -E -w 80% -h 80% "your-script.sh"
```

---

## Next Guide

[→ 05 - Popups and Scripts](05-popups-scripts.md)

---

> **Tip:** fzf + tmux popup = instant productivity!
