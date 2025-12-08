# tmux Workshop Application

Interactive web-based workshop for learning tmux with hands-on terminal practice.

## Features

- **Interactive Terminal**: Real tmux session in the browser via WebSocket
- **Bilingual Guides**: Workshop guides in Portuguese (default) and English
- **fzf Integration**: Pre-configured fzf with tmux popups for enhanced workflow
- **Gruvbox Theme**: Beautiful terminal colors inspired by the Gruvbox color scheme
- **OpenShift Ready**: Deployable to OpenShift or run locally with Podman

## Quick Start

### Run with Podman

```bash
# Build the image
./scripts/build.sh

# Run the container
podman run -it --rm -p 8080:8080 quay.io/chiaretto/tmux-workshop:latest

# Access at http://localhost:8080
```

### Deploy to OpenShift

```bash
# Build and push the image
./scripts/build.sh
podman push quay.io/chiaretto/tmux-workshop:latest

# Deploy to OpenShift
./scripts/deploy.sh

# Or build and deploy in one command
./scripts/build-and-deploy.sh
```

### Undeploy from OpenShift

```bash
./scripts/undeploy.sh
```

## Development

### Prerequisites

- Node.js 22+
- npm or pnpm
- Podman or Docker

### Local Development

```bash
# Install dependencies
npm install
cd server && npm install && cd ..

# Start development server (frontend only)
npm run dev

# Start backend server (in another terminal)
cd server && npm start
```

### Project Structure

```
workshop-app/
├── deploy/                 # OpenShift manifests
├── guides/                 # Workshop guides
│   ├── pt/                 # Portuguese guides
│   └── en/                 # English guides
├── scripts/                # Build and deploy scripts
├── server/                 # Backend Express server
├── src/                    # Frontend React app
│   ├── components/         # React components
│   ├── contexts/           # React contexts (i18n)
│   ├── hooks/              # Custom hooks
│   ├── lib/                # Utilities
│   └── styles/             # CSS styles
├── tmux-config/            # tmux configuration for container
├── Dockerfile              # Container image definition
├── package.json            # Frontend dependencies
└── README.md               # This file
```

## Workshop Content

### Portuguese Guides (default)

1. **Introducao ao tmux** - What is tmux and why use it
2. **Sessoes, Janelas e Paineis** - Core tmux concepts
3. **Navegacao e Atalhos** - Essential shortcuts
4. **Configuracao Personalizada** - Customizing .tmux.conf
5. **Integracao com fzf** - fzf popups and workflows
6. **Exercicios Praticos** - Hands-on practice
7. **Referencia de Atalhos** - Quick reference

### English Guides

Same content translated to English, accessible via language selector.

## Key Shortcuts

| Action | Shortcut |
|--------|----------|
| Prefix key | `Ctrl+s` |
| New window | Click `[+]` in status bar |
| Split horizontal | `Ctrl+\` |
| Split vertical | `Ctrl+s -` |
| Navigate panes | `Ctrl + arrows` |
| Navigate windows | `Shift + arrows` |
| Find files (fzf) | `Ctrl+x` |
| Find URLs (fzf) | `Ctrl+s Tab` |
| Buffers | `Ctrl+s b` |
| Session tree | `Ctrl+s w` |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 8080 | Server port |
| `USE_TMUX` | true | Start terminal with tmux |
| `DEFAULT_LANG` | pt | Default language (pt/en) |
| `GUIDES_DIR` | /app/guides | Path to guides directory |

