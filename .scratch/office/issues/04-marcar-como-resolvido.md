# 04: Marcar como resolvido

**What to build:** The player marks a pasta Resolvido, or clears that mark, only while reading the cenário. The mark is a red stamp. Reload keeps it.

**Blocked by:** 01: List, capa, and cenário

**Status:** done

- [x] "Marcar como resolvido" sits in the fixed bottom bar on the cenário page and works before the verdade is open.
- [x] When the pasta is Resolvido, that control reads "Desmarcar" and returns the pasta to Em andamento.
- [x] The list and the capa show the state and do not offer the stamp.
- [x] A Resolvido pasta shows a red stamp.
- [x] A Resolvido row shows Resolvido and does not show a dica count or "verdade".
- [x] Opening the verdade does not set the mark.
- [x] Reload keeps Resolvido, and keeps Em andamento after "Desmarcar".
- [x] When the bar's words do not fit on one row, the controls stack one per row and each word stays whole.

## Comments

Supervisor rejected the first pass: the red stamp was a paragraph on the scrolling paper, and the capa did not show its state. The fix puts the red border and red type on the bar control "Desmarcar" only, and the capa exposes "Novo" without "Marcar como resolvido" or "Desmarcar". Desmarcar returns Em andamento and leaves dicas and the verdade open. `elm-test` passed 30.
