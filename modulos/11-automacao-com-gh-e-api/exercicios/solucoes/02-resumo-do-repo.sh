#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.02 — Um comando novo para o gh · SOLUÇÃO COMENTADA
set -euo pipefail

repo="${1:-}"
if [[ -z "$repo" ]]; then
    # Sem argumento: o repositório da pasta atual (como os comandos do gh fazem).
    repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)" || repo=''
fi
[[ -n "$repo" ]] || { echo "uso: gh resumo <dono/repo>  (ou rode dentro de um clone)" >&2; exit 2; }

issues="$(gh issue list -R "$repo" --state open --limit 1000 --json number --jq length)"
prs="$(gh pr list -R "$repo" --state open --limit 1000 --json number --jq length)"
echo "$repo: $issues issues abertas, $prs PRs abertos"
