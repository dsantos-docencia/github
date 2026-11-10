#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 04.01 — CODEOWNERS na ordem certa · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github
cat > .github/CODEOWNERS <<'TXT'
# Quem revisa o quê. A ÚLTIMA regra que casar vence:
# o padrão geral vem primeiro e as exceções, depois.
*            @aluno
*.js         @bia-dev
/docs/       @org/documentacao
/.github/    @aluno @org/plataforma
TXT
