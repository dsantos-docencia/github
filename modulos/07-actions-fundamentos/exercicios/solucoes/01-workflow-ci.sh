#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 07.01 — Um workflow de CI correto · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github/workflows
# Aspas em 'YAML': o Bash não tenta expandir nada do conteúdo.
cat > .github/workflows/ci.yml <<'YAML'
name: CI
on:
  push:
    branches: [main]
  pull_request:
permissions:
  contents: read          # menor privilégio: o GITHUB_TOKEN só lê
jobs:
  testes:
    runs-on: ubuntu-latest
    timeout-minutes: 10   # sem isto, o limite é de 6 horas
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - name: Rodar os testes
        run: ./testes.sh
YAML
