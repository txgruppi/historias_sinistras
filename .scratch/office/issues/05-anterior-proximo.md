# 05: Anterior and Próximo

**What to build:** From a pasta, including the capa, the player moves to the previous or next id. The ends of the list have no control that would step past them. A Novo pasta opens on its capa. Any other open pasta opens on its cenário.

**Blocked by:** 01: List, capa, and cenário

**Status:** done

- [x] "Anterior" and "Próximo" sit at the top of the capa and of the cenário, beside "Lista".
- [x] They move by id, one pasta at a time.
- [x] "Anterior" is absent on pasta 1. "Próximo" is absent on pasta 60.
- [x] Landing on a Novo pasta shows its capa. Landing on an Em andamento pasta shows its cenário.
- [x] "Lista" still returns to the list.

## Comments

Supervisor: `controlesTopo` is shared by the capa and the cenário. `IrAnterior` and `IrProximo` change the route and leave progresso alone. Novo lands on the capa. Em andamento and Resolvido land on the cenário, which is the same `view` branch as `AbrirPasta`. `elm-test` passed 37.
