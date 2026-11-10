#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 00.01 — README com recursos do GitHub · SOLUÇÃO COMENTADA
set -euo pipefail

# <<'MD' (com aspas) = o Bash não expande nada dentro: crases e $ vão literais.
cat > README.md <<'MD'
# Meu Projeto

> [!NOTE]
> Este README foi gerado por um script do Curso de GitHub.

## Tarefas
- [x] criar o repositório
- [ ] escrever os testes

## Comandos
| Ação | Comando |
|---|---|
| testar | `./testes.sh` |

## Fluxo
```mermaid
graph LR
  Issue --> PR --> Merge
```
MD
