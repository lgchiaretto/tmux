# Introducao

Neste guia voce vai aprender os conceitos basicos do tmux e como usar este workshop.

---

## Como Usar Este Workshop

No lado esquerdo voce ve este guia. No lado direito voce tem um terminal real com tmux rodando.

**Siga cada passo** e pratique no terminal.

---

## Passo 1: Encontre a Barra de Status

Olhe na parte inferior do terminal. Voce vera uma barra assim:

```
[workshop] bash [+] |              [ tmux workshop ]
```

Esta e a **barra de status do tmux**. Ela mostra:

- `[workshop]` - Nome da sessao
- `bash` - Janela atual
- `[+]` - Botao para criar nova janela

---

## Passo 2: Encontre o Botao [+]

Na barra de status, procure o botao **[+]** verde.

Este botao cria uma nova janela. Clique nele agora!

**O que aconteceu:** Uma nova janela foi criada. Note que apareceu outra aba na barra.

---

## Passo 3: Entenda a Tecla Prefix

O tmux usa uma tecla especial chamada **prefix**. Neste workshop, o prefix e:

```
Ctrl+s
```

A maioria dos comandos tmux segue este padrao:
1. Pressione `Ctrl+s` (prefix)
2. Solte
3. Pressione a tecla do comando

---

## Passo 4: Navegue Entre Janelas

Agora que voce tem 2 janelas, vamos navegar:

| Acao | Atalho |
|------|--------|
| Proxima janela | `Shift →` |
| Janela anterior | `Shift ←` |
| Janela por numero | `Ctrl+s` depois `0-9` |

**Pratique:** Use `Shift →` e `Shift ←` para alternar entre janelas.

---

## Passo 5: Entenda a Hierarquia

O tmux organiza o trabalho em:

```
Servidor
  └── Sessao (workshop)
       └── Janela (como abas do navegador)
            └── Painel (divisoes da tela)
```

- **Sessao**: Um ambiente de trabalho
- **Janela**: Uma tela dentro da sessao
- **Painel**: Divisoes de uma janela

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

---

## Passo 7: Renomeie a Janela

Para renomear a janela atual:

```
Ctrl+s  depois  ,
```

Digite um novo nome e pressione Enter.

**Pratique:** Renomeie uma janela para "codigo" e outra para "logs".

---

## Passo 8: Veja Todas as Janelas

Para ver todas as janelas em uma lista:

```
Ctrl+s  depois  w
```

Use as setas para navegar e Enter para selecionar.

---

## Dica Importante

> Atalhos do navegador como Ctrl+T e Ctrl+W sao bloqueados.
> Use o botao **[+]** e os comandos do tmux para gerenciar janelas.

---

## Proximo Guia

[→ 02 - Sessoes e Janelas](02-sessoes-janelas.md)

---

> **Dica:** O terminal a direita e real! Tudo que voce digita e executado.
