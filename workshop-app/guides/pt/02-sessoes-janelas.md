# Sessões e Janelas

Neste guia você vai aprender a gerenciar sessões e janelas no tmux.

---

## O que e uma Sessão?

Uma sessão e um ambiente completo do tmux contendo:

- Uma ou mais janelas
- Estado persistente (mesmo se você desconectar)
- Seu próprio histórico de buffer

---

## Passo 1: Liste as Sessões

Pressione:

```
Ctrl+s  depois  s
```

você verá a sessão atual destacada na lista.

---

## Passo 2: Crie uma Nova Sessão

Pressione:

```
Ctrl+s  depois  N
```

Digite "dev" e pressione Enter.

Isso cria uma nova sessão chamada "dev".

---

## Passo 3: Troque de Sessão

Use o atalho:

```
Ctrl+s  depois  s
```

Uma lista de sessões aparece. Use as setas para selecionar e Enter para trocar.

---

## Passo 4: Volte para a Sessão Original

Use `Ctrl+s s` novamente e selecione "workshop".

---

## Passo 5: Volte para a Sessão dev

Use `Ctrl+s s` novamente e selecione "dev".

---

## Passo 6: Renomeie a Sessão

```
Ctrl+s  depois  .
```

Digite "delete-dev" e pressione Enter.

## Passo 7: Delete uma Sessão

Para remover a sessão "delete-dev":

```
Ctrl+s  depois  K
```

Verifique se esta usando a sessão "delete-dev" e confirme com `y`.

**Aviso:** Isso fecha todas as janelas e processos dessa sessão!

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

Confirme com `y`. Esse método é bom quando você executa um comando e trava o terminal.

---

## Passo 9: Pratique o Fluxo Completo

Execute esta sequencia:

1. Crie uma sessão:
   ```
   Ctrl+s  depois  N
   ```
   Digite "teste" e pressione Enter.

2. Liste as sessões:
   ```
   Ctrl+s  depois  s
   ```

3. Troque para a nova sessão selecionando-a da lista.

4. Crie duas janelas usando **[+]**

5. Renomeie uma janela:
   ```
   Ctrl+s  depois  ,
   ```
   Digite "janela-1" e pressione Enter.

5. Use `Shift →` e `Shift ←` para alternar entre janelas e mude o nome da outra janela para `janela-2`
   ```
   Ctrl+s  depois  ,
   ```
   Digite "janela-2" e pressione Enter.


6. Delete a sessão de teste:
   ```
   Ctrl+s  depois  K
   ```
   Confirme com `y`.

---

## Resumo de Atalhos

| Acao | Atalho |
|------|--------|
| Criar sessão | `Ctrl+s N` |
| Listar sessões | `Ctrl+s s` |
| Trocar sessão | `Ctrl+s s` |
| Renomear sessão | `Ctrl+s .` |
| Desconectar | `Ctrl+s d` |
| Deletar sessão | `Ctrl+s K` |

**Nota:** Se estiver fora do tmux, use `tmux a` para conectar a uma sessão.

---

## Próximo Guia

[→ 03 - Paineis](03-paineis.md)

---

> **Dica:** Sessões são perfeitas para separar projetos, contextos ou clusters OpenShift!
