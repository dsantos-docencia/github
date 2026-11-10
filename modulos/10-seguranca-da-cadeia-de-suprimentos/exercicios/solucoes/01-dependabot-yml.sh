#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 10.01 — Dependabot com grupos e cooldown · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github
cat > .github/dependabot.yml <<'YAML'
version: 2
updates:
  # As próprias ações do Actions: o Dependabot atualiza a tag E o SHA fixado.
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    groups:
      acoes:
        patterns: ["*"]        # um PR único para todas as ações
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly
    open-pull-requests-limit: 5
    cooldown:
      default-days: 7          # versão nova só depois de uma semana publicada
    groups:
      dev:
        dependency-type: development
YAML
