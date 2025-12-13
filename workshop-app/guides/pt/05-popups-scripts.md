# Popups e Scripts

Neste guia você vai aprender a usar e criar popups customizados no tmux.

---

## O que sao Popups?

Popups sao janelas flutuantes sobre sua sessão tmux. Eles:

- Nao atrapalham seu layout
- Fecham automaticamente apos uso
- Sao perfeitos para tarefas rapidas

---

## Passo 1: Popup Simples

Execute este comando:

```bash
tmux display-popup -E "echo 'Ola do popup!' && sleep 2"
```

**O que acontece:**
- Um popup abre sobre a tela
- Mostra a mensagem
- Fecha apos 2 segundos

---

## Passo 2: Popup Interativo

Abra um shell em popup:

```bash
tmux display-popup -E -w 80% -h 80% "bash"
```

**Opcoes usadas:**
- `-E` - Fecha ao sair
- `-w 80%` - Largura de 80%
- `-h 80%` - Altura de 80%

Digite `exit` para fechar.

---

## Passo 3: Popup com fzf

Combine popup com fzf:

```bash
tmux display-popup -E -w 80% -h 60% "find . -type f | fzf"
```

**Pratique:** Selecione um arquivo e veja o caminho retornado.

---

## Passo 4: Popup Nomeado

Popups podem ter nomes e serem reabertos:

```bash
# Criar popup nomeado
tmux display-popup -E -d "#{pane_current_path}" -w 80% -h 80% -T "Meu Terminal"
```

**Opcao `-T`:** Define o titulo do popup.

---

## Passo 5: Crie um Script de Popup

Vamos criar um script para buscar em arquivos:

```bash
cat > /tmp/buscar.sh << 'EOF'
#!/bin/bash
# Busca interativa em arquivos

FILE=$(find . -type f -name "*.sh" 2>/dev/null | fzf --preview 'head -50 {}')

if [ -n "$FILE" ]; then
    vim "$FILE"
fi
EOF
chmod +x /tmp/buscar.sh
```

Execute com popup:

```bash
tmux display-popup -E -w 90% -h 80% "/tmp/buscar.sh"
```

---

## Passo 6: Popup para Monitoramento

Crie um popup de monitoramento:

```bash
tmux display-popup -E -w 60% -h 40% "htop || top"
```

Pressione `q` para sair.

---

## Passo 7: Popup com Preview

fzf com preview em popup:

```bash
tmux display-popup -E -w 90% -h 80% \
  "ls -la | fzf --preview 'cat {} 2>/dev/null || ls -la {}'"
```

---

## Passo 8: Adicione Atalho no tmux.conf

Para criar um atalho permanente, adicione ao `~/.tmux.conf`:

```bash
# Popup para htop
bind-key h display-popup -E -w 80% -h 80% "htop || top"
```

Depois recarregue:

```bash
tmux source-file ~/.tmux.conf
```

Agora `Ctrl+s h` abre htop em popup!

---

## Scripts de Popup Uteis

### Calculadora

```bash
tmux display-popup -E -w 40% -h 30% "bc -l"
```

### Git Status

```bash
tmux display-popup -E -w 80% -h 60% "git status && read -p 'Pressione Enter...'"
```

### Docker/Podman

```bash
tmux display-popup -E -w 90% -h 80% \
  "docker ps | fzf --header-lines=1 | awk '{print \$1}' | xargs docker logs -f"
```

---

## Anatomia do display-popup

```bash
tmux display-popup [opcoes] [comando]
```

| Opcao | Descricao |
|-------|-----------|
| `-E` | Fecha ao sair do comando |
| `-w LARGURA` | Define largura (%, ou numero de colunas) |
| `-h ALTURA` | Define altura (%, ou numero de linhas) |
| `-x POS` | Posicao horizontal |
| `-y POS` | Posicao vertical |
| `-d DIR` | Diretorio inicial |
| `-T TITULO` | Titulo do popup |

---

## Passo 9: Popup como Menu

Crie um menu interativo:

```bash
cat > /tmp/menu.sh << 'EOF'
#!/bin/bash

OPCAO=$(echo -e "1. Ver processos\n2. Ver memoria\n3. Ver disco\n4. Sair" | \
        fzf --header "Selecione uma opcao:")

case "$OPCAO" in
    "1. Ver processos") ps aux | head -20 ;;
    "2. Ver memoria") free -h ;;
    "3. Ver disco") df -h ;;
esac

read -p "Pressione Enter para fechar..."
EOF
chmod +x /tmp/menu.sh
```

Execute:

```bash
tmux display-popup -E -w 60% -h 50% "/tmp/menu.sh"
```

---

## Próximo Guia

[→ 06 - Copiar e Colar](06-copiar-colar.md)

---

> **Dica:** Popups sao perfeitos para tarefas que nao precisam de painel permanente!
