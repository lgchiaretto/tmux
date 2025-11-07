# Tmux Control Plane Presentation

Interactive presentation about tmux and the OpenShift cluster management system.

## Quick Start

```bash
./start-presentation.sh
```

## Navigation

Once in the presentation:
- **S-Right** (Shift + Right Arrow): Next slide
- **S-Left** (Shift + Left Arrow): Previous slide  
- **C-s q**: Quit presentation

Navigation uses the same keys as tmux window navigation for consistency!

## Presentation Outline

1. **Introduction** - Overview and agenda
2. **What is tmux?** - Terminal multiplexer concepts
3. **Tmux Basics** - Sessions, windows, panes, and keybindings
4. **Tmux Configuration** - Custom prefix (C-s) and status bar
5. **Project Overview** - Architecture and component layers
6. **FZF Integration** - What is FZF and how we use it
7. **Bash Customization** - Custom prompt, functions, and environment
8. **Resource Browsers** - Pod/node/operator management
9. **Live Demo** - Hands-on demonstration scenarios
10. **Conclusion** - Summary and getting started

## Important Keybinding Notes

Many keybindings in this setup **do NOT require the prefix** (C-s):
- **C-t**: Create new window (no prefix!)
- **C-\**: Split horizontal (no prefix!)
- **C-Arrow**: Navigate panes (no prefix!)
- **S-Left/Right**: Switch windows (no prefix!)

FZF scripts require the prefix:
- **C-s p**: Pods browser
- **C-s m**: Cluster manager
- **C-s n**: Nodes browser

See slide 11 (Cheatsheet) for complete reference!

## Architecture

The presentation itself is built using tmux:
- Each slide is a separate bash script in `slides/`
- Main controller (`tmux-presentation.sh`) manages session and navigation
- Custom status bar shows slide counter and navigation help
- Uses Gruvbox color scheme consistent with the project

## Manual Cleanup

If you need to exit forcefully:

```bash
tmux kill-session -t tmux-presentation
```

Or run:

```bash
./tmux-presentation.sh --cleanup
```
