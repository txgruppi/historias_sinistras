# 07: Zerar progresso

**What to build:** After the rows, the player can erase every pasta back to Novo. Nothing is erased until they confirm, and there is no wait. A filter that is still on keeps meaning what it says.

**Blocked by:** 06: Filtrar the list

**Status:** done

- [x] "Zerar progresso" sits after the rows.
- [x] It offers "Confirmar" and "Cancelar" on the list, with no wait and no extra route.
- [x] "Cancelar" leaves every pasta as it was.
- [x] "Confirmar" returns every pasta to Novo: capas unturned, dicas shut, verdades shut, marks cleared.
- [x] Reload after "Confirmar" still shows every pasta Novo.
- [x] If a Resolvido filter is still active after "Confirmar", the list says nothing matches until "Limpar".

## Comments

Supervisor: the confirm step is `Visita`, not `Filtro` and not progresso. "Zerar progresso" is `controlesAposLinhas`, after the rows. "Confirmar" sets progresso to `Dict.empty` and leaves the filter. A Resolvido filter then shows "Nenhuma pasta corresponde ao filtro." "Cancelar" leaves progresso and the filter. `elm-test` passed 53.
