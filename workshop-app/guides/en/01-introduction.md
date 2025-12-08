# Introduction

In this guide you will learn the basic concepts of tmux and how to use this workshop.

---

## How to Use This Workshop

On the left side you see this guide. On the right side you have a real terminal with tmux running.

**Follow each step** and practice in the terminal.

---

## Step 1: Find the Status Bar

Look at the bottom of the terminal. You will see a bar like this:

```
[workshop] bash [+] |              [ tmux workshop ]
```

This is the **tmux status bar**. It shows:

- `[workshop]` - Session name
- `bash` - Current window
- `[+]` - Button to create new window

---

## Step 2: Find the [+] Button

In the status bar, look for the green **[+]** button.

This button creates a new window. Click it now!

**What happened:** A new window was created. Note that another tab appeared in the bar.

---

## Step 3: Understand the Prefix Key

tmux uses a special key called **prefix**. In this workshop, the prefix is:

```
Ctrl+s
```

Most tmux commands follow this pattern:
1. Press `Ctrl+s` (prefix)
2. Release
3. Press the command key

---

## Step 4: Navigate Between Windows

Now that you have 2 windows, let's navigate:

| Action | Shortcut |
|--------|----------|
| Next window | `Shift →` |
| Previous window | `Shift ←` |
| Window by number | `Ctrl+s` then `0-9` |

**Practice:** Use `Shift →` and `Shift ←` to switch between windows.

---

## Step 5: Understand the Hierarchy

tmux organizes work in:

```
Server
  └── Session (workshop)
       └── Window (like browser tabs)
            └── Pane (screen divisions)
```

- **Session**: A working environment
- **Window**: A screen inside the session
- **Pane**: Divisions of a window

---

## Step 6: Your First Commands

In the terminal, type:

```bash
echo "Hello tmux!"
```

Now create another window with **[+]** and run:

```bash
ls -la
```

Use `Shift ←` to go back to the first window.

---

## Step 7: Rename the Window

To rename the current window:

```
Ctrl+s  then  ,
```

Type a new name and press Enter.

**Practice:** Rename one window to "code" and another to "logs".

---

## Step 8: View All Windows

To see all windows in a list:

```
Ctrl+s  then  w
```

Use arrows to navigate and Enter to select.

---

## Important Tip

> Browser shortcuts like Ctrl+T and Ctrl+W are blocked.
> Use the **[+]** button and tmux commands to manage windows.

---

## Next Guide

[→ 02 - Sessions and Windows](02-sessions-windows.md)

---

> **Tip:** The terminal on the right is real! Everything you type is executed.
