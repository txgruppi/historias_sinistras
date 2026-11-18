# 06: Filtrar the list

**What to build:** The player narrows the list by state, categoria, and dificuldade at once, sees that a filter is on, and gets the full list back with "Limpar". The filter survives opening a pasta and is gone after reload. It is not progresso.

**Blocked by:** 02: Revelar dica; 03: Revelar a verdade; 04: Marcar como resolvido

**Status:** done

- [x] Como jogar and Créditos are not required here. Under the title, one Filtrar control comes before the rows. State, categoria, and dificuldade are not stacked above the rows.
- [x] A pasta appears only when it matches every set filter. The remaining rows stay in id order.
- [x] The active filter stays visible. "Limpar" restores all 60 pastas.
- [x] When nothing matches, the list says so.
- [x] Opening a pasta and returning with "Lista" keeps the filter until the page is reloaded.
- [x] Reload clears the filter and keeps progresso.
- [x] An Em andamento row inside a filtered list still shows "N dicas" and, when open, "verdade".

## Comments

Supervisor: `Filtro` is a separate input and output of `Office.update`. `Main` keeps it and does not pass it to `progressoSalvar`. A reload starts from `filtroVazio`. Rows match estado, categoria, and dificuldade together, in id order. The resting list shows "Filtrar"; the choices sit in the panel that control opens. An empty result says "Nenhuma pasta corresponde ao filtro." `elm-test` passed 46.
