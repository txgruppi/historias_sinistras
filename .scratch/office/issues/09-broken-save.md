# 09: A broken save

**What to build:** A save that cannot be read starts the player over with every pasta Novo. Two open tabs do not merge. The later write is the one that remains.

**Blocked by:** 07: Zerar progresso

**Status:** done

- [x] Unreadable progresso opens the list with every pasta Novo.
- [x] With two tabs, the last write wins. The other tab's older progresso is gone after reload.
- [x] A filter is still not part of the save.

## Comments

Supervisor: `decodeProgresso` already returns an empty progresso for a string it cannot read, and empty progresso is Novo. A valid `#/caso/<id>` stays on that route, so the pasta opens as Novo instead of being thrown back to the list. That is story 56. The list shows every pasta Novo when that is the route. `site/index.html` writes the whole blob with `localStorage.setItem` and does not listen for other tabs. `Filtro` and `Visita` are not encoded. One save test covers an unreadable string. `elm-test` passed 62.
