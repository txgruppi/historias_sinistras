# 02: Revelar dica

**What to build:** On the cenário, the player opens dicas one at a time, in order, and they stay readable. The list shows how many are open. Reload keeps them.

**Blocked by:** 01: List, capa, and cenário

**Status:** done

- [x] "Revelar dica" sits in a bar fixed to the bottom of the cenário page and opens only the next dica.
- [x] A later dica cannot appear before an earlier one. Open dicas stay on the page in order, after the cenário.
- [x] After the fourth dica, "Revelar dica" leaves the bar.
- [x] An Em andamento row shows the count as "2 dicas". A Novo row does not.
- [x] Opening a dica does not mark the pasta Resolvido.
- [x] Reload keeps which dicas are open.
- [x] When the bar's words do not fit on one row, the controls stack one per row and each word stays whole. When they fit, they sit on one row.

## Comments

Checked in the browser at `site/`: 60 rows, capa, Ler o caso, reload, return to an Em andamento cenário, and `#/caso/99` shows the list. `elm-test` passed 7. The bad hash stays in the address bar while the list is shown.

Supervisor: `elm-test` passed 16. Office opens the next dica only, keeps them in order, drops "Revelar dica" after the fourth, shows "2 dicas" on an Em andamento row, and does not set Resolvido. Save already encodes `dicas`. The bar is `position: fixed` with `white-space: nowrap` and `flex-wrap`. Recheck one-row vs one-per-row when the bar has more than one control.
