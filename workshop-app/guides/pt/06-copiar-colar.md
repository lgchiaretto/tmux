# Copiar e Colar

Neste guia voce vai aprender a usar o modo copy do tmux para copiar texto.

---

## Conceitos Importantes

O tmux tem seu proprio sistema de copiar/colar:

- **Modo Copy:** Navegacao e selecao de texto
- **Buffer:** Armazena o texto copiado
- **Paste:** Cola do buffer do tmux

---

## Passo 1: Entre no Modo Copy

Pressione:

```
Ctrl+s  depois  [
```

**O que muda:**
- Voce pode navegar pelo historico
- O cursor se move livremente
- Aparece `[0/0]` no canto (posicao no buffer)

---

## Passo 2: Navegue no Modo Copy

Use estas teclas para navegar:

| Tecla | Acao |
|-------|------|
| `Setas` | Move o cursor |
| `Page Up/Down` | Sobe/desce uma pagina |
| `g` | Vai para o inicio |
| `G` | Vai para o fim |
| `/` | Busca para frente |
| `?` | Busca para tras |
| `n` | Proxima ocorrencia |
| `N` | Ocorrencia anterior |

**Pratique:** Entre no modo copy e navegue pelo historico.

---

## Passo 3: Selecione Texto

Para iniciar a selecao:

```
Pressione  v
```

**Modos de selecao:**
- `v` - Selecao normal (caractere a caractere)
- `V` - Selecao de linha inteira
- `Ctrl+v` - Selecao em bloco (retangular)

Mova o cursor para expandir a selecao.

---

## Passo 4: Copie o Texto

Apos selecionar, pressione:

```
y
```

Isso copia para o buffer do tmux e sai do modo copy.

**Ou use:** `Enter` tambem copia e sai.

---

## Passo 5: Cole o Texto

Para colar:

```
Ctrl+s  depois  ]
```

O texto do buffer e inserido na posicao atual.

---

## Passo 6: Pratique o Fluxo Completo

Execute este comando para ter texto:

```bash
echo -e "Linha 1: Primeiro texto\nLinha 2: Segundo texto\nLinha 3: Terceiro texto"
```

Agora:
1. `Ctrl+s [` - Entre no modo copy
2. Navegue ate "Segundo"
3. `v` - Inicie selecao
4. Selecione "Segundo texto"
5. `y` - Copie
6. `Ctrl+s ]` - Cole

---

## Passo 7: Copie Linha Inteira

Metodo rapido para copiar linha:

1. `Ctrl+s [` - Modo copy
2. Va ate a linha desejada
3. `V` - Selecao de linha
4. `y` - Copia

---

## Passo 8: Use a Busca

Para encontrar texto especifico:

1. `Ctrl+s [` - Modo copy
2. `/texto` - Busca "texto"
3. `Enter` - Confirma
4. `n` / `N` - Proxima/anterior

**Pratique:** Busque por uma palavra na tela.

---

## Passo 9: Acesse Buffers Anteriores

O tmux guarda um historico de copias. Para acessar:

```
Ctrl+s  depois  b
```

Isso abre o popup fzf com todos os buffers.

**Ou manualmente:**

```bash
tmux list-buffers
tmux show-buffer -b buffer0
```

---

## Passo 10: Copie para Arquivo

Salve o buffer em um arquivo:

```bash
tmux save-buffer /tmp/copiado.txt
cat /tmp/copiado.txt
```

---

## Passo 11: Copie de Arquivo para Buffer

Carregue texto de arquivo para o buffer:

```bash
echo "Texto do arquivo" > /tmp/origem.txt
tmux load-buffer /tmp/origem.txt
```

Agora `Ctrl+s ]` cola esse texto.

---

## Passo 12: Modo Copy com Mouse

Se o mouse estiver habilitado:

1. Clique e arraste para selecionar
2. Solte para copiar automaticamente
3. Clique do meio para colar

---

## Dicas Avancadas

### Copiar Saida de Comando

```bash
# Copia a saida do ultimo comando para o buffer
tmux capture-pane -p | tmux load-buffer -
```

### Copiar Painel Inteiro

```bash
# Captura todo o historico do painel
tmux capture-pane -p -S - | tmux load-buffer -
```

### Pipe para Comando

```bash
# Copia e processa
tmux save-buffer - | grep "erro"
```

---

## Atalhos Resumidos

| Acao | Atalho |
|------|--------|
| Entrar modo copy | `Ctrl+s [` |
| Iniciar selecao | `v` |
| Selecao de linha | `V` |
| Selecao em bloco | `Ctrl+v` |
| Copiar | `y` ou `Enter` |
| Colar | `Ctrl+s ]` |
| Sair do modo copy | `Esc` ou `q` |
| Ver buffers | `Ctrl+s b` |

---

## Proximo Guia

[→ 07 - Referencia de Atalhos](07-referencia-atalhos.md)

---

> **Dica:** O modo copy e essencial para extrair logs e saidas de comandos!
