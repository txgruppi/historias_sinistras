# 08: Como jogar and Créditos

**What to build:** From the list, the player can read how to play, including the Guardião do Segredo, and can read the notices for every work the page ships. Both pages return to the list.

**Blocked by:** 01: List, capa, and cenário

**Status:** done

- [x] "Como jogar" and "Créditos" sit in a short line under the title, before Filtrar and the rows.
- [x] `#/como-jogar` explains playing alone: form a theory, open a dica only when stuck, open the verdade when the player chooses, and mark the pasta only if they count it solved.
- [x] The same page explains the Guardião do Segredo: one player who has read the verdade answers only sim, não, or irrelevante. There is no second mode.
- [x] `#/creditos` shows `Copyright (c) 2026 Perrart (https://github.com/perrart/cardputer)`, the PolyForm Noncommercial summary, and the license text.
- [x] Créditos also shows Special Elite's OFL notice, Elm's BSD-3-Clause notice (Copyright 2012-present Evan Czaplicki, with the conditions and the disclaimer), and the notice for each Elm package the page imports.
- [x] Créditos does not name M5Stack, the Elm compiler binary, or the host.
- [x] Both pages offer "Lista" at the top.

## Comments

Supervisor: `#/como-jogar` and `#/creditos` parse in `Route`, and both pages offer only "Lista". The list puts those two controls under the title, before Filtrar. The PolyForm Noncommercial 1.0.0 text matches the official license. The font file's name table is Apache License 2.0, Copyright (c) 2010 Brian J. Bonislawsky DBA Astigmatic (AOETI), so Créditos shows that notice and the Apache 2.0 text instead of an OFL notice for a file we do not ship. Package notices are the six packages imported by `src/`. `elm-test` passed 61.
