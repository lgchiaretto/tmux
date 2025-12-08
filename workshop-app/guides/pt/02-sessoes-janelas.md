# Sessoes e Janelas

Neste guia voce vai aprender a gerenciar sessoes e janelas no tmux.

---

## O que e uma Sessao?

Uma sessao e um ambiente completo do tmux contendo:

- Uma ou mais janelas
- Estado persistente (mesmo se voce desconectar)
- Seu proprio historico de buffer

---

## Passo 1: Liste as Sessoes

Pressione:

```
Ctrl+s  depois  s
```

Voce vera a sessao atual destacada na lista.

---

## Passo 2: Crie uma Nova Sessao

Pressione:

```
Ctrl+s  depois  N
```

Digite "dev" e pressione Enter.

Isso cria uma nova sessao chamada "dev".

---

## Passo 3: Troque de Sessao

Use o atalho:

```
Ctrl+s  depois  s
```

Uma lista de sessoes aparece. Use as setas para selecionar e Enter para trocar.

---

## Passo 4: Volte para a Sessao Original

Use `Ctrl+s s` novamente e selecione "workshop".

---

## Passo 5: Volte para a Sessao dev

Use `Ctrl+s s` novamente e selecione "dev".

---

## Passo 6: Delete uma Sessao

Para remover a sessao "dev":

```
Ctrl+s  depois  K
```

Verifique se esta usando a sessao "dev" e confirme com `y`.

**Aviso:** Isso fecha todas as janelas e processos dessa sessao!

---

## Passo 7: Renomeie a Sessao

```
Ctrl+s  depois  .
```

Digite o novo nome e pressione Enter.

---

## Passo 8: Gerenciamento de Janelas

### Criando Janelas

Use o botao **[+]** na barra de status.

### Fechando Janelas

Digite `exit` na janela ou pressione `Ctrl+d`.

Ou use:

```
Ctrl+s  depois  k
```

Confirme com `y`.

---

## Passo 9: Pratique o Fluxo Completo

Execute esta sequencia:

1. Crie uma sessao:
   ```
   Ctrl+s  depois  N
   ```
   Digite "teste" e pressione Enter.

2. Liste as sessoes:
   ```
   Ctrl+s  depois  s
   ```

3. Troque para a nova sessao selecionando-a da lista.

4. Crie uma janela usando **[+]**

5. Renomeie a janela:
   ```
   Ctrl+s  depois  ,
   ```

6. Delete a sessao de teste:
   ```
   Ctrl+s  depois  K
   ```
   Confirme com `y`.

---

## Resumo de Atalhos

| Acao | Atalho |
|------|--------|
| Criar sessao | `Ctrl+s N` |
| Listar sessoes | `Ctrl+s s` |
| Trocar sessao | `Ctrl+s s` |
| Renomear sessao | `Ctrl+s .` |
| Desconectar | `Ctrl+s d` |
| Deletar sessao | `Ctrl+s K` |

**Nota:** Se estiver fora do tmux, use `tmux a` para conectar a uma sessao.

---

## Proximo Guia

[→ 03 - Paineis](03-paineis.md)

---

> **Dica:** Sessoes sao perfeitas para separar projetos ou contextos!
