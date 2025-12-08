# Sessions and Windows

In this guide you will learn to manage sessions and windows in tmux.

---

## What is a Session?

A session is a complete tmux environment containing:

- One or more windows
- Persistent state (even if you disconnect)
- Its own buffer history

---

## Step 1: List Sessions

Press:

```
Ctrl+s  then  s
```

You will see the current session highlighted in the list.

---

## Step 2: Create a New Session

Press:

```
Ctrl+s  then  N
```

Type "dev" and press Enter.

This creates a new session called "dev".

---

## Step 3: Switch Sessions

Use the shortcut:

```
Ctrl+s  then  s
```

A list of sessions appears. Use arrows to select and Enter to switch.

---

## Step 4: Return to Original Session

Use `Ctrl+s s` again and select "workshop".

---

## Step 5: Return to dev Session

Use `Ctrl+s s` again and select "dev".

---

## Step 6: Delete a Session

To remove the "dev" session:

```
Ctrl+s  then  K
```

Verify you are using the "dev" session and confirm with `y`.

**Warning:** This closes all windows and processes in that session!

---

## Step 7: Rename Session

```
Ctrl+s  then  .
```

Type the new name and press Enter.

---

## Step 8: Window Management

### Creating Windows

Use the **[+]** button in the status bar.

### Closing Windows

Type `exit` in the window or press `Ctrl+d`.

Or use:

```
Ctrl+s  then  k
```

Confirm with `y`.

---

## Step 9: Practice Complete Flow

Execute this sequence:

1. Create a session:
   ```
   Ctrl+s  then  N
   ```
   Type "test" and press Enter.

2. List sessions:
   ```
   Ctrl+s  then  s
   ```

3. Switch to the new session by selecting it from the list.

4. Create a window using **[+]**

5. Rename the window:
   ```
   Ctrl+s  then  ,
   ```

6. Delete the test session:
   ```
   Ctrl+s  then  K
   ```
   Confirm with `y`.

---

## Shortcuts Summary

| Action | Shortcut |
|--------|----------|
| Create session | `Ctrl+s N` |
| List sessions | `Ctrl+s s` |
| Switch session | `Ctrl+s s` |
| Rename session | `Ctrl+s .` |
| Detach | `Ctrl+s d` |
| Delete session | `Ctrl+s K` |

**Note:** If you're outside tmux, use `tmux a` to attach to a session.

---

## Next Guide

[→ 03 - Panes](03-panes.md)

---

> **Tip:** Sessions are perfect for separating projects or contexts!
