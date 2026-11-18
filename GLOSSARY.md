# Histórias Sinistras

A Brazilian Portuguese mystery game. The player explains what happened in a caso. Up to four dicas are available, and the verdade stays shut until the player opens it.

## Language

**Caso**:
A single mystery with a stable id, a título, a categoria, a dificuldade, a cenário, four dicas, and one verdade.
_Avoid_: fase, level, episódio

**Pasta**:
The file a player opens for one caso. The player chooses it from the list.
_Avoid_: case file, dossiê, tela, continuar

**Capa**:
The first page of a Novo pasta. It carries the número, the título, the categoria, and the dificuldade. One control shows the cenário, and no animation plays. A later visit does not show it again.
_Avoid_: splash, abertura, intro

**Novo**:
A pasta whose capa the player has not turned. Opening it shows the capa.
_Avoid_: aberto, fechado, lacrado

**Em andamento**:
A pasta whose cenário has been shown and that the player has not marked resolvido. Opening it shows the cenário.
_Avoid_: aberto, iniciado

**Cenário**:
The text the player reads first. It states what is strange and ends in the question they have to answer.
_Avoid_: premissa, sinopse, briefing

**Dica**:
One clue in a caso. The four dicas open in order, one player action at a time, and an open dica stays readable.
_Avoid_: hint, tip

**Verdade**:
The explanation of what actually happened in a caso. Opening it leaves the caso unmarked.
_Avoid_: solução, final, resposta certa

**Resolvido**:
The player's own mark that they solved a pasta. They set or clear it from the cenário page only. Clearing it returns the pasta to Em andamento. Opening the verdade does not set the mark.
_Avoid_: completo, concluído, encerrado, zerado

**Categoria**:
Which kind of mystery a caso is. One of Assassinatos, Crimes Impossíveis, Mortes Misteriosas, Desaparecimentos, Segredos Macabros, Mistérios Psicológicos, Acidentes Fatais.
_Avoid_: gênero, tag, tema

**Dificuldade**:
How hard a caso is meant to be. One of Fácil, Médio, Difícil, Insano.
_Avoid_: nível, estrelas

**Progresso**:
For each pasta, whether it is Novo, Em andamento, or Resolvido, how many dicas are open, and whether the verdade is open. There is no account. Progresso stays in the browser where it was made.
_Avoid_: save, pontuação, conta

**Zerar progresso**:
The list action that asks with a second control, and no wait, then returns every pasta to Novo.
_Avoid_: reset, apagar conta

**Guardião do Segredo**:
A player who has read the verdade and answers the group only with sim, não, or irrelevante. The office has no separate mode for this role.
_Avoid_: mestre, narrador, host
