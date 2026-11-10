#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 03.03 — A fila de triagem · SOLUÇÃO COMENTADA
set -euo pipefail

repo="${1:?uso: $0 <dono/repo>}"
saida="$(gh issue list -R "$repo" --state open --limit 200 \
    --json number,title,assignees,labels |
  jq -r 'map(select((.assignees | length) == 0))
         | sort_by(.number)
         | .[]
         | "#\(.number) \(.title) [\([.labels[].name] | join(", "))]"')"
# -n testa "não vazio": se o filtro não devolveu nada, a fila está vazia.
if [[ -n "$saida" ]]; then printf '%s\n' "$saida"; else echo "fila vazia 🎉"; fi
