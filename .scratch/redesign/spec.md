Status: ready-for-agent

## Problem Statement

The playable browser office already implements every pasta rule from `.scratch/office/spec.md`, but it still looks like warm desk paper. The Cardputer reference is a near-black dossier with cream and blood-red type, compact rows, stamps, and a mobile-first action bar. Players who know the firmware should recognize the same feel without new screens or new rules.

## Solution

Re-skin the existing Elm program. The office module keeps every transition. The view and `site/style.css` adopt the dark dossier: two-tone list title, NN/60 resolvidos counter (ignores filters), stamped row states, sticky pasta strips, capa cover layout, cenário dica chips and headings, fixed thumb bar, and a zerar progresso warning panel. Special Elite only. No animation, sound, splash, menu, keyboard shortcuts, or second font.

Supersedes `.scratch/office/spec.md` stories 41, 48–50, the Visuals bullet in Implementation Decisions, and the out-of-scope line that forbade the device's black screen.

## User Stories

1. As a player, I want a near-black page with cream text and red accents, so that the web office matches the Cardputer dossier feel.
2. As a player, I want the list headed by cream HISTÓRIAS and red SINISTRAS with a red rule and NN/60 resolvidos, so that I see overall progress even when the list is filtered.
3. As a player, I want compact rows with número, título, categoria, difficulty pips, and a rotated stamp for Novo, Em andamento, or Resolvido, so that I can scan the arquivo quickly.
4. As a player on a pasta, I want a sticky strip with Lista, Anterior, Próximo, and the glossary state word, so that I always know where I am.
5. As a player on a Novo capa, I want a centred cover and a solid-red Ler o caso control, so that turning the capa feels deliberate.
6. As a player on the cenário, I want dica chips, per-dica headings, an A VERDADE heading, a RESOLVIDO stamp beside the título when marked, and a fixed bottom bar with Revelar dica primary, so that investigation matches the reference hierarchy.
7. As a player, I want Zerar progresso to show a red-bordered warning with the reference sentence before Confirmar, so that I do not erase progresso by mistake.
8. As a player, I want one column about 40rem centred on the dark background, so that phone and wide windows stay readable.
9. As a player, I want no animation and no sound, so that text is never gated (office story 50 kept).
10. As a player, I want every control word unchanged from the office spec, so that Brazilian Portuguese labels stay stable.

## Implementation Decisions

- Office gains `resolvidos : Int` and `avisoZerar : Maybe String` on `ListaPage` only. Pips, chips, stamp placement, and uppercase chrome are view/CSS; control strings are not renamed (`controleParaMsg` matches label text).
- Colour tokens: background near `#0d0d0d`, cream `#e8e0d4`, text red `#e5484d`, fill red `#b3121b` for solid buttons and Resolvido stamps with cream text. Visible `:focus-visible` ring.
- `theme-color` meta matches the background.
- Reference PNGs for local comparison live under `local/referencias/` (gitignored).

## Testing Decisions

- Test `resolvidos` counts all Resolvido pastas and ignores active filters; drops to 0 after Confirmar on zerar.
- Test `avisoZerar` is `Just` only while `visita.confirmarZerar` is true.
- Existing office suite must still pass. View/CSS are not unit-tested.

## Out of Scope

- Splash, main menu, investigation menu, separate dica/verdade pages, Casos resolvidos stats screen, Configurações.
- Toasts, interstitials, keyboard shortcuts, IBM Plex, light theme, fingerprint/eye decoration, sound, animation, text-size control.
- Office rule changes, new routes, caso text edits.

## Further Notes

- ADR: `docs/adr/0001-dark-dossier-look.md`.
- Glossary: investigação stays avoided for Em andamento.