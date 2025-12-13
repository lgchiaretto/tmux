# Introducao

Neste guia você vai aprender os conceitos básicos do tmux e como usar este workshop.

---

## Como Usar Este Workshop

No lado esquerdo você ve este guia. No lado direito você tem um terminal real com tmux rodando.

**Siga cada passo** e pratique no terminal.

---


## Passo 1: Entenda a Tecla Prefix

O tmux usa uma tecla especial chamada **prefix**. Neste workshop, o prefix não é mais `Ctrl-b` mas sim `Ctrl+s`

---

## Passo 2: Encontre a Barra de Status

Olhe na parte inferior do terminal. você verá uma barra assim:

```
[workshop] /home/default [+] |              [ tmux workshop ]
```

Esta é a **barra de status do tmux**. Ela mostra:

- `[workshop]` - Nome da sessão
- `/home/default` - Janela atual
- `[+]` - botão para criar nova janela

---

A maioria dos comandos tmux segue este padrao:
1. Pressione `Ctrl+s` (prefix)
2. Solte
3. Pressione a tecla do comando

---

## Passo 3: Encontre o Botão [+]

Na barra de status, procure o botão **[+]** verde.

Este botão cria uma nova janela. Clique nele agora!

**O que aconteceu:** Uma nova janela foi criada. Note que apareceu outra aba (janela) na barra.

---

## Passo 4: Navegue Entre Janelas

Agora que você tem 2 janelas, vamos navegar:

| Acao | Atalho |
|------|--------|
| Próxima janela | `Shift →` |
| Janela anterior | `Shift ←` |
| Janela por numero | `Ctrl+s` depois `0-9` |

**Pratique:** Use `Shift →` e `Shift ←` para alternar entre janelas.

---

## Passo 5: Entenda a Hierarquia

O tmux organiza o trabalho em:

```
Sessão (workshop)
       └── Janela (como abas do navegador)
            └── Painel (divisões da tela)
```

- **Sessão**: Um ambiente de trabalho
- **Janela**: Uma tela dentro da sessão
- **Painel**: Divisões de uma janela

---

## Passo 6: Seus Primeiros Comandos

No terminal, digite:

```bash
echo "Ola tmux!"
```

Agora crie outra janela com **[+]** e execute:

```bash
ls -la
```

Use `Shift ←` para voltar a primeira janela.

Digite `exit` ou pressione `ctrl+d` para fechar a janela

---

## Passo 7: Renomeie a Janela

Para renomear a janela atual:

```
Ctrl+s  depois  ,
```

Digite um novo nome e pressione Enter.

**Pratique:** Renomeie uma janela para "codigo".

---

## Passo 8: Veja Todas as Janelas

Para ver todas as janelas em uma lista:

```
Ctrl+s  depois  w
```

Use as setas para navegar e Enter para selecionar.

---

## Passo 9: Veja todas as sessões

Para ver todas as sessões em uma lista:

```
Ctrl+s  depois  s
```

## Dica Importante

> Use o botão **[+]** e os comandos do tmux para gerenciar janelas.

---

## Próximo Guia

[→ 02 - Sessoes e Janelas](02-sessoes-janelas.md)

---

