#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 10.03 — Boas-vindas sem injeção · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github/workflows
cat > .github/workflows/boas-vindas.yml <<'YAML'
name: Boas-vindas
on:
  issues:
    types: [opened]
permissions: {}            # topo: nenhuma permissão
jobs:
  comentar:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    permissions:
      issues: write        # só o que este job precisa
    steps:
      - name: Comentar
        env:
          # Tudo que vem do evento entra como DADO (variável), nunca colado no script.
          GH_TOKEN: ${{ github.token }}
          REPO: ${{ github.repository }}
          NUMERO: ${{ github.event.issue.number }}
          TITULO: ${{ github.event.issue.title }}
          AUTOR: ${{ github.event.issue.user.login }}
        run: |
          gh issue comment "$NUMERO" -R "$REPO" \
            --body "Obrigado, @$AUTOR! Recebemos: \"$TITULO\". Vamos triar em breve."
YAML
