# Paineis

Neste guia voce vai aprender a dividir a tela em paineis e navegar entre eles.

---

## Passo 1: Divida Horizontalmente

Pressione:

```
Ctrl + \
```

Isso divide a janela atual em dois paineis lado a lado.

---

## Passo 2: Divida Verticalmente

Pressione:

```
Ctrl+s  depois  -
```

Isso divide o painel atual em dois, um acima do outro.

---

## Passo 3: Pratique as Divisoes

Crie uma estrutura assim:

```
+─────────+─────────+
|         |         |
|    1    |    2    |
|         +─────────+
|         |    3    |
+─────────+─────────+
```

**Passos:**
1. `Ctrl+\` para dividir horizontalmente
2. Va para o painel da direita
3. `Ctrl+s` depois `-` para dividir verticalmente

---

## Passo 4: Navegue entre Paineis

Use as setas com Ctrl:

| Acao | Atalho |
|------|--------|
| Painel a esquerda | `Ctrl ←` |
| Painel a direita | `Ctrl →` |
| Painel acima | `Ctrl ↑` |
| Painel abaixo | `Ctrl ↓` |

**Pratique:** Navegue entre todos os paineis que voce criou.

---

## Passo 5: Redimensione Paineis

Use Alt+Shift+Setas:

| Acao | Atalho |
|------|--------|
| Aumentar para esquerda | `Alt+Shift ←` |
| Aumentar para direita | `Alt+Shift →` |
| Aumentar para cima | `Alt+Shift ↑` |
| Aumentar para baixo | `Alt+Shift ↓` |

---

## Passo 6: Mova Paineis

Troque a posicao dos paineis:

| Acao | Atalho |
|------|--------|
| Trocar com painel acima | `Alt ↑` |
| Trocar com painel abaixo | `Alt ↓` |

---

## Passo 7: Zoom em um Painel

Para maximizar um painel temporariamente:

```
Ctrl+s  depois  z
```

Pressione novamente para voltar ao layout original.

**Util para:** Ver logs ou saidas longas em tela cheia.

---

## Passo 8: Feche um Painel

Para fechar o painel atual, simplesmente digite:

```bash
exit
```

Ou pressione `Ctrl+d`.

---

## Passo 9: Sincronize Paineis

Para digitar em todos os paineis ao mesmo tempo:

```
Ctrl+s  depois  a
```

Isso ativa/desativa o modo sincronizado. Util para executar comandos em varios servidores.

---

## Passo 10: Converta Painel em Janela

Para transformar um painel em uma nova janela:

```
Ctrl+s  depois  !
```

---

## Layout Sugerido para Desenvolvimento

```
+─────────────────────────────+
|           Editor            |
+──────────────+──────────────+
|    Logs      |   Terminal   |
+──────────────+──────────────+
```

**Monte esse layout:**
1. `Ctrl+s` depois `-` (divide vertical)
2. Va para o painel de baixo
3. `Ctrl+\` (divide horizontal)

---

## Proximo Guia

[→ 04 - Integracao com fzf](04-fzf-integracao.md)

---

> **Dica:** Use paineis para monitorar logs enquanto trabalha no codigo!
