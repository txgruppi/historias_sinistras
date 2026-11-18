Status: done

## Problem Statement

Histórias Sinistras is a Brazilian Portuguese mystery game of 60 casos that today runs as Cardputer firmware. A player without that device cannot read a cenário, open a dica, open the verdade, or mark a pasta resolvido. The firmware's tiny screens, hardware keys, sound, and backlight are the wrong shape for a phone.

## Solution

A mobile-first, one-column page on GitHub Pages. The player picks a pasta from a list, turns the capa once, reads the cenário, opens up to four dicas in order, opens the verdade when they choose, and marks the pasta resolvido themselves. Progresso stays in that browser. The page looks like paperwork: warm off-white paper, black Special Elite, a red stamp for Resolvido. The words on the controls are fixed Brazilian Portuguese.

## User Stories

1. As a player, I want the list titled Histórias Sinistras, so that I know which game I opened.
2. As a player, I want the 60 pastas listed from 1 to 60, so that I can find a caso by número.
3. As a player, I want each row to show número, título, categoria, dificuldade, and Novo, Em andamento, or Resolvido, so that I can choose a pasta without opening it.
4. As a player, I want to open a pasta by choosing its row, so that there is no separate play control.
5. As a player, I want a Novo pasta to open on its capa, so that I see número, título, categoria, and dificuldade before the cenário.
6. As a player, I want the capa to offer "Ler o caso", so that turning the page is a deliberate action.
7. As a player, I want "Ler o caso" to show the cenário with no animation, so that the pasta becomes Em andamento.
8. As a player, I want a later visit to an Em andamento pasta to open on the cenário, so that the capa is not a gate every time.
9. As a player, I want the cenário page to show número, título, categoria, and dificuldade above the text, so that I still know which pasta I am in.
10. As a player, I want the cenário to stay on the page, so that I can re-read the question without a separate control.
11. As a player, I want "Revelar dica" to open only the next dica, in order, so that a later dica cannot appear before an earlier one.
12. As a player, I want each open dica to stay readable, so that I can use all of them together.
13. As a player, I want "Revelar dica" to leave the bar after the fourth dica, so that the page does not offer a fifth.
14. As a player, I want "Revelar a verdade" to work when zero dicas are open, so that I can answer with no help.
15. As a player, I want the verdade to stay on the page once opened, and "Revelar a verdade" to leave the bar, so that I can read it without opening it again.
16. As a player, I want opening the verdade to leave the pasta unmarked, so that reading the explanation is not the same as solving the caso.
17. As a player, I want "Marcar como resolvido" on the cenário page before the verdade is open, so that I can record a solution I have not checked yet.
18. As a player, I want "Desmarcar" when the pasta is Resolvido, so that clearing the mark returns it to Em andamento.
19. As a player, I want the list and the capa to show the state and not the stamp, so that I cannot mark a pasta I am not reading.
20. As a player, I want an Em andamento row to show the count as "2 dicas", so that I can see how far I got.
21. As a player, I want an Em andamento row to show "verdade" when the verdade is open, so that I can see I already read it.
22. As a player, I want a Novo row and a Resolvido row to omit that dica count and that "verdade" line, so that the list only adds detail while a pasta is Em andamento.
23. As a player, I want "Lista", "Anterior", and "Próximo" at the top of a pasta, including the capa, so that I can move without a resume control.
24. As a player, I want "Anterior" absent on pasta 1 and "Próximo" absent on pasta 60, so that the ends of the list are obvious.
25. As a player, I want "Anterior" and "Próximo" to follow id order and to open each pasta on its capa or its cenário according to its state, so that moving does not skip the capa of a Novo pasta or repeat the capa of an Em andamento pasta.
26. As a player, I want "Lista" to return me to the list, so that I can pick a different pasta.
27. As a player, I want the browser back control to leave the pasta, so that ordinary browser navigation still works.
28. As a player, I want one Filtrar control, so that state, categoria, and dificuldade do not sit stacked above the rows.
29. As a player, I want a pasta to appear only when it matches every filter I set, so that the filters narrow the same 1-to-60 order.
30. As a player, I want an active filter to stay visible, so that I can tell the list is narrowed.
31. As a player, I want "Limpar" to clear the filters, so that all 60 pastas return.
32. As a player, I want the list to say when nothing matches, so that an empty result is not a blank page.
33. As a player, I want a filter to stay in effect while I open a pasta and come back, until I reload the page, so that I do not rebuild it every time.
34. As a player, I want Como jogar and Créditos in a short line under the title, before Filtrar and the rows, so that the rules are reachable on a phone.
35. As a player, I want Zerar progresso after the rows, so that it is not beside the pastas I mean to open.
36. As a player, I want Zerar progresso to offer "Confirmar" and "Cancelar" with no wait, so that a stray tap does not erase progresso and a timer does not block me.
37. As a player, I want "Cancelar" to leave every pasta as it was, so that I can back out.
38. As a player, I want "Confirmar" to return every pasta to Novo, so that capas, dicas, verdades, and marks are all shut.
39. As a player, I want a Resolvido filter that is still active after Zerar progresso to show an empty list until Limpar, so that the filter keeps meaning what I set.
40. As a player on a phone, I want one column, so that the list and the pasta are readable without a side-by-side desk.
41. As a player on a wide window, I want that same column with more margin and a short line, so that Special Elite stays readable.
42. As a player, I want "Revelar dica", "Revelar a verdade", and the stamp in a bar fixed to the bottom of the cenário page, so that the actions stay in reach while the paper scrolls.
43. As a player on a phone, I want those three controls stacked one per row when one row would cut the words, so that each word stays whole.
44. As a player on a wide column, I want those three controls on one row when they fit, so that the bar does not stay tall for no reason.
45. As a player, I want the capa to keep "Ler o caso" on the page and to have no three-action bar, so that the only action on a capa is turning it.
46. As a player, I want every action to be a visible control, so that I do not need Cardputer keys or the digits 1, 2, or 5.
47. As a player, I want the controls sized for a thumb, so that the phone layout is the one the page is built for.
48. As a player, I want warm off-white paper, black Special Elite, and a red stamp on a Resolvido pasta, so that the page reads as a file on a desk. _(Superseded by `.scratch/redesign/spec.md`.)_
49. As a player, I want the type large and the line short, so that a verdade is readable in a typewriter face. _(Superseded by `.scratch/redesign/spec.md`.)_
50. As a player, I want no animation and no sound, so that nothing gates the text that is already visible. _(Kept; also in `.scratch/redesign/spec.md`.)_
51. As a player, I want the page in Brazilian Portuguese, including every control word named in this spec, so that I am not offered an English interface.
52. As a player, I want progresso to remain in this browser when I leave and come back, so that Em andamento and Resolvido survive a reload.
53. As a player, I want no account, so that I do not sign in to keep my pastas.
54. As a player, I want unreadable progresso to behave as every pasta Novo, so that a broken save does not trap the page.
55. As a player with two tabs open, I want the last write to win, so that the page does not pretend the tabs are synchronized.
56. As a player, I want `#/` to be the list, `#/caso/<id>` to be that pasta, `#/como-jogar` to be the rules, and `#/creditos` to be the notices, so that refresh and a shared link return to the same place.
57. As a player, I want an id outside 1–60 to return me to the list, so that a bad link is not a broken pasta.
58. As a player, I want a shared link to hide every dica and the verdade until I open them, so that the link itself is not the reveal.
59. As a player, I want Como jogar and Créditos to offer "Lista" at the top, so that I can return without relying on the browser alone.
60. As a player, I want Como jogar to explain playing alone, so that I know to form a theory, open a dica only when stuck, open the verdade when I choose, and mark the pasta only if I count it solved.
61. As a player in a group, I want Como jogar to explain the Guardião do Segredo, so that one person who has read the verdade can answer only sim, não, or irrelevante.
62. As a player in a group, I want no second mode for the Guardião, so that the office stays the same list and the same pasta.
63. As a player, I want Créditos to show the required notice `Copyright (c) 2026 Perrart (https://github.com/perrart/historias_sinistras)`, the PolyForm Noncommercial summary, and the license text, so that I can see what I may do with the casos.
64. As a player, I want Créditos to include Special Elite's OFL notice, Elm's BSD-3-Clause notice, and the notice for each Elm package the page imports, so that the works I downloaded are named with the notice their license requires.
65. As a player, I want the casos' words left as written, so that the port does not rewrite a mistério.

