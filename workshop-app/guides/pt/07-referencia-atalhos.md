# Referencia de Atalhos

Esta e uma referencia rapida de todos os atalhos do tmux usados neste workshop.

---

## Tecla Prefix

A tecla prefix esta configurada como:

```
Ctrl+s
```

A maioria dos comandos exige pressionar o prefix primeiro.

---

## Sessoes

| Acao | Atalho |
|------|--------|
| Nova sessao | `Ctrl+s N` |
| Listar sessoes | `Ctrl+s s` |
| Renomear sessao | `Ctrl+s .` |
| Desconectar (detach) | `Ctrl+s d` |
| Deletar sessao | `Ctrl+s K` |

---

## Janelas

| Acao | Atalho |
|------|--------|
| Nova janela | Clique em `[+]` na barra |
| Proxima janela | `Shift →` |
| Janela anterior | `Shift ←` |
| Ir para janela N | `Ctrl+s 0-9` |
| Renomear janela | `Ctrl+s ,` |
| Fechar janela | `Ctrl+s k` |
| Lista de janelas | `Ctrl+s w` |
| Mover janela esquerda | `Ctrl+Shift ←` |
| Mover janela direita | `Ctrl+Shift →` |

---

## Paineis - Criar

| Acao | Atalho |
|------|--------|
| Dividir horizontal | `Ctrl+\` |
| Dividir vertical | `Ctrl+s -` |
| Fechar painel | `exit` ou `Ctrl+d` |

---

## Paineis - Navegar

| Acao | Atalho |
|------|--------|
| Painel esquerda | `Ctrl ←` |
| Painel direita | `Ctrl →` |
| Painel acima | `Ctrl ↑` |
| Painel abaixo | `Ctrl ↓` |

---

## Paineis - Redimensionar

| Acao | Atalho |
|------|--------|
| Expandir esquerda | `Alt+Shift ←` |
| Expandir direita | `Alt+Shift →` |
| Expandir cima | `Alt+Shift ↑` |
| Expandir baixo | `Alt+Shift ↓` |

---

## Paineis - Outros

| Acao | Atalho |
|------|--------|
| Zoom (maximizar) | `Ctrl+s z` |
| Trocar com acima | `Alt ↑` |
| Trocar com abaixo | `Alt ↓` |
| Converter em janela | `Ctrl+s !` |
| Sincronizar paineis | `Ctrl+s a` |

---

## Modo Copy

| Acao | Atalho |
|------|--------|
| Entrar modo copy | `Ctrl+s [` |
| Iniciar selecao | `v` |
| Selecao de linha | `V` |
| Selecao bloco | `Ctrl+v` |
| Copiar | `y` ou `Enter` |
| Colar | `Ctrl+s ]` |
| Sair | `Esc` ou `q` |
| Buscar | `/texto` |
| Proxima busca | `n` |
| Busca anterior | `N` |

---

## fzf e Popups

| Acao | Atalho |
|------|--------|
| Buscar arquivos | `Ctrl+x` |
| Ver buffers | `Ctrl+s b` |
| URLs no terminal | `Ctrl+s Tab` |
| Listar sessoes | `Ctrl+s s` |

---

## Historico de Comandos

| Acao | Atalho |
|------|--------|
| Buscar no historico | `Ctrl+r` |

---

## Comandos tmux Uteis

```bash
# Criar sessao (se fora do tmux)
tmux new-session -s nome
tmux new -s nome

# Anexar a sessao (se fora do tmux)
tmux attach -t nome
tmux a -t nome

# Matar servidor tmux (use com cuidado)
tmux kill-server

# Recarregar configuracao
tmux source-file ~/.tmux.conf

# Ver todas as teclas
tmux list-keys

# Ver opcoes
tmux show-options -g
```

---

## Comandos de Buffer

```bash
# Listar buffers
tmux list-buffers

# Ver conteudo do buffer
tmux show-buffer

# Salvar buffer em arquivo
tmux save-buffer /caminho/arquivo.txt

# Carregar arquivo para buffer
tmux load-buffer /caminho/arquivo.txt

# Capturar painel para buffer
tmux capture-pane -p
```

---

## Comandos de Popup

```bash
# Popup simples
tmux display-popup -E "comando"

# Popup com tamanho
tmux display-popup -E -w 80% -h 80% "comando"

# Popup com titulo
tmux display-popup -E -T "Titulo" "comando"
```

---

## Vim no tmux

| Acao | Atalho |
|------|--------|
| Abrir arquivo | `vim arquivo` |
| Salvar | `:w` |
| Sair | `:q` |
| Salvar e sair | `:wq` ou `ZZ` |
| Sair sem salvar | `:q!` |

---

## Dicas Finais

1. **Prefix + ?** - Mostra todos os atalhos do tmux
2. **tmux list-keys** - Lista atalhos no terminal
3. **tmux show-options** - Mostra configuracoes

---

## Proximos Passos

- Explore o arquivo `~/.tmux.conf`
- Crie seus proprios atalhos
- Adicione plugins com TPM
- Customize as cores e status bar

---

> **Parabens!** Voce completou o workshop de tmux!
