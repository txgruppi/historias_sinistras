# 01: List, capa, and cenário

**What to build:** A player opens Histórias Sinistras, sees the 60 pastas, chooses a Novo row, reads the capa, turns it with "Ler o caso", and reads the cenário. Coming back opens the cenário, not the capa. Leaving and reloading keeps that.

**Blocked by:** None (can start immediately).

**Status:** done

- [x] The list is titled Histórias Sinistras and shows pastas 1 through 60 in id order.
- [x] Each row shows número, título, categoria, dificuldade, and Novo.
- [x] Choosing a row opens that pasta. A Novo pasta shows the capa: número, título, categoria, dificuldade, and "Ler o caso".
- [x] "Ler o caso" shows the cenário with no animation, and the pasta becomes Em andamento.
- [x] A later visit to an Em andamento pasta opens on the cenário. The capa is not shown again.
- [x] The cenário page shows número, título, categoria, and dificuldade above the cenário, and the cenário stays readable.
- [x] "Lista" returns to the list.
- [x] `#/` is the list and `#/caso/<id>` is that pasta. An id outside 1–60 shows the list.
- [x] Reload keeps Novo and Em andamento.
- [x] The page is one column of warm off-white paper in large black Special Elite with a short measure. A wide window only adds margin.
- [x] There is no animation and no sound.
- [x] The casos' words are the shipped set of 60, unchanged.

## Comments

Checked in the browser at `site/`: 60 rows, capa, Ler o caso, reload, return to an Em andamento cenário, and `#/caso/99` shows the list. `elm-test` passed 7. The bad hash stays in the address bar while the list is shown.
