#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 08.03 — Workflow reutilizável e quem o chama · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github/workflows
cat > .github/workflows/testes-reutilizavel.yml <<'YAML'
name: Testes (reutilizável)
on:
  workflow_call:
    inputs:
      versao-node:
        type: string
        required: false
        default: "22"
permissions:
  contents: read
jobs:
  testes:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - uses: actions/setup-node@949feb2413d6458794dcd2491c4babbbce0c15c1 # v7.1.0
        with:
          node-version: ${{ inputs.versao-node }}
      - run: node --version
YAML
# Quem chama: um job com "uses:" no lugar de runs-on/steps.
cat > .github/workflows/ci.yml <<'YAML'
name: CI
on: [push, pull_request]
permissions:
  contents: read
jobs:
  testes:
    uses: ./.github/workflows/testes-reutilizavel.yml
    with:
      versao-node: "24"
YAML
