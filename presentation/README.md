# Tmux Control Plane Presentation

Interactive presentation about tmux and the OpenShift cluster management system built using tmux itself.

## Quick Start

```bash
./start-presentation.sh
```

The launcher script automatically:
- Makes all slide scripts executable
- Starts the presentation in a dedicated tmux session named `talks-tmux`
- Centers content using Gruvbox color scheme

## Navigation

Once in the presentation:
- **S-Right** (Shift + Right Arrow): Next slide
- **S-Left** (Shift + Left Arrow): Previous slide
- **Prefix + number**: Jump to specific slide (e.g., `C-s 5`)

Navigation uses the same keybindings as tmux window navigation for consistency.

## Presentation Outline

1. **Introduction** - Overview, agenda, and learning objectives
2. **What is tmux?** - Terminal multiplexer concepts and benefits
3. **Tmux Basics** - Sessions, windows, panes, and core keybindings
4. **Tmux Configuration** - Custom prefix (C-s), status bar, and settings
5. **Project Overview** - Architecture and component layers
6. **FZF Integration** - Interactive menus and resource browsers
7. **Bash Customization** - Custom prompt, functions, and environment variables
8. **Resource Browsers** - OpenShift pod/node/operator management workflows
9. **Live Demo** - Hands-on demonstration of key features
10. **Conclusion** - Summary and getting started guide
11. **Questions** - Q&A and additional resources

## Key Features

### Presentation Architecture
- **Session-based**: Runs in dedicated `talks-tmux` session (isolated from other work)
- **Window-per-slide**: Each slide is a tmux window with descriptive name
- **Centered display**: Custom centering logic via `lib/center-content.sh`
- **Color scheme**: Gruvbox theme matching the main project
- **Status bar**: Clean top-positioned status with minimal distractions used only in this presentation. By default the status bar is in the bottom.

### Important Keybindings Covered

Keybindings **without prefix** (C-s):
- **C-t**: Create new window
- **C-s -**: Horizontal split
- **C-Arrow**: Navigate between panes
- **S-Left/Right**: Switch between windows

Keybindings **with prefix** (C-s first):
- **C-s p**: FZF pods browser
- **C-s m**: FZF cluster manager
- **C-s n**: FZF nodes browser
- **C-s o**: FZF operators browser
- **C-s Shift-p**: FZF projects browser

See slide 11 for complete keybinding reference.

## Technical Details

### File Structure
```
presentation/
├── start-presentation.sh          # Entry point launcher
├── tmux-presentation.sh           # Session controller
├── lib/
│   └── center-content.sh          # Content centering utility
└── slides/
    ├── 01-intro.sh                # Slide scripts (executable)
    ├── 02-what-is-tmux.sh
    └── ...
```

### Slide Script Pattern
Each slide follows this structure:
1. Source centering helper from `lib/center-content.sh`
2. Clear screen
3. Generate ANSI-colored content using Gruvbox palette
4. Pipe through `center_content` function
5. Execute clean bash shell with empty PS1

### Color Palette (Gruvbox)
- **Title**: `\033[38;5;214m` (Orange)
- **Subtitle**: `\033[38;5;142m` (Green)
- **Text**: `\033[38;5;223m` (Light beige)
- **Highlight**: `\033[38;5;208m` (Bright orange)
- **Links**: `\033[38;5;109m` (Blue-gray)

## Session Management

### Starting Presentation
```bash
# From presentation directory
./start-presentation.sh

# Or directly
./tmux-presentation.sh
```

### Exiting Presentation
- **Normal exit**: Navigate through all slides or detach with `C-s d`
- **Force kill**: Run cleanup command below

### Cleanup Session
```bash
# Manual cleanup
tmux kill-session -t talks-tmux

# Or use built-in cleanup
./tmux-presentation.sh --cleanup
```

## Integration with Main Project

The presentation demonstrates:
- **FZF integration patterns** from `fzf-files/` scripts
- **Cluster management workflows** using `fzf-manageclusters.sh`
- **Resource browsers** for OpenShift pods, nodes, operators
- **Bash customization** from `dotfiles/bashrc` and `dotfiles/bash_functions`
- **Tmux configuration** from `dotfiles/tmux.conf`

Live demo (slide 9) showcases real cluster operations when OpenShift environment is available.

## Prerequisites

- **tmux** installed (version 3.4+)
- **bash** shell
- Terminal with 256-color support

Optional for full demo:
- OpenShift cluster access
- FZF installed (`~/.fzf/install`)
- Project configured via `../configure-local.sh`

## Customization

To modify slides:
1. Edit scripts in `slides/` directory
2. Follow existing color scheme and centering pattern
3. Test with `bash slides/XX-name.sh` before running full presentation
4. Reload presentation to see changes
