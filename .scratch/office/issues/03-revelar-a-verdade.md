# 03: Revelar a verdade

**What to build:** The player can open the verdade with no dicas open. It stays on the page. The pasta is not marked. Reload keeps it open.

**Blocked by:** 01: List, capa, and cenário

**Status:** done

- [x] "Revelar a verdade" sits in the fixed bottom bar and works when zero dicas are open.
- [x] The verdade stays on the page after the cenário and any open dicas. The control leaves the bar once it is open.
- [x] Opening the verdade leaves the pasta Em andamento.
- [x] An Em andamento row shows "verdade" when it is open.
- [x] Reload keeps the verdade open.
- [x] When the bar's words do not fit on one row, the controls stack one per row and each word stays whole.

## Comments

Supervisor: `RevelarVerdade` sets `verdade` and leaves `estado` as Em andamento. The bar includes the control until it is open, including with zero dicas. An Em andamento row lists "verdade". Save already encodes the flag. Bar CSS was already `position: fixed`, `flex-wrap`, and `white-space: nowrap`. `elm-test` passed 22. The process exit after the run was sandbox `kill EACCES`, not a test failure.

## Comments

Supervisor stopped before an implementer started. `composer-2.5` is not a valid subagent model here. `composer-2.5-fast` is forbidden. No substitute was used.
