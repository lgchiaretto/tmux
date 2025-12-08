# Integracao com fzf

Neste guia voce vai aprender a usar popups fzf dentro do tmux para navegacao rapida.

---

## O que e fzf?

fzf e um fuzzy finder - uma ferramenta de busca interativa que filtra listas rapidamente.

Combinado com tmux, ele abre em popups elegantes sobre sua sessao.

---

## Passo 1: Busca de Arquivos

Pressione:

```
Ctrl+x
```

**O que acontece:**
- Abre um popup com todos os arquivos do diretorio
- Digite para filtrar
- Enter para abrir no vim
- Esc para cancelar

**Pratique:** Abra o popup e busque por "bashrc".

---

## Passo 2: Navegue Sessoes tmux

```
Ctrl+s  depois  s
```

**O que acontece:**
- Lista todas as sessoes
- Preview da sessao no lado direito
- Navegue e selecione para trocar

**Pratique:** 
1. Crie uma nova sessao: `Ctrl+s N` e nomeie como "teste"
2. Use `Ctrl+s s` para ver e alternar

---

## Passo 3: Gerenciador de Buffers

```
Ctrl+s  depois  b
```

**O que acontece:**
- Lista buffers do tmux (historico de copias)
- Selecione para colar
- Util para acessar copias anteriores

---

## Passo 4: URLs no Terminal

```
Ctrl+s  depois  Tab
```

**O que acontece:**
- Extrai todas as URLs visiveis no terminal
- Selecione para abrir no navegador
- Util para links em logs ou saidas

---

## Passo 5: Historico de Comandos

Dentro do terminal, pressione:

```
Ctrl+r
```

**O que acontece:**
- Busca no historico de comandos
- Digite para filtrar
- Enter para executar

---

## Scripts fzf Disponiveis

| Atalho | Funcao |
|--------|--------|
| `Ctrl+x` | Busca de arquivos |
| `Ctrl+s b` | Buffers do tmux |
| `Ctrl+s Tab` | URLs no terminal |
| `Ctrl+s s` | Sessoes tmux |

---

## Passo 6: Execute um Script Manualmente

Voce pode executar scripts fzf diretamente:

```bash
# Listar arquivos
/usr/local/share/tmux-ocp/fzf-files/fzf-files.sh

# Ver buffers
/usr/local/share/tmux-ocp/fzf-files/fzf-buffer.sh
```

---

## Criando seu Proprio Script fzf

Estrutura basica de um script fzf com popup:

```bash
#!/bin/bash
# Gera lista | fzf com opcoes | processa selecao

ls -la | fzf --preview 'file {}' | xargs echo "Selecionado:"
```

Para abrir em popup tmux:

```bash
tmux display-popup -E -w 80% -h 80% "seu-script.sh"
```

---

## Proximo Guia

[→ 05 - Popups e Scripts](05-popups-scripts.md)

---

> **Dica:** fzf + tmux popup = produtividade instantanea!
