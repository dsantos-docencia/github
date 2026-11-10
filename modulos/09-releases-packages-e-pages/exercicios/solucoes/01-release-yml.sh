#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 09.01 — Categorias das notas de release · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github
cat > .github/release.yml <<'YAML'
changelog:
  exclude:
    labels: [ignorar-nas-notas]
    authors: [dependabot]
  categories:
    - title: 🚀 Novidades
      labels: [feature, melhoria]
    - title: 🐛 Correções
      labels: [bug]
    - title: Outras mudanças
      labels: ["*"]        # coringa: o que não caiu antes. Sempre por último.
YAML
