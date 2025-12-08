# Copy and Paste

In this guide you will learn to use tmux copy mode to copy text.

---

## Important Concepts

tmux has its own copy/paste system:

- **Copy Mode:** Navigation and text selection
- **Buffer:** Stores copied text
- **Paste:** Pastes from tmux buffer

---

## Step 1: Enter Copy Mode

Press:

```
Ctrl+s  then  [
```

**What changes:**
- You can navigate through history
- Cursor moves freely
- Shows `[0/0]` in corner (buffer position)

---

## Step 2: Navigate in Copy Mode

Use these keys to navigate:

| Key | Action |
|-----|--------|
| `Arrows` | Move cursor |
| `Page Up/Down` | Move one page |
| `g` | Go to beginning |
| `G` | Go to end |
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next occurrence |
| `N` | Previous occurrence |

**Practice:** Enter copy mode and navigate through history.

---

## Step 3: Select Text

To start selection:

```
Press  v
```

**Selection modes:**
- `v` - Normal selection (character by character)
- `V` - Line selection
- `Ctrl+v` - Block selection (rectangular)

Move cursor to expand selection.

---

## Step 4: Copy the Text

After selecting, press:

```
y
```

This copies to tmux buffer and exits copy mode.

**Or use:** `Enter` also copies and exits.

---

## Step 5: Paste the Text

To paste:

```
Ctrl+s  then  ]
```

Text from buffer is inserted at current position.

---

## Step 6: Practice Complete Flow

Run this command to have text:

```bash
echo -e "Line 1: First text\nLine 2: Second text\nLine 3: Third text"
```

Now:
1. `Ctrl+s [` - Enter copy mode
2. Navigate to "Second"
3. `v` - Start selection
4. Select "Second text"
5. `y` - Copy
6. `Ctrl+s ]` - Paste

---

## Step 7: Copy Entire Line

Quick method to copy a line:

1. `Ctrl+s [` - Copy mode
2. Go to desired line
3. `V` - Line selection
4. `y` - Copy

---

## Step 8: Use Search

To find specific text:

1. `Ctrl+s [` - Copy mode
2. `/text` - Search for "text"
3. `Enter` - Confirm
4. `n` / `N` - Next/previous

**Practice:** Search for a word on screen.

---

## Step 9: Access Previous Buffers

tmux keeps a copy history. To access:

```
Ctrl+s  then  b
```

This opens the fzf popup with all buffers.

**Or manually:**

```bash
tmux list-buffers
tmux show-buffer -b buffer0
```

---

## Step 10: Copy to File

Save buffer to a file:

```bash
tmux save-buffer /tmp/copied.txt
cat /tmp/copied.txt
```

---

## Step 11: Copy from File to Buffer

Load text from file to buffer:

```bash
echo "Text from file" > /tmp/source.txt
tmux load-buffer /tmp/source.txt
```

Now `Ctrl+s ]` pastes that text.

---

## Step 12: Copy Mode with Mouse

If mouse is enabled:

1. Click and drag to select
2. Release to copy automatically
3. Middle click to paste

---

## Advanced Tips

### Copy Command Output

```bash
# Copy last command output to buffer
tmux capture-pane -p | tmux load-buffer -
```

### Copy Entire Pane

```bash
# Capture entire pane history
tmux capture-pane -p -S - | tmux load-buffer -
```

### Pipe to Command

```bash
# Copy and process
tmux save-buffer - | grep "error"
```

---

## Shortcuts Summary

| Action | Shortcut |
|--------|----------|
| Enter copy mode | `Ctrl+s [` |
| Start selection | `v` |
| Line selection | `V` |
| Block selection | `Ctrl+v` |
| Copy | `y` or `Enter` |
| Paste | `Ctrl+s ]` |
| Exit copy mode | `Esc` or `q` |
| View buffers | `Ctrl+s b` |

---

## Next Guide

[→ 07 - Shortcuts Reference](07-shortcuts-reference.md)

---

> **Tip:** Copy mode is essential for extracting logs and command outputs!
