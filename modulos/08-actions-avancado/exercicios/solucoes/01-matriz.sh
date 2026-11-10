#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 08.01 — Uma matriz com exclusão e inclusão · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github/workflows
cat > .github/workflows/matriz.yml <<'YAML'
name: Matriz
on: [push, pull_request]
permissions:
  contents: read
jobs:
  testes:
    strategy:
      fail-fast: false              # uma combinação quebrada não cancela as outras
      matrix:
        os: [ubuntu-latest, windows-latest]
        node: [20, 22, 24]
        exclude:
          - os: windows-latest
            node: 20
        include:
          - os: ubuntu-latest       # casa com uma combinação existente:
            node: 24                # só acrescenta "experimental"
            experimental: true
    runs-on: ${{ matrix.os }}
    continue-on-error: ${{ matrix.experimental == true }}
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - uses: actions/setup-node@949feb2413d6458794dcd2491c4babbbce0c15c1 # v7.1.0
        with:
          node-version: ${{ matrix.node }}
      - run: node --version
YAML