## Implementation Decisions

- The product is one Elm 0.19.3 program. The compiler already on the machine emits static JavaScript. GitHub Pages serves the HTML shell, the CSS, the font file, the casos, and that JavaScript. The browser never loads Elm source.
- One module, the office, owns the transition. It takes the casos, the progresso, the current page, and one player action, and it returns the next progresso and the page the player is looking at. The view draws that result and holds no rules of its own.
- The hash route and the browser save are adapters. The route adapter turns `#/`, `#/caso/<id>`, `#/como-jogar`, and `#/creditos` into a page request and turns a page change back into a hash. The save adapter loads progresso when the page opens and writes it when the office changes it. Neither adapter decides what a dica, a verdade, or a mark means.
- A caso has a stable id, a título, a categoria, a dificuldade, a cenário, four dicas, and one verdade. The shipped set is ids 1 through 60, text unchanged. Categoria is one of Assassinatos, Crimes Impossíveis, Mortes Misteriosas, Desaparecimentos, Segredos Macabros, Mistérios Psicológicos, Acidentes Fatais. Dificuldade is one of Fácil, Médio, Difícil, Insano.
- Progresso records, per pasta, whether it is Novo, Em andamento, or Resolvido, how many dicas are open, and whether the verdade is open. Filters are visit state. They last until reload, including a trip into a pasta and back. They are not written with progresso.
- "Ler o caso" is the only transition from Novo to Em andamento. Opening the verdade never sets Resolvido. The stamp is only on the cenário page. "Desmarcar" returns the pasta to Em andamento. Zerar progresso returns every pasta to Novo and is a second control on the list, "Confirmar" and "Cancelar", with no timer and no extra route.
- The cenário paper shows identity, then the cenário, then open dicas in order, then the verdade if it is open. The fixed bar holds only the actions that still apply: "Revelar dica" until four are open, "Revelar a verdade" until it is open, and the stamp always. On a narrow column the bar stacks those controls one per row. On a wide column it uses one row when the words fit. The top of every pasta, and of Como jogar and Créditos, offers "Lista". "Anterior" and "Próximo" exist only on a pasta, and they are absent at ids 1 and 60.
- The list title is Histórias Sinistras. Under it: Como jogar, Créditos, then one Filtrar control, then the rows, then Zerar progresso. An Em andamento row adds "N dicas" and, when open, "verdade". A filter that matches nothing says so.
- Visuals are one column at every width, more margin when the window is wide, a short measure, large Special Elite for every string, warm off-white paper, black type, and a red stamp for Resolvido. Special Elite is a file the page serves, with its OFL notice. There is no animation and no sound. _(Visual palette superseded by `.scratch/redesign/spec.md`; rules unchanged.)_
- Créditos include the Perrart notice, the PolyForm Noncommercial summary, the license text, the Special Elite notice, the Elm BSD-3-Clause notice (Copyright 2012-present Evan Czaplicki, with the license conditions and disclaimer), and the notice for each Elm package the program imports. Packages that are not imported are not credited.
- The control words are exactly: "Ler o caso", "Lista", "Anterior", "Próximo", "Revelar dica", "Revelar a verdade", "Marcar como resolvido", "Desmarcar", "Confirmar", "Cancelar", "Filtrar", "Limpar", "Como jogar", "Créditos", and the state words Novo, Em andamento, and Resolvido.
- Unreadable progresso is treated as every pasta Novo. An id outside 1–60 selects the list. Two tabs share the save and the last write wins.

