# Panes

In this guide you will learn to split the screen into panes and navigate between them.

---

## Step 1: Split Horizontally

Press:

```
Ctrl + \
```

This splits the current window into two side-by-side panes.

---

## Step 2: Split Vertically

Press:

```
Ctrl+s  then  -
```

This splits the current pane into two, one above the other.

---

## Step 3: Practice Splits

Create a structure like this:

```
+─────────+─────────+
|         |         |
|    1    |    2    |
|         +─────────+
|         |    3    |
+─────────+─────────+
```

**Steps:**
1. `Ctrl+\` to split horizontally
2. Go to the right pane
3. `Ctrl+s` then `-` to split vertically

---

## Step 4: Navigate Between Panes

Use arrows with Ctrl:

| Action | Shortcut |
|--------|----------|
| Left pane | `Ctrl ←` |
| Right pane | `Ctrl →` |
| Pane above | `Ctrl ↑` |
| Pane below | `Ctrl ↓` |

**Practice:** Navigate between all panes you created.

---

## Step 5: Resize Panes

Use Alt+Shift+Arrows:

| Action | Shortcut |
|--------|----------|
| Expand left | `Alt+Shift ←` |
| Expand right | `Alt+Shift →` |
| Expand up | `Alt+Shift ↑` |
| Expand down | `Alt+Shift ↓` |

---

## Step 6: Move Panes

Swap pane positions:

| Action | Shortcut |
|--------|----------|
| Swap with pane above | `Alt ↑` |
| Swap with pane below | `Alt ↓` |

---

## Step 7: Zoom a Pane

To temporarily maximize a pane:

```
Ctrl+s  then  z
```

Press again to return to the original layout.

**Useful for:** Viewing logs or long outputs in full screen.

---

## Step 8: Close a Pane

To close the current pane, simply type:

```bash
exit
```

Or press `Ctrl+d`.

---

## Step 9: Synchronize Panes

To type in all panes at once:

```
Ctrl+s  then  a
```

This toggles synchronized mode. Useful for running commands on multiple servers.

---

## Step 10: Convert Pane to Window

To turn a pane into a new window:

```
Ctrl+s  then  !
```

---

## Suggested Development Layout

```
+─────────────────────────────+
|           Editor            |
+──────────────+──────────────+
|    Logs      |   Terminal   |
+──────────────+──────────────+
```

**Build this layout:**
1. `Ctrl+s` then `-` (vertical split)
2. Go to the bottom pane
3. `Ctrl+\` (horizontal split)

---

## Next Guide

[→ 04 - fzf Integration](04-fzf-integration.md)

---

> **Tip:** Use panes to monitor logs while working on code!
