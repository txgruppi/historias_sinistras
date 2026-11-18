# Histórias Sinistras

Um jogo de mistério com 60 casos. Leia o cenário, abra até quatro dicas, revele a verdade quando quiser e marque o caso como resolvido por conta própria. O progresso fica salvo no seu navegador.

**Jogar:** <https://txgruppi.github.io/historias_sinistras/>

## Development

Requirements: [Elm](https://elm-lang.org) 0.19.3, [elm-test](https://github.com/rtfeldman/node-test-runner), and [just](https://github.com/casey/just). Docker is optional and only used by the serve recipes.

| Command | What it does |
| --- | --- |
| `just build` | Compiles `src/Main.elm` to `site/main.js` and writes hashed assets to `dist/` |
| `just test` | Runs the tests in `tests/` |
| `just serve` | Serves `site/` with nginx on port 8080 |
| `just serve-dist` | Serves `dist/` with nginx on port 8080 |

Layout:

- `src/`: the Elm application
- `site/`: the static page and `casos.json` (`main.js` is generated and gitignored)
- `tests/`: elm-test suites
- `docs/adr/`: architecture decision records
- [`GLOSSARY.md`](GLOSSARY.md): domain terms (caso, pasta, dica, verdade, ...)

Pushes to `master` run [`.github/workflows/pages.yml`](.github/workflows/pages.yml), which tests, builds, and publishes `dist/` to GitHub Pages.

## Créditos / License

A web port of the Cardputer game by Perrart: [github.com/perrart/historias_sinistras](https://github.com/perrart/historias_sinistras).

Required Notice: Copyright (c) 2026 Perrart (https://github.com/perrart/historias_sinistras)

Licensed under the [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0); see [`LICENSE.md`](LICENSE.md). You may use, change, and share it for noncommercial purposes only.

The Special Elite font is under the Apache License 2.0, and Elm and its packages are under BSD-3-Clause. The full texts are on the in-game credits page.
