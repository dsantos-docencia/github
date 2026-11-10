#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.03 — Todos os repositórios ativos de uma organização · SOLUÇÃO COMENTADA
set -euo pipefail

org="${1:-}"
[[ -n "$org" ]] || { echo "uso: $0 <organização>" >&2; exit 2; }
# --paginate: o gh segue o cabeçalho Link até a última página.
# per_page=100: menos idas à API (o padrão é 30).
# O --jq roda em CADA página; o sort junta e ordena tudo no final.
nomes="$(gh api --paginate "orgs/$org/repos?per_page=100" \
    --jq '.[] | select(.archived | not) | .full_name' | sort)"
[[ -n "$nomes" ]] && printf '%s\n' "$nomes"
echo "total: $(grep -c . <<<"$nomes")"
