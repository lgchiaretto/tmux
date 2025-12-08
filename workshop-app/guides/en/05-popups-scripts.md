# Popups and Scripts

In this guide you will learn to use and create custom popups in tmux.

---

## What are Popups?

Popups are floating windows over your tmux session. They:

- Don't disrupt your layout
- Close automatically after use
- Are perfect for quick tasks

---

## Step 1: Simple Popup

Run this command:

```bash
tmux display-popup -E "echo 'Hello from popup' && sleep 2"
```

**What happens:**
- A popup opens over the screen
- Shows the message
- Closes after 2 seconds

---

## Step 2: Interactive Popup

Open a shell in a popup:

```bash
tmux display-popup -E -w 80% -h 80% "bash"
```

**Options used:**
- `-E` - Closes on exit
- `-w 80%` - 80% width
- `-h 80%` - 80% height

Type `exit` to close.

---

## Step 3: Popup with fzf

Combine popup with fzf:

```bash
tmux display-popup -E -w 80% -h 60% "find . -type f | fzf"
```

**Practice:** Select a file and see the returned path.

---

## Step 4: Named Popup

Popups can have names and be reopened:

```bash
# Create named popup
tmux display-popup -E -d "#{pane_current_path}" -w 80% -h 80% -T "My Terminal"
```

**Option `-T`:** Sets the popup title.

---

## Step 5: Create a Popup Script

Let's create a script to search files:

```bash
cat > /tmp/search.sh << 'EOF'
#!/bin/bash
# Interactive file search

FILE=$(find . -type f -name "*.sh" 2>/dev/null | fzf --preview 'head -50 {}')

if [ -n "$FILE" ]; then
    vim "$FILE"
fi
EOF
chmod +x /tmp/search.sh
```

Run with popup:

```bash
tmux display-popup -E -w 90% -h 80% "/tmp/search.sh"
```

---

## Step 6: Monitoring Popup

Create a monitoring popup:

```bash
tmux display-popup -E -w 60% -h 40% "htop || top"
```

Press `q` to exit.

---

## Step 7: Popup with Preview

fzf with preview in popup:

```bash
tmux display-popup -E -w 90% -h 80% \
  "ls -la | fzf --preview 'cat {} 2>/dev/null || ls -la {}'"
```

---

## Step 8: Add Shortcut to tmux.conf

To create a permanent shortcut, add to `~/.tmux.conf`:

```bash
# Popup for htop
bind-key h display-popup -E -w 80% -h 80% "htop || top"
```

Then reload:

```bash
tmux source-file ~/.tmux.conf
```

Now `Ctrl+s h` opens htop in a popup!

---

## Useful Popup Scripts

### Calculator

```bash
tmux display-popup -E -w 40% -h 30% "bc -l"
```

### Git Status

```bash
tmux display-popup -E -w 80% -h 60% "git status && read -p 'Press Enter...'"
```

### Docker/Podman

```bash
tmux display-popup -E -w 90% -h 80% \
  "docker ps | fzf --header-lines=1 | awk '{print \$1}' | xargs docker logs -f"
```

---

## Anatomy of display-popup

```bash
tmux display-popup [options] [command]
```

| Option | Description |
|--------|-------------|
| `-E` | Closes when command exits |
| `-w WIDTH` | Sets width (%, or column count) |
| `-h HEIGHT` | Sets height (%, or line count) |
| `-x POS` | Horizontal position |
| `-y POS` | Vertical position |
| `-d DIR` | Initial directory |
| `-T TITLE` | Popup title |

---

## Step 9: Popup as Menu

Create an interactive menu:

```bash
cat > /tmp/menu.sh << 'EOF'
#!/bin/bash

OPTION=$(echo -e "1. View processes\n2. View memory\n3. View disk\n4. Exit" | \
        fzf --header "Select an option:")

case "$OPTION" in
    "1. View processes") ps aux | head -20 ;;
    "2. View memory") free -h ;;
    "3. View disk") df -h ;;
esac

read -p "Press Enter to close..."
EOF
chmod +x /tmp/menu.sh
```

Run:

```bash
tmux display-popup -E -w 60% -h 50% "/tmp/menu.sh"
```

---

## Next Guide

[→ 06 - Copy and Paste](06-copy-paste.md)

---

> **Tip:** Popups are perfect for tasks that don't need a permanent pane!
