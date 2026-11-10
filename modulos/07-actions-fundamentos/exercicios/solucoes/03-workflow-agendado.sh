#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 07.03 — Manual, agendado e à prova de injeção · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github/workflows
cat > .github/workflows/relatorio.yml <<'YAML'
name: Relatório semanal
on:
  schedule:
    - cron: '0 11 * * 1'   # segunda, 11:00 UTC = 08:00 em Brasília (UTC-3)
  workflow_dispatch:
    inputs:
      dias:
        description: Quantos dias olhar para trás
        type: number
        default: 7
permissions:
  contents: read
jobs:
  relatorio:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - name: Montar o relatório
        env:
          # A expressão é resolvida AQUI, como dado; o script só lê a variável.
          # No agendamento não há inputs: o || 7 garante um valor.
          DIAS: ${{ inputs.dias || 7 }}
        run: echo "### Relatório dos últimos $DIAS dias" >> "$GITHUB_STEP_SUMMARY"
YAML