## Testing Decisions

- A good test performs a player action and asserts what the player can see and what the progresso became. It does not assert markup, CSS, ports, or storage bytes.
- The only tested module is the office. The view and the two adapters are outside the seam. If a behavior cannot be stated as an office transition, it is not a rule.
- There is no prior test suite in this repo. The runner is elm-test 0.19.3-0, already installed, against Elm 0.19.3.
- The suite covers the transitions in the user stories: capa to cenário, dica order and the missing fifth, verdade with zero dicas, stamp before and after the verdade, desmarcar, anterior and próximo at the ends and across Novo and Em andamento pastas, filters including the empty result and survival across opening a pasta, zerar and cancelar, a bad id, and unreadable progresso.

## Out of Scope

- A Continuar control, a splash, a reler control, and a second mode for the Guardião do Segredo.
- Cardputer keys, the digits 1, 2, and 5 as shortcuts, brightness, a backlight sleep, sound, volume, text speed, a text-size control, and any animation or glitch.
- A side-by-side list and pasta, a drawn room, IBM Plex. _(A dark screen is in scope for `.scratch/redesign/spec.md`.)_
- An English translation.
- An account, a server, or a save that syncs two tabs.
- Path URLs that depend on GitHub Pages rewriting every route to the shell. The address stays a hash.
- M5Stack, the Cardputer flashing instructions, and crediting the Elm compiler binary or the host.
- Rewriting, adding, or removing casos.
- Installing further tools. Elm and elm-test are already on the machine.

## Further Notes

- The 60 casos are the corrected JSON already produced from the original text: ids 1 through 60, every required field present, categoria and dificuldade counts matching the firmware. That JSON is the data to ship. The original text remains the copyrighted source. PolyForm Noncommercial 1.0.0 applies, and the required notice must ship with the page.
- No ADR has been written. The choice of Elm is the decision most worth an ADR if one is added later.
- Publishing this spec did not copy the casos into the repo and did not run Elm.
